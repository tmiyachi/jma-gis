#!/bin/bash
# 気象庁が公開しているXMLコード定義ファイルとGISファイルをダウンロードする．
#
# 気象庁防災情報XMLフォーマット 技術資料
#  http://xml.kishou.go.jp/tec_material.html
# 予報区等GISデータの一覧
#  https://www.data.jma.go.jp/developer/gis.html
# から最新の「XML個別コード表」と「市町村等（気象警報等）」のzipファイル名を確認して
# XMLZIPとGISZIPに指定する．

# 気象庁公開のXML個別コード表のzipファイル名
XMLZIP=jmaxml_20240418_Code.zip
# 気象庁公開の市町村等（気象警報等）GISデータのzipファイル名
GISZIP=20230517_AreaInformationCity_weather_GIS.zip

aria2c http://xml.kishou.go.jp/${XMLZIP}
unzip -p ${XMLZIP} '*AreaInformationCity-AreaForecastLocalM*xls' >AreaInformationCity.xls
rm ${XMLZIP}

aria2c https://www.data.jma.go.jp/developer/gis/${GISZIP}
unzip -p ${GISZIP} '*.shp' >AreaInformationCity_weather_GIS.shp
unzip -p ${GISZIP} '*.dbf' >AreaInformationCity_weather_GIS.dbf
unzip -p ${GISZIP} '*.shx' >AreaInformationCity_weather_GIS.shx
rm ${GISZIP}
