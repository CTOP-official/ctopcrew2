import pandas as pd
import pymysql

conn = pymysql.connect(host = "localhost", port=3306, user="ctop", password="0815", db = "ctop")

sql_input = "select * from PRODUCT"
df_this_data = pd.read_sql_query(sql_input, conn)

df_this_data.to_excel("ctopcrewProduct.xlsx")

sql_input2 = "select * from CTOPOPTION2"
df_this_data2 = pd.read_sql_query(sql_input2, conn)

df_this_data2.to_excel("ctopcrewOption.xlsx")

