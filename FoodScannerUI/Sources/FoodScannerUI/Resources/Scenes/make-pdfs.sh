#!/bin/sh
# Convertit les saynetes SVG en PDF vectoriels pour l'asset catalog.
# Prerequis : brew install librsvg
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
ASSETS="$DIR/../FoodScannerUI.xcassets/Scenes"
conv() { rsvg-convert -f pdf -o "$2" "$1"; echo "-> $2"; }
conv "$DIR/scene-laboratory-spring.svg" "$ASSETS/scene-laboratory.imageset/scene-laboratory.pdf"
conv "$DIR/scene-picnic.svg"            "$ASSETS/scene-picnic.imageset/scene-picnic.pdf"
conv "$DIR/scene-chalet.svg"            "$ASSETS/scene-chalet.imageset/scene-chalet.pdf"
echo "Variante sombre du labo : scene-laboratory-autumn.svg, a ajouter en Dark Appearance dans Xcode."
