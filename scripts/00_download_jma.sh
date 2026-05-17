#!/bin/bash
# 気象庁が公開しているXMLコード定義ファイルとGISファイルをダウンロードする．
#
# 気象庁防災情報XMLフォーマット 技術資料
#  http://xml.kishou.go.jp/tec_material.html
# 予報区等GISデータの一覧
#  https://www.data.jma.go.jp/developer/gis.html
# から最新の「XML個別コード表」と「市町村等（気象警報等）」のzipファイル名を確認して
# XMLZIPとGISZIPに指定する．
set -eu

PROJECT_DIR=$(cd $(dirname $0)/.. && pwd)

cd ${PROJECT_DIR}

# 最新ファイル名取得
python scripts/00_lookup_latest_jma.py

# GISファイル取得・解凍
cd jma
# 気象庁公開のXML個別コード表のzipファイル名
XMLZIP=$(cat latest_xmlzip.txt)
# 気象庁公開の市町村等（気象警報等）GISデータのzipファイル名
GISZIP=$(cat latest_giszip.txt)

wget -N http://xml.kishou.go.jp/${XMLZIP}
unzip -p ${XMLZIP} '*AreaInformationCity-AreaForecastLocalM*xls' >AreaInformationCity.xls

wget -N https://www.data.jma.go.jp/developer/gis/${GISZIP}
rm AreaInformationCity_weather_GIS.*

unzip -p ${GISZIP} '*.shp' >AreaInformationCity_weather_GIS.shp
unzip -p ${GISZIP} '*.dbf' >AreaInformationCity_weather_GIS.dbf
unzip -p ${GISZIP} '*.shx' >AreaInformationCity_weather_GIS.shx
