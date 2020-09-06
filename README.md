## JMA-GIS

気象庁公開の予報区データを加工したベクトルタイル

## Data

### geojson

| ファイル名           | 区域                   |
| -------------------- | ---------------------- |
| pref.geojson         | 府県予報区             |
| firstarea.geojson    | 一次細分区             |
| municipality.geojson | 市町村等をまとめた地域 |
| city.geojson         | 二次細分区             |

### fields

| フィールド名        | 説明                             | pref | firstarea | municipality | city |
| ------------------- | -------------------------------- | ---- | --------- | ------------ | ---- |
| prefcode            | 府県予報区コード                 | ○    | ×         | ×            | ×    |
| prefname            | 府県予報区名                     | ○    | ×         | ×            | ×    |
| prefname_kn         | 府県予報区名（かな）             | ○    | ×         | ×            | ×    |
| firstareacode       | 一次細分区コード                 | ○    | ○         | ×            | ×    |
| firstareaname       | 一次細分区名                     | ○    | ○         | ×            | ×    |
| firstareaname_kn    | 一次細分区名（かな）             | ○    | ○         | ×            | ×    |
| municipalitycode    | 市町村等をまとめた地域コード     | ○    | ○         | ○            | ○    | × |
| municipalityname    | 市町村等をまとめた地域名         | ○    | ○         | ○            | ○    | × |
| municipalityname_kn | 市町村等をまとめた地域名（かな） | ○    | ○         | ○            | ○    | × |
| citycode            | 二次細分区コード                 | ○    | ○         | ○            | ○    | ○ |
| cityname            | 二次細分区名                     | ○    | ○         | ○            | ○    | ○ |
| cityname_kn         | 二次細分区名（かな）             | ○    | ○         | ○            | ○    | ○ |

## Make

必要なパッケージをダウンロードする．

```
npm install
pipenv install
```

気象庁データをダウンロードする．`jma/get.sh` の `XMLZIP`，`GISZIP` を最新のファイル名に変更する．

```
# ./jma
./get.sh
```

XML コードテーブル表から csv ファイルを作成する．

```
# ./jmacode
python jmacode.py
```

geoJSON ファイルを作成する．[mapshaper](https://github.com/mbloch/mapshaper)を使用してポリゴンの簡素化，統合をしている．

```
# ./geojson
./make.sh
```

## Refference

このデータの作成には気象庁公開のデータを利用しています．

- [予報区等 GIS データ](https://www.data.jma.go.jp/developer/gis.html)の GIS データを加工して作成．
- [気象庁防災情報 XML フォーマット　技術資料](http://xml.kishou.go.jp/tec_material.html)の XML コード表を加工して作成．
