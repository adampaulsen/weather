#!/bin/bash

APIKEY={APIKEY}
#Replace {APIKEY} with your own from https://www.geoapify.com/
if [ ! $# == 1 ]; then
  echo "Usage: $0 ZIPCODE, eg. $0 95747"
  exit
fi
url=$'https://api.geoapify.com/v1/geocode/search?text='$1'&lang=en&limit=10&type=postcode&filter=countrycode:us&apiKey='$APIKEY''
lat=$(curl -s "$url" | jq -r '.features[].properties.lat')
lon=$(curl -s "$url" | jq -r '.features[].properties.lon')
lat4=$(printf "%8.3f" "$lat")
lon4=$(printf "%8.3f" "$lon")
latlon=$(echo $lat4 | xargs),$(echo $lon4 | xargs)
pointurl="https://api.weather.gov/points/$latlon"
point=$(curl -s "$pointurl" | jq -r '.properties["forecast"]')
curl -s "${point}" | jq -r '.properties.periods[] | "\(.name):\(.temperature):\(.shortForecast)"' | awk -F':' '{ printf "%-16s  %d  %-60s\n", $1, $2, $3 }'