// Ajustes del cráneo parlante. Todo lo que puede cambiar con el montaje está aquí.
#pragma once

// --- Pines (ver docs/conexiones.md) ---
#define PIN_SERVO   13
#define PIN_I2S_BCLK 26
#define PIN_I2S_LRC  25
#define PIN_I2S_DIN  22
#define PIN_BUTTON   4   // pulsador a GND, usa la resistencia pull-up interna
#define PIN_LED      2   // LED azul de la placa DevKit

// --- Mandíbula ---
// Ángulos de servo.write(). El horn se monta con el servo centrado (90°) y la
// boca cerrada; abrir son 60° de recorrido (≈ 30° de mandíbula). Si al probar la
// boca se abre hacia el lado equivocado, cambia JAW_OPEN_DEG a 30.
#define JAW_CLOSED_DEG 90
#define JAW_OPEN_DEG   150
#define JAW_GAIN       4.0f   // cuánto abre según el volumen de la voz
#define JAW_ATTACK     0.6f   // 0..1: rapidez al abrir
#define JAW_RELEASE    0.25f  // 0..1: rapidez al cerrar

// --- Audio ---
#define TTS_SAMPLE_RATE 24000  // el formato "pcm" de OpenAI es 24 kHz, 16 bits, mono
#define VOLUME          0.5f   // 0..1. Con 5 V el MAX98357A puede dar más de 1 W a 8 Ω

// --- APIs ---
#define CLAUDE_MODEL "claude-opus-5-5"
#define TTS_MODEL    "gpt-4o-mini-tts"
#define TTS_VOICE    "onyx"
