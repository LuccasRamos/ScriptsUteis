SQLLDR USER/PASS@SERVER:PORT/INSTANCE

OPTIONS (ERRORS=999999999, ROWS=100) 
LOAD DATA 
infile 'C:\temp\sqlloader\infile.txt'
badfile 'C:\temp\sqlloader\badFiles.bad'
discardfile 'C:\temp\sqlloader\discardFiles.dsc'
APPEND 
INTO TABLE sql_loader 
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS (ID,VALOR,VALOR2,DATA)
