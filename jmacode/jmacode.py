"""
気象庁XMLコード定義ファイルから府県予報区，一次細分区，市町村等をまとめた地域の
コード，名称，かな名称のデータを抽出したcsvファイルを作成する．
"""
import os

import pandas as pd

xmltablefile = os.path.join(os.path.dirname(__file__), '../jma/AreaInformationCity.xls')

# 二次細分区域, 市町村等をまとめた地域
citycode_idx = 0
cityname_idx = 2
cityname_kn_idx = 3
municipalitycode_idx = 4
filter_idx = 5  # 気象警報注意報で利用フラグ
df_city = pd.read_excel(xmltablefile, sheet_name='AreaInformationCity', header=2)
ilocs = [citycode_idx, cityname_idx, cityname_kn_idx, municipalitycode_idx]
df_city = df_city.loc[df_city.iloc[:, filter_idx] == 1].iloc[:, ilocs]
df_city.columns = ['citycode', 'cityname', 'cityname_kn', 'municipalitycode']
df_city['citycode'] = df_city['citycode'].apply(lambda code: '{:07d}'.format(int(code)))
df_city['municipalitycode'] = df_city['municipalitycode'].apply(lambda code: '{:06d}'.format(int(code)))
df_city = df_city.sort_values('citycode')

# 市町村等をまとめた地域, 一次細分区, 府県予報区の名称
code_idx = 0
name_idx = 1
name_kn_idx = 2
df_code = pd.read_excel(xmltablefile, sheet_name='AreaForecastLocalM（コード表）', header=3)
ilocs = [code_idx, name_idx, name_kn_idx]
df_code = df_code.iloc[:, ilocs]
df_code.columns = ['code', 'name', 'name_kn']
df_code['code'] = df_code['code'].apply(lambda code: '{:06d}'.format(int(code)))
df_code = df_code.sort_values('code')

# 市町村等をまとめた地域, 一次細分区, 府県予報区の対応関係
municipalitycode_idx = 0
firstareacode_idx = 2
prefcode_idx = 4
df_table = pd.read_excel(xmltablefile, sheet_name='AreaForecastLocalM（関係表　警報・注意報', header=2)
ilocs = [municipalitycode_idx, firstareacode_idx, prefcode_idx]
df_table = df_table.iloc[:, ilocs]
df_table.columns = ['municipalitycode', 'firstareacode', 'prefcode']
df_table['municipalitycode'] = df_table['municipalitycode'].apply(lambda code: '{:06d}'.format(int(code)))
df_table['firstareacode'] = df_table['firstareacode'].apply(lambda code: '{:06d}'.format(int(code)))
df_table['prefcode'] = df_table['prefcode'].apply(lambda code: '{:06d}'.format(int(code)))

# 市町村等をまとめた地域
df_muni = df_table.drop_duplicates('municipalitycode').merge(
    df_code, left_on='municipalitycode', right_on='code', how='left')
df_muni = df_muni.loc[:, ['municipalitycode', 'name', 'name_kn']]
df_muni.columns = ['municipalitycode', 'municipalityname', 'municipalityname_kn']

# 一次細分区
df_firstarea = df_table.drop_duplicates('firstareacode').merge(
    df_code, left_on='firstareacode', right_on='code', how='left')
df_firstarea = df_firstarea.loc[:, ['firstareacode', 'name', 'name_kn']]
df_firstarea.columns = ['firstareacode', 'firstareaname', 'firstareaname_kn']

# 府県予報区
df_pref = df_table.drop_duplicates('prefcode').merge(
    df_code, left_on='prefcode', right_on='code', how='left')
df_pref = df_pref.loc[:, ['prefcode', 'name', 'name_kn']]
df_pref.columns = ['prefcode', 'prefname', 'prefname_kn']

# csvで保存
df_city.loc[:, ['citycode', 'cityname', 'cityname_kn']].to_csv('citycode.csv', index=False)
df_muni.to_csv('municipalitycode.csv', index=False)
df_firstarea.to_csv('firstareacode.csv', index=False)
df_pref.to_csv('prefcode.csv', index=False)

# 統合
df_all = df_city.merge(
    df_table,
    how='left').merge(
        df_muni,
        how='left').merge(
            df_firstarea,
            how='left').merge(
                df_pref,
    how='left')
df_all = df_all.loc[:,
                    ['citycode',
                     'cityname',
                     'cityname_kn',
                     'municipalitycode',
                     'municipalityname',
                     'municipalityname_kn',
                     'firstareacode',
                     'firstareaname',
                     'firstareaname_kn',
                     'prefcode',
                     'prefname',
                     'prefname_kn']]
df_all.to_csv('jmacode.csv', index=False)
