// Cráneo parlante: al pulsar el botón pide a Claude una calaverita corta,
// la convierte en voz con la API de OpenAI y la reproduce por el MAX98357A
// mientras mueve la mandíbula según el volumen de la voz.

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>
#include <driver/i2s.h>
#include <math.h>

#include "config.h"
#include "secrets.h"

static const i2s_port_t I2S_PORT = I2S_NUM_0;
// Bloque de análisis de la mandíbula: 480 muestras = 20 ms a 24 kHz.
static const size_t BLOCK_SAMPLES = 480;

static Servo jaw;
static float jawLevel = 0;  // 0 = cerrada, 1 = abierta del todo

static const char *TOPICS[] = {
  "un programador que nunca hacía respaldos",
  "una maestra muy estricta",
  "un taquero famoso del barrio",
  "un gato que se creía tigre",
  "un futbolista que fallaba penales",
  "una abuela que cocinaba el mejor mole",
  "un robot que quería bailar",
  "un influencer sin señal de wifi",
  "un mariachi desafinado",
  "un dentista con miedo a las agujas",
  "una impresora 3D que siempre se atascaba",
  "un esqueleto que hablaba demasiado",
};

// ---------- Mandíbula ----------

static void setJaw(float level) {
  level = constrain(level, 0.0f, 1.0f);
  jaw.write(JAW_CLOSED_DEG + (int)lroundf(level * (JAW_OPEN_DEG - JAW_CLOSED_DEG)));
}

static void updateJawFromRms(float rms) {
  float target = constrain(rms * JAW_GAIN, 0.0f, 1.0f);
  float k = target > jawLevel ? JAW_ATTACK : JAW_RELEASE;
  jawLevel += (target - jawLevel) * k;
  setJaw(jawLevel);
}

// Movimiento de "no" cuando algo falla (sin red, error de la API...).
static void shakeJawError() {
  for (int i = 0; i < 3; i++) {
    setJaw(0.4f); digitalWrite(PIN_LED, HIGH); delay(150);
    setJaw(0.0f); digitalWrite(PIN_LED, LOW);  delay(150);
  }
}

// ---------- Audio ----------

static void setupI2S() {
  i2s_config_t cfg = {};
  cfg.mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX);
  cfg.sample_rate = TTS_SAMPLE_RATE;
  cfg.bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT;
  cfg.channel_format = I2S_CHANNEL_FMT_RIGHT_LEFT;
  cfg.communication_format = I2S_COMM_FORMAT_STAND_I2S;
  cfg.intr_alloc_flags = 0;
  // Buffer DMA corto (4 × 240 muestras ≈ 40 ms) para que la mandíbula
  // vaya casi a la par con lo que suena.
  cfg.dma_buf_count = 4;
  cfg.dma_buf_len = 240;
  cfg.use_apll = false;
  cfg.tx_desc_auto_clear = true;  // si la red se atrasa, suena silencio y no un zumbido

  i2s_pin_config_t pins = {};
  pins.mck_io_num = I2S_PIN_NO_CHANGE;
  pins.bck_io_num = PIN_I2S_BCLK;
  pins.ws_io_num = PIN_I2S_LRC;
  pins.data_out_num = PIN_I2S_DIN;
  pins.data_in_num = I2S_PIN_NO_CHANGE;

  i2s_driver_install(I2S_PORT, &cfg, 0, nullptr);
  i2s_set_pin(I2S_PORT, &pins);
  i2s_zero_dma_buffer(I2S_PORT);
}

// Recibe el PCM de la respuesta HTTP (HTTPClient ya quita el "chunked"),
// lo manda al amplificador y mueve la mandíbula cada 20 ms de audio.
class AudioSink : public Stream {
 public:
  size_t write(uint8_t b) override { return write(&b, 1); }

  size_t write(const uint8_t *data, size_t len) override {
    for (size_t i = 0; i < len; i++) {
      if (!haveLow) { low = data[i]; haveLow = true; continue; }
      haveLow = false;
      int16_t s = (int16_t)(low | (data[i] << 8));
      push(s);
    }
    return len;
  }

  void finish() {
    if (n > 0) flushBlock();
    i2s_zero_dma_buffer(I2S_PORT);
  }

  int available() override { return 0; }
  int read() override { return -1; }
  int peek() override { return -1; }
  void flush() override {}

 private:
  int16_t frames[BLOCK_SAMPLES * 2];  // estéreo intercalado L, R
  size_t n = 0;
  double sumSq = 0;
  uint8_t low = 0;
  bool haveLow = false;

  void push(int16_t s) {
    sumSq += (double)s * s;
    int16_t out = (int16_t)(s * VOLUME);
    frames[2 * n] = out;
    frames[2 * n + 1] = out;
    if (++n == BLOCK_SAMPLES) flushBlock();
  }

  void flushBlock() {
    float rms = sqrtf(sumSq / n) / 32768.0f;
    updateJawFromRms(rms);
    size_t written;
    i2s_write(I2S_PORT, frames, n * 2 * sizeof(int16_t), &written, portMAX_DELAY);
    n = 0;
    sumSq = 0;
  }
};

