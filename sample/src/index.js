import mapboxgl from 'mapbox-gl';
import '@/main.css';

// タイルをホストしているサーバーのルート
// eslint-disable-next-line no-undef
const maphost = MAPHOST ?? 'http://localhost';

// マップオブジェクト
const map = new mapboxgl.Map({
  container: 'map',
  center: [135, 35],
  zoom: 7,
  maxZoom: 10,
  minZoom: 4,
  style: {
    version: 8,
    sources: {
      'jmagis-vector': {
        type: 'vector',
        tiles: [`${maphost}/tiles/zxy/{z}/{x}/{y}.pbf`],
        attribution:
          '<a href="https://www.data.jma.go.jp/developer/gis.html">気象庁「予報区等GISデータ」</a>を加工して作成',
      },
    },
    layers: [
      {
        id: 'city-fills',
        type: 'fill',
        source: 'jmagis-vector',
        'source-layer': 'city',
        layout: {},
        paint: {
          'fill-color': '#627BC1',
          'fill-opacity': [
            'case',
            ['boolean', ['feature-state', 'hover'], false],
            1,
            0.5,
          ],
        },
      },
      {
        id: 'matomearea-lines',
        type: 'line',
        source: 'jmagis-vector',
        'source-layer': 'matomearea',
        layout: {},
        paint: {
          'line-color': '#627BC1',
          'line-opacity': 0.8,
        },
      },
      {
        id: 'firstarea-fills',
        type: 'fill',
        source: 'jmagis-vector',
        'source-layer': 'firstarea',
        layout: {},
        paint: {
          'fill-color': '#627BC1',
          'fill-opacity': 0.5,
        },
        maxzoom: 7,
      },
      {
        id: 'firstarea-lines',
        type: 'line',
        source: 'jmagis-vector',
        'source-layer': 'firstarea',
        layout: {},
        paint: {
          'line-color': '#757575',
          'line-width': 0.8,
        },
        minzoom: 7,
      },
      {
        id: 'pref-lines',
        type: 'line',
        source: 'jmagis-vector',
        'source-layer': 'pref',
        layout: {},
        paint: {
          'line-color': '#212121',
          'line-width': 0.8,
        },
      },
    ],
  },
});

// コントロールの追加
map.addControl(new mapboxgl.ScaleControl());
map.addControl(new mapboxgl.NavigationControl());

// loadイベント
map.on('load', function () {
  let hoveredCityId = null;

  // cityレイヤーのマウスイベントで常態を切り替える
  map.on('mousemove', 'city-fills', function (e) {
    if (e.features.length > 0) {
      if (hoveredCityId) {
        map.setFeatureState(
          { source: 'jmagis-vector', sourceLayer: 'city', id: hoveredCityId },
          { hover: false }
        );
      }
      hoveredCityId = e.features[0].id;
      map.setFeatureState(
        { source: 'jmagis-vector', sourceLayer: 'city', id: hoveredCityId },
        { hover: true }
      );
      setInfoPanel(e.features[0].properties);
    }
  });

  map.on('mouseleave', 'city-fills', function () {
    if (hoveredCityId) {
      map.setFeatureState(
        { source: 'jmagis-vector', sourceLayer: 'city', id: hoveredCityId },
        { hover: false }
      );
      setInfoPanel(null);
    }
    hoveredCityId = null;
  });

  // ズームレベルを表示

  const zoomInfo = document.getElementById('zoomlevel');
  zoomInfo.innerHTML = `ズームレベル: ${Math.round(map.getZoom() * 100) / 100}`;
  document.getElementById('control').classList.remove('hidden');

  map.on('zoom', function () {
    zoomInfo.innerHTML = `ズームレベル: ${
      Math.round(map.getZoom() * 100) / 100
    }`;
  });

  const contentInfo = document.getElementById('contentInfo');
  const setInfoPanel = (f) => {
    if (f) {
      let html = `
<table>
<tr><td>府県予報区</td><td>${f.prefname}（${f.prefname_kn}）</td></tr>
<tr><td>一次細分区</td><td>${f.firstareaname}（${f.firstareaname_kn}）</td></tr>
<tr><td>市町村等をまとめた地域</td><td>${f.matomeareaname}（${f.matomeareaname_kn}）</td></tr>
<tr><td>二次細分区</td><td>${f.cityname}（${f.cityname_kn}）</td></tr>
</table>`;
      contentInfo.innerHTML = html;
    } else {
      contentInfo.innerHTML = '';
    }
  };
});
