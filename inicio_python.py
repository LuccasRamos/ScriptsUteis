import requests
import json
from pymongo import MongoClient
from mysql.connector import MySQLConnection, Error

client = MongoClient('mongodb://localhost:27017')
db = client['plive']
collection = db.pessoas
def cria_pessoas(qtd):
    for i in range(qtd):
        res  = requests.get("http://localhost:8080/pessoa")
        post = res.text
        #post = res.json()
        #collection.insert_one(post)
        post = json.loads(post)
        print (post["pessoas"][0]["cartao de credito"])
        cvv = post["pessoas"][0]["cartao de credito"]["cvv"]
        validade = post["pessoas"][0]["cartao de credito"]["validade"]
        numero = post["pessoas"][0]["cartao de credito"]["numero"]
        cpf = post["pessoas"][0]["documentos"]["cpf"]
        conn = None
    try:
        conn = MySQLConnection(host='localhost', 
                           database='banco', 
                           user='admin', 
                           password='admin')
        x = conn.cursor()
        if conn.is_connected():
             print('Conectado Mysql!')
             x.execute("""INSERT INTO tb_conta(cvv,validade,numero,cpf) VALUES (%s,%s,%s,%s)""",(cvv,validade,numero,cpf))
             conn.commit()
    except Error as e:
        print(e)
        
    finally:
        if conn is not None and conn.is_connected():
            conn.close()