// ---------- Red ----------

static bool connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return true;
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Conectando a WiFi");
  for (int i = 0; i < 40 && WiFi.status() != WL_CONNECTED; i++) {
    digitalWrite(PIN_LED, i % 2);
    delay(250);
    Serial.print('.');
  }
  digitalWrite(PIN_LED, LOW);
  Serial.println(WiFi.status() == WL_CONNECTED ? " listo" : " falló");
  return WiFi.status() == WL_CONNECTED;
}

// Sin verificar el certificado del servidor: más simple, pero en una red no
// confiable alguien podría interceptar las claves. Ver firmware/README.md.
static void prepareClient(WiFiClientSecure &client) {
  client.setInsecure();
  client.setTimeout(30);
}

// Pide a Claude una calaverita. Devuelve "" si falla.
static String askClaude() {
  const char *topic = TOPICS[esp_random() % (sizeof(TOPICS) / sizeof(TOPICS[0]))];

  JsonDocument req;
  req["model"] = CLAUDE_MODEL;
  req["max_tokens"] = 1024;
  req["fallbacks"] = "default";
  req["output_config"]["effort"] = "low";
  req["system"] =
      "Eres una calavera mexicana parlante que recita calaveritas literarias "
      "para el Día de Muertos. Escribe una sola calaverita original, en español "
      "de México, de cuatro versos que rimen, con humor ligero y sin groserías. "
      "Responde solo con los versos, sin título ni explicación.";
  JsonObject msg = req["messages"].add<JsonObject>();
  msg["role"] = "user";
  msg["content"] = String("Haz una calaverita sobre ") + topic + ".";
  String body;
  serializeJson(req, body);

  WiFiClientSecure client;
  prepareClient(client);
  HTTPClient http;
  http.setTimeout(30000);
  http.begin(client, "https://api.anthropic.com/v1/messages");
  http.addHeader("content-type", "application/json");
  http.addHeader("x-api-key", ANTHROPIC_API_KEY);
  http.addHeader("anthropic-version", "2023-06-01");
  http.addHeader("anthropic-beta", "server-side-fallback-2026-07-01");

  int code = http.POST(body);
  String resp = http.getString();
  http.end();
  if (code != 200) {
    Serial.printf("Claude respondió %d: %s\n", code, resp.c_str());
    return "";
  }

  JsonDocument doc;
  if (deserializeJson(doc, resp)) {
    Serial.println("No se pudo leer la respuesta de Claude");
    return "";
  }
  if (doc["stop_reason"] == "refusal") {
    Serial.println("Claude no quiso responder");
    return "";
  }
  String text;
  for (JsonObject block : doc["content"].as<JsonArray>()) {
    if (block["type"] == "text") text += block["text"].as<const char *>();
  }
  text.trim();
  return text;
}

// Convierte el texto en voz y lo reproduce mientras llega. true si sonó.
static bool speak(const String &text) {
  JsonDocument req;
  req["model"] = TTS_MODEL;
  req["voice"] = TTS_VOICE;
  req["input"] = text;
  req["response_format"] = "pcm";
  req["instructions"] =
      "Habla en español de México con voz grave, lenta y teatral, como una "
      "calavera divertida que recita un poema en el Día de Muertos.";
  String body;
  serializeJson(req, body);

  WiFiClientSecure client;
  prepareClient(client);
  HTTPClient http;
  http.setTimeout(30000);
  http.begin(client, "https://api.openai.com/v1/audio/speech");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", String("Bearer ") + OPENAI_API_KEY);

  int code = http.POST(body);
  if (code != 200) {
    Serial.printf("OpenAI respondió %d: %s\n", code, http.getString().c_str());
    http.end();
    return false;
  }
  AudioSink sink;
  int bytes = http.writeToStream(&sink);
  sink.finish();
  http.end();
  Serial.printf("Audio reproducido: %d bytes\n", bytes);
  return bytes > 0;
}

// ---------- Programa ----------

static void tellCalaverita() {
  digitalWrite(PIN_LED, HIGH);
  if (!connectWiFi()) { shakeJawError(); return; }

  String text = askClaude();
  if (text.isEmpty()) { shakeJawError(); return; }
  Serial.println(text);

  bool ok = speak(text);
  jawLevel = 0;
  setJaw(0);
  digitalWrite(PIN_LED, LOW);
  if (!ok) shakeJawError();
}

void setup() {
  Serial.begin(115200);
  pinMode(PIN_LED, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);

  jaw.setPeriodHertz(50);
  jaw.attach(PIN_SERVO, 500, 2400);
  setJaw(0);

  setupI2S();
  connectWiFi();
  Serial.println("Listo: pulsa el botón para escuchar una calaverita");
}

void loop() {
  static uint32_t pressedSince = 0;
  if (digitalRead(PIN_BUTTON) == LOW) {
    if (pressedSince == 0) pressedSince = millis();
    if (millis() - pressedSince > 40) {  // antirrebote
      tellCalaverita();
      while (digitalRead(PIN_BUTTON) == LOW) delay(10);
      pressedSince = 0;
    }
  } else {
    pressedSince = 0;
  }
  delay(5);
}
