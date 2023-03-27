#!/bin/sh

DPI=300
BACKGROUND="white"

if [ -f "map.svg" ] ; then
  echo -n "Exporting map.svg to png... "
  inkscape map.svg \
    --export-area-page \
    --export-dpi=$DPI \
    --export-type=png \
    --export-filename=map.png 2> /dev/null
  echo "done"
fi

if [ -f "map.png" ] ; then
  echo -n "Resizing map.png to a square... "
  DIMENSIONS="$(identify -format "%[fx:w],%[fx:h]" map.png)"
  SIZE="$(python3 -c "print(2**(max($DIMENSIONS)-1).bit_length())")"
  convert map.png \
    -background $BACKGROUND \
    -alpha remove \
    -compose Copy \
    -gravity center \
    -resize ${SIZE}x${SIZE} \
    -extent ${SIZE}x${SIZE} \
    map_sq.png
  echo "done"
fi

if [ ! -f "map_sq.png" ] ; then
  echo "No map found. Please make sure that you supply either map.svg, map.png or map_sq.png!"
  exit 1
fi

echo -n "Converting map_sq.png into vrt... "
gdal_translate -q -of vrt map_sq.png map_sq.vrt
echo "done"

echo -n "Rendering tiles from map_sq.vrt... "
gdal2tiles.py -q -w none -p raster map_sq.vrt tiles
echo "done"
