import pandas as pd
import pyodbc
from datetime import datetime


nombres_tabla= ['good','bad']
csv_files= ['good.csv', 'bad.csv']

#Conexión a SQL Server
conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost\\SQLEXPRESS;DATABASE=Redarbor_test;UID=lluis;PWD=lluis$$')
cursor = conn.cursor()
print("Connection established with SQL Server")

#Iteramos para cada pareja de tabla con csv usando for y el zip para emparejarlos:
for tabla, csv in zip(nombres_tabla, csv_files):
    
    print(f"Starting ETL process for: {csv}")

    #Leer csv solo con la columnas que nos interesan
    df=pd.read_csv(csv ,usecols=['Source', 'userid', 'Join'])

    #cambiar nombre de las columnas para tener los nombres con misma estructura.
    df.rename(columns={'Source': 'source', 'Join': 'time'}, inplace=True)

    #transformar la columna time en un formato compatible para SQL Server.
    df['time'] = pd.to_datetime(df['time'], errors='coerce', format='%Y-%m-%d %H:%M:%S')

    print(f"Número de filas en el archivo {csv}: {df.shape[0]}")

    #Eliminar filas con valores nulos
    df_clean = df.dropna()

    print(f"Número de filas válidas después de eliminar nulos para {csv}: {df_clean.shape[0]}")


    #Verificar si la tabla existe antes de crearla
    table_check_query = f"""
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '{tabla}')
    BEGIN
        CREATE TABLE {tabla} (
            source NVARCHAR(100),
            userid NVARCHAR(100),
            time DATETIME
        );
    END
    """
    print(f"Creating table if not exists for: {csv}")
    cursor.execute(table_check_query)
    conn.commit()

    insert_query = f"""
    INSERT INTO {tabla} (source, userid, time) 
    VALUES (?, ?, ?)
    """

    print(f"Starting loading data to sql: {csv}")

    # Optimización para inserciones en bloque
    cursor.fast_executemany = True
    cursor.executemany(insert_query, df_clean.values.tolist())
    
    print(f"ETL process completed for: {csv}")


conn.commit()

cursor.close()
conn.close()
