"""
気象庁XMLコード定義ファイルから府県予報区，一次細分区，市町村等をまとめた地域の
コード，名称，かな名称のデータを抽出したcsvファイルを作成する．
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd

PROJECT_DIR = Path(__file__).parent.parent
TABLE_DIR = PROJECT_DIR / "jma"
JMACODE_DIR = PROJECT_DIR / "jmacode"

# AreaInformationCity
COLUMNS_AREA_INFORMATION_CITY = {
    0: "citycode",
    2: "cityname",
    3: "cityname_kn",
    4: "matomeareacode",
    5: "filter",  # "気象警報・注意報"及び "気象特別警報報知"で使用の有無フラグ
}
# AreaForecastLocalM（コード表）
COLUMNS_AREA_FORECAST_LOCAL_M_CODE = {
    0: "code",
    1: "name",
    2: "name_kn",
}
# AreaForecastLocalM（関係表　警報・注意報
COLUMNS_AREA_FORECAST_LOCAL_M_LOOKUP = {
    0: "matomeareacode",
    2: "firstareacode",
    4: "prefcode",
}


def read_excel(excel_path: Path, sheet_name: str, header: int, columns: dict[int, str]):
    df = pd.read_excel(
        excel_path,
        sheet_name=sheet_name,
        header=header,
        usecols=columns.keys(),
    )
    df.columns = list(columns.values())

    return df


def normalize_code(s: pd.Series, width: int):
    return s.astype(int).astype(str).str.zfill(width)


def attach_name(df_lookup, df_code, key, prefix):
    return df_lookup.merge(df_code, left_on=key, right_on="code", how="left").rename(
        columns={
            "name": f"{prefix}name",
            "name_kn": f"{prefix}name_kn",
        }
    )


def main():
    table_path = TABLE_DIR / "AreaInformationCity.xls"

    #
    # テーブルの読み込み
    #
    # 二次細分区域, 市町村等をまとめた地域
    df_city = read_excel(
        excel_path=table_path,
        sheet_name="AreaInformationCity",
        header=2,
        columns=COLUMNS_AREA_INFORMATION_CITY,
    )
    # "気象警報・注意報"及び "気象特別警報報知"で使用するコードを抽出
    df_city = df_city.loc[df_city["filter"] == 1].drop(columns="filter")
    # コードを0埋めする
    df_city["citycode"] = normalize_code(df_city["citycode"], 7)
    df_city["matomeareacode"] = normalize_code(df_city["matomeareacode"], 6)

    # 市町村等をまとめた地域, 一次細分区, 府県予報区の名称定義
    df_code = read_excel(
        excel_path=table_path,
        sheet_name="AreaForecastLocalM（コード表）",
        header=3,
        columns=COLUMNS_AREA_FORECAST_LOCAL_M_CODE,
    )
    df_code["code"] = normalize_code(df_code["code"], 6)

    # 市町村等をまとめた地域, 一次細分区, 府県予報区コードの対応関係
    df_lookup = read_excel(
        excel_path=table_path,
        sheet_name="AreaForecastLocalM（関係表　警報・注意報",
        header=2,
        columns=COLUMNS_AREA_FORECAST_LOCAL_M_LOOKUP,
    )
    for col in COLUMNS_AREA_FORECAST_LOCAL_M_LOOKUP.values():
        df_lookup[col] = normalize_code(df_lookup[col], 6)
    df_lookup = df_lookup.sort_values(["matomeareacode", "firstareacode", "prefcode"])

    #
    # 整形
    #
    # 統合
    df_lookup = attach_name(df_lookup, df_code, "matomeareacode", "matomearea")
    df_lookup = attach_name(df_lookup, df_code, "firstareacode", "firstarea")
    df_lookup = attach_name(df_lookup, df_code, "prefcode", "pref")
    df_all = (
        df_city.merge(df_lookup, on="matomeareacode", how="left")
        .loc[
            :,
            [
                "citycode",
                "cityname",
                "cityname_kn",
                "matomeareacode",
                "matomeareaname",
                "matomeareaname_kn",
                "firstareacode",
                "firstareaname",
                "firstareaname_kn",
                "prefcode",
                "prefname",
                "prefname_kn",
            ],
        ]
        .sort_values(by="citycode")
    )

    #
    # csvで保存
    #
    outputs = {
        "citycode.csv": df_city[["citycode", "cityname", "cityname_kn"]],
        "matomeareacode.csv": df_lookup[
            ["matomeareacode", "matomeareaname", "matomeareaname_kn"]
        ].drop_duplicates(),
        "firstareacode.csv": df_lookup[
            ["firstareacode", "firstareaname", "firstareaname_kn"]
        ].drop_duplicates(),
        "prefcode.csv": df_lookup[
            ["prefcode", "prefname", "prefname_kn"]
        ].drop_duplicates(),
        "jmacode.csv": df_all,
    }
    for filename, df in outputs.items():
        df.to_csv(JMACODE_DIR / filename, index=False)
        print(f"{filename} を出力しました")


if __name__ == "__main__":
    main()
