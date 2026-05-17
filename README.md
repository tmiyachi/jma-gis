# JMA-GIS

気象庁公開の予報区データを加工したベクトルタイル

## Demo

<https://tmiyachi.github.io/jma-gis/>

## Data

### geojson

| ファイル名         | 区域                   |
| ------------------ | ---------------------- |
| pref.geojson       | 府県予報区             |
| firstarea.geojson  | 一次細分区             |
| matomearea.geojson | 市町村等をまとめた地域 |
| city.geojson       | 二次細分区             |

### tiles

| レイヤー名 | 区域                   | ズームレベル |
| ---------- | ---------------------- | ------------ |
| pref       | 府県予報区             | 4~14         |
| firstarea  | 一次細分区             | 5~14         |
| matomearea | 市町村等をまとめた地域 | 7~14         |
| city       | 二次細分区             | 7~14         |

### fields

| フィールド名      | 説明                             | pref | firstarea | matomearea | city |
| ----------------- | -------------------------------- | ---- | --------- | ---------- | ---- |
| prefcode          | 府県予報区コード                 | ○    | ×         | ×          | ×    |
| prefname          | 府県予報区名                     | ○    | ×         | ×          | ×    |
| prefname_kn       | 府県予報区名（かな）             | ○    | ×         | ×          | ×    |
| firstareacode     | 一次細分区コード                 | ○    | ○         | ×          | ×    |
| firstareaname     | 一次細分区名                     | ○    | ○         | ×          | ×    |
| firstareaname_kn  | 一次細分区名（かな）             | ○    | ○         | ×          | ×    |
| matomeareacode    | 市町村等をまとめた地域コード     | ○    | ○         | ○          | ×    |
| matomeareaname    | 市町村等をまとめた地域名         | ○    | ○         | ○          | ×    |
| matomeareaname_kn | 市町村等をまとめた地域名（かな） | ○    | ○         | ○          | ×    |
| citycode          | 二次細分区コード                 | ○    | ○         | ○          | ○    |
| cityname          | 二次細分区名                     | ○    | ○         | ○          | ○    |
| cityname_kn       | 二次細分区名（かな）             | ○    | ○         | ○          | ○    |

## Dependencies

- [mapshaper](https://github.com/mbloch/mapshaper)
- [tippecanoe](https://github.com/mapbox/tippecanoe)
- [pmtiles CLI](https://docs.protomaps.com/pmtiles/cli)

## Make

必要なパッケージをダウンロードする．

```
npm install
python -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

気象庁データをダウンロードする．

```
# ./scripts
./00_download_jma.sh
```

XML コードテーブル表から csv ファイルを作成する．

```
# ./scripts
python 01_make_jmacode.py
```

geoJSON ファイルを作成する．[mapshaper](https://github.com/mbloch/mapshaper)を使用してポリゴンの簡素化，統合をしている．

```
# ./scripts
./02_make_geojson.sh
```

ベクトルタイルを作成する．

```
# ./scripts
./03_make_tiles.sh
```

## Demo

```
# ./
npm run start

```

## How To Use

```js
const protocol = new Protocol();
maplibregl.addProtocol("pmtiles", protocol.tile);

const map = new maplibregl.Map({
  ...,
  style: {
    version: 8,
    sources: {
      v: {
        type: "vector",
        minzoom: 4,
        maxzoom: 14,
        url: "pmtiles://https://tmiyachi.github.io/jma-gis/jma-gis.pmtiles",
        attribution:
          '<a href="https://www.data.jma.go.jp/developer/gis.html">気象庁「予報区等GISデータ」</a>を加工して作成',
      },
    },
  },
});
```

## Reference

このデータの作成には気象庁公開のデータを利用しています．

- [予報区等 GIS データ](https://www.data.jma.go.jp/developer/gis.html)の GIS データを加工して作成．
- [気象庁防災情報 XML フォーマット　技術資料](http://xml.kishou.go.jp/tec_material.html)の XML コード表を加工して作成．
