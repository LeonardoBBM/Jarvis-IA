# Instalación local

Los scripts activos viven en `~/.local/bin/`. Para instalar una versión nueva:

```bash
bash install-mejoras.sh --dry-run
bash install-mejoras.sh
systemctl --user restart jarvis-escucha.service
systemctl --user status jarvis-escucha.service --no-pager
```

El instalador crea backups automáticos en:

`~/.local/bin/backups/jarvis-YYYYMMDD-HHMMSS/`

Última instalación aplicada en esta máquina:

- Backup: `~/.local/bin/backups/jarvis-20260520-203222/`
- Servicio reiniciado correctamente.
