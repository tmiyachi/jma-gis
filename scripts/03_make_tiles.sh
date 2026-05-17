#!/bin/bash
# tippecanoeを使ってgeoJSONをベクトルタイルに変換する
set -eu

# directories settings
PROJECT_DIR=$(cd $(dirname $0)/.. && pwd)

cd ${PROJECT_DIR}

ATTRIBUTION='<a href="https://www.data.jma.go.jp/developer/gis.html">気象庁「予報区等GISデータ」を加工して作成</a>'

rm -f tiles/*.pmtiles

tippecanoe --force \
  --name="jmagis" --description="JMA GIS vector tiles" --attribution="${ATTRIBUTION}" \
  --generate-ids \
  --no-progress-indicator \
  --maximum-zoom=14 --minimum-zoom=4 \
  -o tiles/jma-gis.pmtiles \
  geojson/pref.geojson geojson/firstarea.geojson geojson/matomearea.geojson geojson/city.geojson
