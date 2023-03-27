FROM alpine AS builder

RUN apk update && apk add \
       gdal-tools \
       imagemagick \
       inkscape \
       npm \
       python3

WORKDIR /build

RUN npm install leaflet

COPY . /build/

RUN ./build-tiles.sh

FROM nginx:alpine

COPY --from=builder \
  /build/tiles/ \
  /usr/share/nginx/html/tiles/

COPY --from=builder \
  /build/node_modules/leaflet/dist/leaflet.* \
  /usr/share/nginx/html/leaflet/

COPY --from=builder \
  /build/node_modules/leaflet/dist/images/ \
  /usr/share/nginx/html/leaflet/images/

COPY \
  index.html main.js style.css \
  /usr/share/nginx/html/
