# Jarvis Voz

Carpeta de proyecto para el asistente de voz local de Jarvis.

> Nota: esta carpeta es una copia organizada/documentada. Los scripts reales que ejecuta el sistema siguen viviendo en `~/.local/bin/` y el servicio systemd apunta a `~/.local/bin/jarvis-escucha`.

## Ubicaciones reales

- Scripts activos: `~/.local/bin/`
- Servicio systemd: `~/.config/systemd/user/jarvis-escucha.service`
- Configuración Jarvis/proyector: `~/.config/jarvis/`
- Modelo Vosk: `~/.local/share/oye-jarvis/`
- Estado temporal de voz: `/run/user/1000/jarvis-voz/`
- Cache temporal TTS: `/run/user/1000/jarvis-tts/`

## Estructura de esta carpeta

- `scripts/` — copia actual de los scripts principales.
- `config/` — solo ejemplos sanitizados. La configuración real con tokens no se versiona.
- `systemd/` — copia del servicio de escucha.
- `backups/` — no se versiona por seguridad.
- `current-state/` — snapshots de estado del servicio/runtime.
- `docs/` — notas técnicas y pendientes.

## Scripts principales

- `jarvis-escucha` — escucha wake word y dispara comandos.
- `jarvis-voz` — graba/transcribe/ejecuta comandos o consulta OpenClaw.
- `jarvis-intent` — parser rápido de intenciones locales.
- `jarvis-say` — voz Microsoft Edge TTS / Álvaro.
- `jarvis-stop` — corta voz/procesamiento.
- `jarvis-overlay` — HUD/animación visual.
- `jarvis-open-app` — abre aplicaciones/carpetas/documentos.
- `jarvis-freestyle` — controla el proyector Samsung The Freestyle.

## Comandos útiles

```bash
systemctl --user status jarvis-escucha.service --no-pager
systemctl --user restart jarvis-escucha.service
journalctl --user -u jarvis-escucha.service -n 80 --no-pager
```

Probar comando directo sin wake word:

```bash
JARVIS_PREFILLED_TEXT='pon volumen al treinta' ~/.local/bin/jarvis-voz
JARVIS_PREFILLED_TEXT='como estas' ~/.local/bin/jarvis-voz
```

## Estado de mejoras recientes

- Comandos locales ultrarrápidos para volumen, saludos y respuestas simples.
- Interrupción con “Jarvis para / detente / cállate / cancela”.
- Voz restaurada a `es-ES-AlvaroNeural`, rate `+4%`, pitch `-20Hz`.
- Overlay mantiene `processing` hasta 180s para no desaparecer mientras espera OpenAI/OpenClaw.
- Consultas OpenAI/OpenClaw usan respuesta en dos fases: primero “Lo reviso.” y después respuesta final.

## Regla de seguridad

No mover los scripts reales sin actualizar también el servicio systemd y probarlo. Preferible editar en `~/.local/bin/` con backup, y luego sincronizar copia aquí.

## Seguridad del repo

Este repositorio evita subir secretos: tokens del proyector, contraseñas, audios temporales y backups quedan fuera por `.gitignore`.
