#!/bin/bash
# tippecanoeを使ってgeoJSONをベクトルタイルに変換する
set -eu

# directories settings
PROJECT_DIR=$(cd $(dirname $0)/.. && pwd)

cd ${PROJECT_DIR}

ATTRIBUTION='<a href="https://www.data.jma.go.jp/developer/gis.html">気象庁「予報区等GISデータ」を加工して作成</a>'

rm -f tiles/*.pmtiles
rm -f tiles/*.mbtiles

for layer in city matomearea firstarea pref; do
    case $layer in
    "city")
        minzoom=7
        maxzoom=14
        ;;
    "matomearea")
        minzoom=7
        maxzoom=14
        ;;
    "firstarea")
        minzoom=5
        maxzoom=14
        ;;
    "pref")
        minzoom=4
        maxzoom=14
        ;;
    esac

    tippecanoe --force \
        --generate-ids \
        --layer="${layer}" --maximum-zoom=${maxzoom} --minimum-zoom=${minzoom} \
        -o tiles/${layer}.mbtiles \
        geojson/${layer}.geojson
done

cd tiles

tile-join --force --name="jmagis" --description="JMA GIS vector tiles" --attribution="${ATTRIBUTION}" \
    --output-to-directory=${TILEDIR}/zxy --no-tile-compression \
    pref.mbtiles firstarea.mbtiles matomearea.mbtiles city.mbtiles
rm -f pref.mbtiles firstarea.mbtiles matomearea.mbtiles city.mbtiles
