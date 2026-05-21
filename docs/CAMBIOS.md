# CAMBIOS — revisión 2026-05-20

Revisión completa del repositorio. Cada bug y mejora referencia el archivo afectado.

---

## jarvis-escucha

### Bugs corregidos
- **Variable muerta `REQUIRE_VOSK_OYE`** — estaba definida como `True` pero nunca se consultaba.
  Ahora implementa confirmación secundaria real: cuando OpenWakeWord dispara con score
  entre `THRESHOLD` y `HIGH_THRESHOLD`, espera que Vosk haya reconocido el wake word
  en los últimos ~480 ms antes de activar. Score ≥ `HIGH_THRESHOLD` (0.85) dispara de inmediato.
- **Código muerto `_ = SPEAKING_LOCK.exists()`** — resultado descartado, eliminado.
- **Auto-activación durante TTS** — OpenWakeWord seguía procesando audio mientras Jarvis
  hablaba, pudiendo activarse con su propia voz. Ahora OWW se suspende mientras exista
  `speaking.lock`; los stop commands (Vosk) siguen funcionando durante TTS.
- **Spin loop cuando arecord muere silenciosamente** — `proc.stdout.read()` devolvía `b''`
  en bucle quemando CPU. Ahora hay un `sleep(0.03)` y reinicio automático del proceso.

### Mejoras
- `deque(vosk_history)` guarda los últimos textos de Vosk para la confirmación diferida de OWW.
- Nuevas palabras de stop sin nombre: `basta`, `ya basta`, `ya para`, `olvida`, `olvidalo`.
- Log más descriptivo al activar (`oww+vosk`, `oww+vosk (diferido)`, etc.).
- `OPENWAKEWORD_HIGH_THRESHOLD = 0.85` como nueva constante separada.

---

## jarvis-voz

### Bugs corregidos
- **Lectura bloqueante de arecord** — `proc.stdout.read(chunk_bytes)` podía bloquearse
  indefinidamente si arecord se colgaba. El script Python embebido usa ahora `select()`
  con timeout de 0.2 s, y detecta si el proceso murió para salir limpiamente.
- **`needs_followup()` demasiado agresiva** — cualquier `?` en la respuesta activaba
  seguimiento (p. ej. `"¿Entendido?"`). Ahora solo analiza la **última oración** del texto.
- **Cancel flag tardío en el loop de seguimiento** — se agregó verificación de `CANCEL_FLAG`
  antes de consultar al agente y antes de escuchar el followup.
- **`beep_ready` fallaba silenciosamente** — `canberra-gtk-play -i bell` no siempre existe.
  Ahora prueba `message-new-instant`, `bell` y `audio-bell` en orden.

### Mejoras
- `CAPTURE_VOLUME` ahora se puede sobreescribir con la variable de entorno
  `JARVIS_CAPTURE_VOLUME=40%` sin editar el script.
- El patrón de apertura de apps también captura `busca`, `buscar`, `googlea`, `google`
  como verbos → se reenvía a `jarvis-open-app` sin pasar por el agente.
- Los verbos de proyector `súbele` / `bájale` (sin "volumen") ahora disparan
  `volup` / `voldown` del Freestyle.
- Nuevas palabras de stop local: `basta`, `olvida`, `olvidalo`.
- Soporte del nuevo intent `search_youtube` del proyector.

---

## jarvis-open-app

### Bugs corregidos
- **Match parcial incorrecto en `sites`** — `"key in target or target in key"` hacía que
  `target = "am"` abriera Amazon (`"am" in "amazon"`). Reemplazado por `site_match()` que
  exige coincidencia exacta o palabra completa con regex `(^|\s)key($|\s)`.
- El match de carpetas no reconocía `"la carpeta X"`. Añadido `f'la carpeta {key}'` a la lista.
- `"la terminal"` no abría la Terminal. Añadido como alias explícito.

### Mejoras — sitios nuevos
`claude` / `claude ai`, `twitter` / `x`, `reddit`, `linkedin`,
`maps` / `google maps`, `traductor` / `translate` / `google translate`,
`meet` / `google meet`, `calendar` / `google calendar` / `calendario google`.

### Mejoras — apps nuevas
`vlc` / `reproductor`, `gimp`, `inkscape`, `impress` / `presentacion`, `explorador`.

### Mejoras — búsqueda
El verbo `googlea` y `google` también activan la ruta de búsqueda web.
El motor `maps` tiene su propia URL de búsqueda (`google.com/maps/search/…`).
El dict de sites se ordena por longitud de clave descendente para dar prioridad
a claves más específicas (`"google maps"` antes que `"maps"`).

---

## jarvis-intent

### Bugs corregidos
- Patrones de `volume_up`/`volume_down` del proyector requerían la palabra "volumen"
  explícita. Ahora `"súbele"` y `"bájale"` solos también disparan el intent.
- `device_words` no incluía `"proyectar"`, `"proyección"`, `"frestyle"`, `"frestil"`.

### Mejoras
- Nuevas palabras de stop: `basta`, `ya basta`, `ya para`, `espera`, `hasta aqui`,
  `olvida`, `calla`.
- Nuevo intent `search_youtube` para Freestyle: si el usuario dice
  "busca X en el cine" o "pon X en el proyector", devuelve `action=search_youtube`
  con `args.query`.
- Apps nuevas en el proyector: `max` / `hbo` / `hbo max`, `paramount+`.
- `t2` normaliza también `"frestyle"` → `"freestyle"` y `"the freestyle"` → `"freestyle"`.

---

## jarvis-say

### Bugs corregidos
- Sin reintentos: si `edge-tts` fallaba por un error de red transitorio (timeout, DNS),
  se caía directamente al fallback de `spd-say`. Ahora reintenta hasta 3 veces con
  espera incremental (1 s, 2 s).
- `SPEAKING_LOCK` podía quedar huérfano si `jarvis-stop` mataba el proceso antes de que
  el trap `EXIT` se ejecutara. Ahora el lock contiene el PID del proceso y solo se borra
  si el PID coincide.

---

## jarvis-stop

### Bugs corregidos
- **`pkill -f 'spd-say .*'` demasiado amplio** — mataba cualquier instancia de spd-say
  del sistema (no solo la de Jarvis). Ahora se verifica el PID en `speaking.lock` y
  se comprueba que el proceso sea efectivamente uno de los esperados antes de matarlo.
- No cancelaba instancias de `jarvis-voz` en espera del agente. Ahora sí.

### Mejoras
- `pkill` de `aplay` ahora apunta exactamente al directorio TTS de Jarvis:
  `aplay -q ${TTS_DIR}/jarvis-*.wav`.
- Limpia archivos `*.wav` y `*.mp3` temporales del directorio TTS.
- Orden de cancelación más coherente: flag → TTS → openclaw → jarvis-voz → spd-say global → limpieza.

---

## jarvis-freestyle

### Mejoras
- **Reintentos en WebSocket** — `send_key()` y `launch_app_ws()` reintentan hasta 3 veces
  con 1.5 s de espera si la conexión falla.
- **Guarda preferencia de canal** — tras `pair` exitoso, persiste `secure` y `port`
  en `freestyle.json` para que futuras conexiones no tengan que probar ambas opciones.
- **Nuevo subcomando `search <query>`** — abre YouTube en el proyector y prepara
  una búsqueda. Requiere que `jarvis-intent` emita `action=search_youtube`.
- Apps nuevas: `max` / `hbo`, `paramount+`.
- `WS_RETRY_ATTEMPTS` y `WS_RETRY_DELAY` son constantes fácilmente ajustables.
