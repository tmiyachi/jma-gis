#!/bin/bash
# tippecanoeを使ってgeoJSONをベクトルタイルに変換する

# directories settings
SCRIPTDIR=$(cd $(dirname $0); pwd)
TILEDIR=${SCRIPTDIR}
GEODIR=${SCRIPTDIR}/../geojson

ATTRIBUTION='<a href="https://www.data.jma.go.jp/developer/gis.html">気象庁「予報区等GISデータ」を加工して作成</a>'

rm -f ${TILEDIR}/*.mbtiles
rm -r -f ${TILEDIR}/zxy

for layer in city municipality firstarea pref; do
    case $layer in
        "city") minzoom=7; maxzoom=10; id=citicode; ;;
        "municipality") minzoom=7; maxzoom=10; id=municode; ;;
        "firstarea") minzoom=5; maxzoom=10; id=firstareacode; ;;
        "pref") minzoom=4; maxzoom=10; id=prefcode; ;;
    esac
    tippecanoe --force \
    --use-attribute-for-id=${id} --convert-stringified-ids-to-numbers \
    --layer="${layer}" --maximum-zoom=${maxzoom} --minimum-zoom=${minzoom} -o ${TILEDIR}/${layer}.mbtiles \
    ${GEODIR}/${layer}.geojson
done
tile-join --force --name="jmagis" --description="JMA GIS ector tiles" --attribution="${ATTRIBUTION}" \
    --output-to-directory=${TILEDIR}/zxy --no-tile-compression \
    pref.mbtiles firstarea.mbtiles municipality.mbtiles city.mbtiles
rm -f pref.mbtiles firstarea.mbtiles municipality.mbtiles city.mbtiles
