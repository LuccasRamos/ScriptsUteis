import cx_Oracle
import mysql.connector
import getpass
import pymongo
import subprocess

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
            
class loader():
    def __init__(self,username,password,hostname,columns,table,directory,termined_by):
        self.username = username
        self.password = password
        self.hostname = hostname
        self.columns = columns
        self.table = table
        self.directory = directory
        self.termined_by = termined_by
    
    def create_controlfile(self):
        file = open(self.directory+"controlfile.ctl", "w") 
        file.write("options (errors=9999999)\n")
        file.write("load data\n") 
        file.write("characterset UTF8\n") 
        file.write("infile '"+self.directory+"carrega_token.csv' \n") 
        file.write("badfile '"+self.directory+"bad_file.bad' \n")
        file.write("discardfile '"+self.directory+"discard_filed.dsc'\n")
        file.write("into table "+self.table+"\n")
        file.write("fields terminated by ';' TRAILING NULLCOLS\n")
        file.write("("+self.columns+")")
        file.close() 
    
    
    def sqlldr(self):
        loader = 'sqlldr userid='+self.username+'/'+self.password+'@'+self.hostname+' control='+self.directory+'controlfile.ctl'
        #print(loader)
        subprocess.call(loader, shell=True)
                
