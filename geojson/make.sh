#!/bin/bash
# mapshaperを使って以下の処理を行う
# - shapeファイルをgeojsonに変換する
# - ジオメトリエラーを修正する
# - XMLコード表のコードをフィールドに追加する
# - 簡素化と小さなポリゴンの除去を行いファイルサイズを小さくする

# directories settings
SCRIPTDIR=$(
  cd $(dirname $0)
  pwd
)
GEODIR=${SCRIPTDIR}
MSCMD="npx mapshaper"
JMADIR=${SCRIPTDIR}/../jma
CODEDIR=${SCRIPTDIR}/../jmacode

# simplify options
SIMPLIFY_PERCENT="5%"
SIMPLIFY_MINAREA="1000m2"

JMASHP=${JMADIR}/AreaInformationCity_weather_GIS.shp
JMACODE=${CODEDIR}/jmacode.csv

rm -f ${GEODIR}/*.geojson

# geojsonに変換
echo -e "\e[1;33mConvert shape to geoJSON...\e[0;m"
$MSCMD -i ${JMASHP} encoding="utf-8" -filter-fields regioncode -clean -o ${GEODIR}/tmp.geojson force

# 簡素化
echo -e "\e[1;33mSimplify geoJSON...\e[0;m"
$MSCMD ${GEODIR}/tmp.geojson -simplify ${SIMPLIFY_PERCENT} -o ${GEODIR}/tmp.geojson force
$MSCMD -i ${GEODIR}/tmp.geojson -filter-slivers min-area=${SIMPLIFY_MINAREA} -o ${GEODIR}/tmp.geojson force
$MSCMD -i ${GEODIR}/tmp.geojson -clean -o ${GEODIR}/tmp.geojson force

# フィールドを追加
echo -e "\e[1;33mJoin xml code table to fields...\e[0;m"
$MSCMD ${GEODIR}/tmp.geojson -each 'citycode=regioncode, delete regioncode' -o ${GEODIR}/tmp.geojson force
$MSCMD ${GEODIR}/tmp.geojson -join ${JMACODE} keys=citycode,citycode string-fields=* -o ${GEODIR}/city.geojson force

# コードレベルでまとめる
echo -e "\e[1;33mAggregate groups of features using a code field...\e[0;m"
$MSCMD ${GEODIR}/city.geojson -dissolve matomeareacode copy-fields=prefcode,prefname,firstareacode,firstareaneme,matomeareaname -o ${GEODIR}/matomearea.geojson force
$MSCMD ${GEODIR}/city.geojson -dissolve firstareacode copy-fields=prefcode,prefname,firsareaneme -o ${GEODIR}/firstarea.geojson force
$MSCMD ${GEODIR}/city.geojson -dissolve prefcode copy-fields=prefname -o ${GEODIR}/pref.geojson force

rm ${GEODIR}/tmp.geojson
