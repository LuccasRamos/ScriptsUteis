db.coll.insert({"string":"texto","numero":12.5,"bool1":true,"bool2":false,"isnull":null,"data":Date()});  

db.coll.find({"isnull":null}); 


{
	"_id" : ObjectId("5bd9a8bb39b5e7c0dc1ba3e1"),
	"id_cliente" : 27374336810,
	"nome_cliente" : "JULIANO BELLINI                                   ",
	"dia_pagamento" : 14,
	"fatura" : [
		{
			"id_fatura" : 30099394,
			"desc_fatura" : "GERAÇÃO AUTOMÁTICA DE FATURA",
			"valor" : 800,
			"data_compra" : "31/03/02"
		}
	],
	"produtos" : [
		{
			"id_servico" : 5
		}
	],
	"status" : null
}

{ print( "user: " + myDoc.name ); }


db.faturas.find({"fatura.id_fatura" : 30099394},{"fatura.id_fatura":1,"fatura.data_compra":1,_id:0,"id_cliente":1}).toArray().map(function(doc){"data: "+doc.id_cliente})

db.faturas.find({"id_cliente" : 27374336810}).toArray().map(function(doc){return doc.fatura.id_fatura})

db.faturas.find({"id_cliente":{$elemMatch:{"id_cliente":27374336810}}})



db.cities.aggregate([{$group: {_id: "$ibge_city_id",count: { $sum: 1 }, city_id:{$first:"$city_id"}}}, {$match: {count: { "$eq": 1 }}}, {$project: { _id:0 , count:0 }}]).toArray().map(function(doc){return doc.city_id});



db.inventory.find( { "instock": { $elemMatch: { qty: 5, warehouse: "A" } } } )


db.faturas.find({"fatura.id_fatura" : 30099394},{fatura.id_fatura:1, fatura.data_compra:1}).forEach(function(doc){print( "data: " + doc.fatura.data_compra );}) 
























mongo --username alice --password --authenticationDatabase admin --host mongodb0.examples.com --port 28015 

db.faturas.insertOne(
{
	"id_cliente" : 27374336810,
	"nome_cliente" : "JULIANO BELLINI",
	"dia_pagamento" : 14,
	"fatura" : [
		{
			"id_fatura" : 100000,
			"desc_fatura" : "GERAÇÃO AUTOMÁTICA DE FATURA",
			"valor" : 800,
			"data_compra" : "31/03/02"
		}
	],
	"produtos" : [
		{
			"id_servico" : 2003,
			"id_servico" : 2004,
			"id_servico" : 2005

		}
	],
	"status" : null
})




db.faturas.find({"fatura"."id_fatura":100000})


DNS
qa2-3.mongodb.globoi.com
em csv a saída

mongo qa2-3.mongodb.globoi.com/admin -udb_arq -p

db.currentOp()
db.users.findOne({"created_at":{$gte:ISODate("2018-11-26 12:47:36.300Z")}},{"cadun_id":1,"globo_id":1,"status_id":1})
db.killOp(opid)
db.users.findOne({"created_at":{$gte:ISODate("2018-11-26T12:47:36.300Z")}},{"_id":1,"cadun_id":1,"status_id":1})

ALTER SYSTEM KILL SESSION '4313,62792'
exportando dump via mongo. 
mongoexport --host=qa2-3.mongodb.globoi.com --username=db_arq --password= --authenticationDatabase=admin --db=glive --collection=users --type=csv --fields=cadun_id,_id,status_id,email  --out=glive-users.csv --query='{"created_at":{$gte:ISODate("2018-11-26T12:47:36.300Z")}}'

 
db.cities.aggregate([{$group: {_id: "$ibge_city_id",count: { $sum: 1 }, city_id:{$first:"$city_id"}}}, {$match: {count: { "$eq": 1 }}}, {$project: { _id:0 , count:0 }}]).toArray().map(function(doc){return doc.city_id});


db.collection.createIndex( { "fatura.id_fatura":-1 } )




db.faturas.find({})
db.faturas.distinct({"produtos.id_servico"})

