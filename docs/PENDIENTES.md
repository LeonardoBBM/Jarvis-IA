# Pendientes / ideas

## Velocidad

- Crear un agente de voz rápido separado del `main`, con modelo más ligero y contexto mínimo.
- Añadir más comandos locales para evitar consultas OpenAI/OpenClaw.
- Medir latencia por etapas: wake word → grabación → Vosk → intent → TTS → OpenClaw.

## Voz

- Probar alternativas masculinas en Microsoft Edge TTS si Álvaro no convence del todo.
- Evitar fallback `spd-say` salvo emergencia, porque suena robótico.
- Añadir aviso/log visible cuando `edge-tts` falle.

## Overlay

- Mantener animación continua durante consultas largas.
- Considerar mostrar estados: escuchando / procesando / respondiendo / cancelado.

## Reconocimiento

- Ampliar gramática wake word con frases frecuentes.
- Mejorar detección de comandos en la misma frase: “Oye Jarvis, haz X”.
- Reducir falsos positivos de “oye”.

## Organización

- Convertir esta carpeta en repo Git local cuando Leo lo autorice.
- Crear script `sync-from-system.sh` para copiar scripts reales hacia esta carpeta.
- Crear script `install-to-system.sh` con confirmación para publicar cambios desde esta carpeta a `~/.local/bin/`.
