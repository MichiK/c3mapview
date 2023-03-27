// Configuration - these probably have to be adapted to your needs

// 0 is usually fine
const minZoom = 0;

// 6 works well for an image of 16384x1683 pixel
const maxZoom = 6;

// initial coordinates and zoom level if noting is given via the URL
// the center is at [0, 0]
const defaultCenter = [0, 0];
const defaultZoom = 3;

// maximum bounds of the map
// use this to restrict the user to a certain area of the map
// the format is [[min_x, min_y], [max_x, max_y]]
// [-128, -128] and [128, 128] is the full image
// the center is at [0, 0]
const maxBounds = [[-128, -128], [128, 128]];

const mapOptions = {
  attributionControl: true,
  minZoom: minZoom,
  maxZoom: maxZoom,
  maxBounds: maxBounds,
};

const mapObj = L.map("map", mapOptions);

L.tileLayer(`tiles/{z}/{x}/{y}.png`, {
  minZoom: minZoom,
  maxZoom: maxZoom,
  bounds: maxBounds,
  tms: true,
  noWrap: true,
}).addTo(mapObj);

const hash = location.hash.substr(1).split('/');

if (hash.length === 3) {
  mapObj.setView([hash[0], hash[1]], hash[2]);
} else if (hash.length === 6 && hash[3] === "m") {
  mapObj.setView([hash[4], hash[5]], hash[2]);
  L.marker([hash[4], hash[5]]).addTo(mapObj);
} else {
  mapObj.setView(defaultCenter, defaultZoom);
}

const updateHash = function() {
  const oldHash = location.hash.substr(1).split('/');
  const mapLat = mapObj.getCenter().lat.toPrecision(7);
  const mapLng = mapObj.getCenter().lng.toPrecision(7);
  const mapZoom = mapObj.getZoom();
  if (oldHash.length >= 3) {
    oldHash[0] = mapLat;
    oldHash[1] = mapLng;
    oldHash[2] = mapZoom;
    location.hash = oldHash.join('/');
  } else {
    location.hash = `#${mapLat}/${mapLng}/${mapZoom}`;
  }
}

mapObj.on('moveend', updateHash);
mapObj.on('zoomend', updateHash);

const showUrl = function(ev) {
  const baseUrl = location.href.replace(location.hash,"") 
  const evLat = ev.latlng.lat.toPrecision(7);
  const evLng = ev.latlng.lng.toPrecision(7);
  const mapZoom = mapObj.getZoom();
  console.log(
    "To create a link with a marker at this coordinates, please use the following URL: " +
    `${baseUrl}#${evLat}/${evLng}/${mapZoom}/m/${evLat}/${evLng}`
  );
}

mapObj.on('click', showUrl);
