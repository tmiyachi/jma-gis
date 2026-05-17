#!/bin/bash
# mapshaperを使って以下の処理を行う
# - shapeファイルをgeojsonに変換する
# - ジオメトリエラーを修正する
# - XMLコード表のコードをフィールドに追加する
# - 簡素化と小さなポリゴンの除去を行いファイルサイズを小さくする
set -eu

# directories settings
PROJECT_DIR=$(cd $(dirname $0)/.. && pwd)
MSCMD="npx mapshaper"

cd ${PROJECT_DIR}

# simplify options
SIMPLIFY_PERCENT="5%"
SIMPLIFY_MINAREA="1000m2"

JMASHP=jma/AreaInformationCity_weather_GIS.shp
JMACODE=jmacode/jmacode.csv

rm -f geojson/*.geojson

# geojsonに変換
echo -e "\e[1;33mConvert shape to geoJSON...\e[0;m"
$MSCMD -i ${JMASHP} encoding="utf-8" -filter-fields regioncode -clean -o geojson/tmp.geojson force

# 簡素化
echo -e "\e[1;33mSimplify geoJSON...\e[0;m"
$MSCMD geojson/tmp.geojson -simplify ${SIMPLIFY_PERCENT} -o geojson/tmp.geojson force
$MSCMD -i geojson/tmp.geojson -filter-slivers min-area=${SIMPLIFY_MINAREA} -o geojson/tmp.geojson force
$MSCMD -i geojson/tmp.geojson -clean -o geojson/tmp.geojson force

# フィールドを追加
echo -e "\e[1;33mJoin xml code table to fields...\e[0;m"
$MSCMD geojson/tmp.geojson -each 'citycode=regioncode, delete regioncode' -o geojson/tmp.geojson force
$MSCMD geojson/tmp.geojson -join ${JMACODE} keys=citycode,citycode string-fields=* -o geojson/city.geojson force

# コードレベルでまとめる
echo -e "\e[1;33mAggregate groups of features using a code field...\e[0;m"
$MSCMD geojson/city.geojson -dissolve matomeareacode copy-fields=prefcode,prefname,firstareacode,firstareaneme,matomeareaname -o geojson/matomearea.geojson force
$MSCMD geojson/city.geojson -dissolve firstareacode copy-fields=prefcode,prefname,firsareaneme -o geojson/firstarea.geojson force
$MSCMD geojson/city.geojson -dissolve prefcode copy-fields=prefname -o geojson/pref.geojson force

rm geojson/tmp.geojson
