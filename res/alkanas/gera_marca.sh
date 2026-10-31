#!/bin/bash
# ----------------------------------------------------------------------------
# Gera os ícones e logos do Alkanas Suporte a partir dos SVGs desta pasta
# (cópias de goodfood/_ASSETS) e grava por cima dos arquivos do RustDesk:
#   res/icon.ico, res/tray-icon.ico, res/icon.png
#   flutter/windows/runner/resources/app_icon.ico
#   flutter/assets/icon.ico, icon.png, logo_light.png, logo_dark.png
#
# icone.svg            -> rosto escuro; vai sobre um quadrado branco arredondado
#                         para ficar legível na barra de tarefas clara ou escura
# icone.svg + logo-texto-escuro.svg              -> logo_light.png (tema claro)
# icone-rosto-branco.svg + logo-texto-branco.svg -> logo_dark.png  (tema escuro)
#
# Requer macOS (sips), Google Chrome e python3.
# ----------------------------------------------------------------------------
set -euo pipefail

AQUI="$(cd "$(dirname "$0")" && pwd)"
RAIZ="$(cd "$AQUI/../.." && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || { echo "❌ Google Chrome não encontrado"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# render <html> <largura> <altura> <saida.png>
render() {
    "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
        --default-background-color=00000000 --force-device-scale-factor=1 \
        --window-size="$2,$3" --screenshot="$4" "file://$1" >/dev/null 2>&1
    [ -s "$4" ] || { echo "❌ Chrome não gerou $4"; exit 1; }
}

cat > "$TMP/icone.html" <<EOF
<html><body style="margin:0;background:transparent">
<div style="width:1024px;height:1024px;box-sizing:border-box;padding:96px;
            background:#fff;border-radius:200px;display:flex">
  <img src="file://$AQUI/icone.svg" style="width:100%;height:100%;object-fit:contain">
</div></body></html>
EOF
render "$TMP/icone.html" 1024 1024 "$TMP/icone-1024.png"

for lado in 16 24 32 48 64 128 256; do
    sips -z $lado $lado "$TMP/icone-1024.png" --out "$TMP/icone-$lado.png" >/dev/null
done

# Mascote + texto, sem sobra lateral: o app limita a logo a 300x60 e não centraliza.
# Proporções dos SVGs: mascote 342x370, texto 407x78.
logo() {
    cat > "$TMP/logo.html" <<EOF
<html><body style="margin:0;background:transparent">
<div style="width:571px;height:120px;display:flex;align-items:center;gap:22px">
  <img src="file://$AQUI/$1" style="width:111px;height:120px;display:block">
  <img src="file://$AQUI/$2" style="width:438px;height:84px;display:block">
</div></body></html>
EOF
    render "$TMP/logo.html" 571 120 "$3"
}
logo icone.svg logo-texto-escuro.svg "$RAIZ/flutter/assets/logo_light.png"
logo icone-rosto-branco.svg logo-texto-branco.svg "$RAIZ/flutter/assets/logo_dark.png"

ICO="python3 -I $AQUI/ico.py"
p() { for l in "$@"; do printf '%s ' "$TMP/icone-$l.png"; done; }

$ICO "$RAIZ/res/icon.ico" $(p 16 24 32 48 64 128 256)
$ICO "$RAIZ/flutter/assets/icon.ico" $(p 16 24 32 48 64 128 256)
$ICO "$RAIZ/flutter/windows/runner/resources/app_icon.ico" $(p 16 24 32 48 64 128 256)
$ICO "$RAIZ/res/tray-icon.ico" $(p 16 24 32)
cp "$TMP/icone-1024.png" "$RAIZ/res/icon.png"
cp "$TMP/icone-256.png" "$RAIZ/flutter/assets/icon.png"

echo "✅ Ícones e logos do Alkanas Suporte gerados."
