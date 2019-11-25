import requests
import json
from pymongo import MongoClient


client = MongoClient('mongodb://localhost:27017')
db = client['plive']
collection = db.pessoas
def cria_pessas(qtd):
    for i in range(qtd):
        res  = requests.get("http://localhost:8080/pessoa")
        post = res.text
        post = post.replace('{"pessoas": [{','({')
        post = post.replace('}]}','})')
        post = res.json()
        collection.insert_one(post)
