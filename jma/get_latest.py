"""
気象庁が公開しているXMLコード定義ファイルとGISファイルの最新版のファイル名を取得
"""

import re
from pathlib import Path

import requests
from bs4 import BeautifulSoup


def get_xmlzip_name():
    # 気象庁防災情報XMLフォーマット技術資料のXML個別コード表
    with requests.get("http://xml.kishou.go.jp/tec_material.html") as res:
        res.raise_for_status()
        soup = BeautifulSoup(res.text, "html.parser")

        # <a>タグのhref属性をすべて抽出
        link = soup.find("a", href=re.compile(r"jmaxml_\d{8}_Code\.zip$"))
        if link is not None:
            return Path(link.get("href")).name

    raise ValueError("XML個別コード表ファイルのパスが見つかりません")


def get_giszip_name():
    # 気象庁気象データ高度利用ポータルサイト > 予報区等GISデータの一覧
    with requests.get("https://www.data.jma.go.jp/developer/gis.html") as res:
        res.raise_for_status()
        soup = BeautifulSoup(res.text, "html.parser")

        # <a>タグのhref属性をすべて抽出
        link = soup.find(
            "a", href=re.compile(r"\d{8}_AreaInformationCity_weather_GIS\.zip$")
        )
        if link is not None:
            return Path(link.get("href")).name

    raise ValueError("XML個別コード表ファイルのパスが見つかりません")


if __name__ == "__main__":
    xmlzip = get_xmlzip_name()
    giszip = get_giszip_name()

    save_dir = Path(__file__).parent
    with open(save_dir / "latest_xmlzip.txt", "w") as f:
        f.write(xmlzip)
    with open(save_dir / "latest_giszip.txt", "w") as f:
        f.write(giszip)
