import cx_Oracle
import mysql.connector
import getpass
import pymongo

class Connection():
    def __init__(self, sgbd, username, password, hostname, port, database):
        self.sgbd = sgbd
        self.username = username
        self.password = password
        self.hostname = hostname
        self.port = port
        self.sid  = database
        
    def connecta_mysql(self):
        conn = None
        CONFIG = {
            'user': self.username,
            'password': self.password,
            'host': self.hostname,
            'port': self.port
        }
        try:
            conn = mysql.connector.connect(**CONFIG)
        except mysql.connector.Error as err:
            print(err)
        
        return conn
    
    def connecta_orcl(self):
        conn = None
        host_orcl = self.hostname+':'+self.port+'/'+self.sid
        CONFIG = {
            'user':self.username,
            'password':self.password,
            'dsn':host_orcl
        }
        try: 
            conn = cx_Oracle.connect(**CONFIG)
        except cx_Oracle.Error as err:
            print(err)

        return conn
        
    def connecta_mongo(self):
        conn = None
        CONFIG = {'user':self.username,'password':self.password,'hostname':self.hostname}
        try:
            conn = pymongo.MongoClient('mongodb://localhost:27017/')
        except pymongo.errors.ConnectionFailure as err:
            print(err)
