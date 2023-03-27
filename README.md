# c3mapview

Simple Docker setup to render tiles from a map in SVG or PNG format and display
them in a simple web interface for event maps.

## How to use

Place the map in this directory as `map.svg` or `map.png` and run

    docker-compose up -d

The resulting container starts a simple web server that displays the rendered
tiles in a nice map view similar to OpenStreetMap etc. on port 9876.

You may wish to adapt `build-tiles.sh`, `style.css` and `main.js` according to
your needs, especially with regard to the DPI that determine the resulting image
size and the background color.

Please note that the Inkscape installation used inside the container does not
know any fonts, so either convert all text to paths or install the needed fonts
via apk in the `Dockerfile`.

## Build tricks

If the original image is really big and the server you are deploying to does not
have a lot of resources, building in place might be a bad idea. You can build
locally like this:

    docker build --target builder --tag tmp .

Then, create a container and extract the tiles:

    export CONTAINER=$(docker create tmp)
    docker cp $CONTAINER:/build/tiles/ .

After you have extracted the tiles, you can delete the temporary container and
image:

    docker rm $CONTAINER
    docker rmi tmp

The build script will pick up an existing `tiles` directory and skip the build
process.
