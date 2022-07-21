#!/bin/bash

APIKEY={APIKEY}
#Replace {APIKEY} with your own from https://www.geoapify.com/
if [ $APIKEY == {APIKEY} ]; then
	echo "No API key found. Visit https://www.geoapify.com to get an API key"
	exit
fi
if [ ! $# == 1 ]; then
  echo "Usage: $0 ZIPCODE, eg. $0 95747"
  exit
fi
url=$'https://api.geoapify.com/v1/geocode/search?text='$1'&lang=en&limit=10&type=postcode&filter=countrycode:us&apiKey='$APIKEY''
lat=$(curl -s "$url" | jq -r '.features[].properties.lat')
lon=$(curl -s "$url" | jq -r '.features[].properties.lon')
lat4=$(bc <<< "scale=4;$lat/1")
lon4=$(bc <<< "scale=4;$lon/1")
latlon=$(echo $lat4 | xargs),$(echo $lon4 | xargs)
point=$(curl -s "https://api.weather.gov/points/$latlon" | jq -r '.properties["forecast"]')
curl -s "${point}" | jq -r '.properties.periods[] | "\(.name):\(.temperature):\(.shortForecast)"' | awk -F':' '{ printf "%-16s  %d  %-60s\n", $1, $2, $3 }'
