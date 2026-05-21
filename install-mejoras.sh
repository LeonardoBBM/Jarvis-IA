#!/usr/bin/env bash
# install-mejoras.sh — copia los scripts mejorados a ~/.local/bin con backup automático.
# Uso: bash install-mejoras.sh [--dry-run]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"
TARGET_DIR="$HOME/.local/bin"
BACKUP_DIR="$HOME/.local/bin/backups/jarvis-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

SCRIPTS=(
  jarvis-escucha
  jarvis-voz
  jarvis-open-app
  jarvis-intent
  jarvis-say
  jarvis-stop
  jarvis-freestyle
)

echo "=== Instalador de mejoras Jarvis ==="
[[ "$DRY_RUN" == "1" ]] && echo "(DRY RUN — no se escribirá nada)"
echo ""

# Crear backup de los scripts actuales.
if [[ "$DRY_RUN" == "0" ]]; then
  mkdir -p "$BACKUP_DIR"
  for script in "${SCRIPTS[@]}"; do
    src="$TARGET_DIR/$script"
    if [[ -f "$src" ]]; then
      cp "$src" "$BACKUP_DIR/$script.bak"
      echo "  Backup: $script → $BACKUP_DIR/"
    fi
  done
  echo ""
fi

# Copiar scripts nuevos.
for script in "${SCRIPTS[@]}"; do
  src="$SCRIPTS_DIR/$script"
  dst="$TARGET_DIR/$script"
  if [[ ! -f "$src" ]]; then
    echo "  SKIP (no encontrado): $src"
    continue
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "  [dry] cp $src → $dst"
  else
    cp "$src" "$dst"
    chmod +x "$dst"
    echo "  ✓ $script"
  fi
done

echo ""
if [[ "$DRY_RUN" == "0" ]]; then
  echo "Listo. Reinicia el servicio para aplicar cambios:"
  echo "  systemctl --user restart jarvis-escucha.service"
  echo ""
  echo "Para verificar:"
  echo "  systemctl --user status jarvis-escucha.service --no-pager"
  echo "  journalctl --user -u jarvis-escucha.service -n 40 --no-pager"
  echo ""
  echo "Para revertir si algo falla:"
  echo "  cp $BACKUP_DIR/*.bak ~/.local/bin/"
  echo "  (y quitar el .bak del nombre)"
fi
