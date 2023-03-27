#!/bin/sh

DPI=200
BACKGROUND="white"

# The export area should be either 'page' or 'drawing'
EXPORT_AREA="drawing"

svg_to_png() {
  echo -n "Exporting map.svg to png... "
  inkscape map.svg \
    --export-area-$EXPORT_AREA \
    --export-dpi=$DPI \
    --export-type=png \
    --export-filename=map.png 2> /dev/null
  echo "done"
}

png_to_square() {
  echo -n "Resizing map.png to a square... "
  DIMENSIONS="$(identify -format "%[fx:w],%[fx:h]" map.png)"
  SIZE="$(python3 -c "print(2**(max($DIMENSIONS)-1).bit_length())")"
  echo -n "dimensions will be ${SIZE}x${SIZE} pixels... "
  convert map.png \
    -background $BACKGROUND \
    -alpha remove \
    -compose Copy \
    -gravity center \
    -resize ${SIZE}x${SIZE} \
    -extent ${SIZE}x${SIZE} \
    map_sq.png
  echo "done"
}

square_to_vrt() {
  echo -n "Converting map_sq.png into vrt... "
  gdal_translate -q -of vrt map_sq.png map_sq.vrt
  echo "done"
}

vrt_to_tiles() {
  echo -n "Rendering tiles from map_sq.vrt... "
  gdal2tiles.py -q -w none -p raster map_sq.vrt tiles
  echo "done"
}

if [ -d "tiles" ] ; then
  echo "Found existing tiles, skipping build"
  exit 0
fi

if [ -f "map_sq.vrt" ] ; then
  vrt_to_tiles
  exit 0
fi

if [ -f "map_sq.png" ] ; then
  square_to_vrt
  vrt_to_tiles
  exit 0
fi

if [ -f "map.png" ] ; then
  png_to_square
  square_to_vrt
  vrt_to_tiles
  exit 0
fi

if [ -f "map.svg" ] ; then
  svg_to_png
  png_to_square
  square_to_vrt
  vrt_to_tiles
  exit 0
fi

echo "No map found. Please make sure that you supply either map.svg, map.png or map_sq.png!"
exit 1
