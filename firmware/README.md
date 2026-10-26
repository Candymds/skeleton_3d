# Firmware del ESP32

Al pulsar el botón, el cráneo:

1. Pide a Claude (API de Anthropic) una calaverita literaria corta y al azar, en español de México.
2. La convierte en voz con la API de voz de OpenAI (`gpt-4o-mini-tts`, audio PCM de 24 kHz).
3. La reproduce por el MAX98357A mientras llega, y abre la mandíbula según el volumen de cada fragmento de 20 ms.

Claude no genera audio, por eso la voz viene de OpenAI. Hacen falta dos claves de API, una de cada servicio, y cada calaverita gasta una pequeña cantidad en ambas.

Las conexiones están en [`docs/conexiones.md`](../docs/conexiones.md).

## Preparar

1. Instala [PlatformIO](https://platformio.org/install) (extensión de VS Code o `pip install platformio`).
2. Copia `include/secrets.example.h` como `include/secrets.h` y rellena la red WiFi y las dos claves. `secrets.h` está en `.gitignore`: no se sube al repositorio.
3. Con el cargador del pedestal **desconectado**, conecta el ESP32 al ordenador por su micro-USB y ejecuta, desde esta carpeta:

   ```bash
   pio run -t upload
   pio device monitor
   ```

4. El monitor muestra la conexión WiFi y cada calaverita en texto. Pulsa el botón.

## Ajustes (`include/config.h`)

- `JAW_CLOSED_DEG` / `JAW_OPEN_DEG`: el horn se monta con el servo centrado (90°) y la boca cerrada, y abrir son 60° más. Si al probar la mandíbula empuja contra el tope en lugar de abrir, cambia `JAW_OPEN_DEG` a 30.
- `JAW_GAIN`, `JAW_ATTACK`, `JAW_RELEASE`: cuánto y con qué rapidez abre y cierra.
- `VOLUME`: 0,5 por defecto para no pasar de 1 W en un altavoz de 8 Ω.
- `CLAUDE_MODEL`, `TTS_MODEL`, `TTS_VOICE`: modelo de texto, modelo de voz y voz (`onyx` es grave; también hay `ash`, `ballad`, `echo`...).

Si algo falla (sin WiFi, error de una API), el LED parpadea y la mandíbula hace tres movimientos cortos. El motivo aparece en el monitor serie.

## Seguridad

Las conexiones HTTPS no verifican el certificado del servidor (`setInsecure()`), para no tener que mantener certificados raíz en el firmware. En tu WiFi de casa es aceptable; en una red pública alguien podría interceptar las claves. Usa claves con límite de gasto.
