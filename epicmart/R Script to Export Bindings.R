################################## 0. EXECUTE WITH EXTREME CAUTION
#README: 
#This script has DELETE portions, understand the DELETE portions before executing the script. Search the script for 'unlink'.
#This Script exports essential pieces of a subject area mart, primarily the SQL code in bindings and also any data entry tables in entirety as CSV
#In any new environment you will have to modify section 1 for server and in any case you will have to attend to the samList
#Folders are never cleaned up at the Subject-Area-Mart level, only within their binding classification, data entry table, etc.

#Version Notes
# Version 1 Adam Proctor 2020
# Version 2 Adam Proctor 2022 Includes Data Entry Tables, and needs minimal configuration
################################## 1.  This section defines variables, do not change the output path if this export is being used in the EAM template for repository.
#SQL Server is the same hosting your EDWAdmin when you connect SAMD
SQLserver                       <- "phssql2161"
samList                         <- "'EAMImaging','EAMInpatient','EAMBehavioral'"

################################## 2. This section installs or loads libraries depending on whether they are already installed or not
using<-function(...) {
  libs<-unlist(list(...))
  req<-unlist(lapply(libs,require,character.only=TRUE))
  need<-libs[req==FALSE]
  if(length(need)>0){ 
    install.packages(need,repos='http://cran.us.r-project.org')
    lapply(need,require,character.only=TRUE)
  }
}
using("RODBC","readr","this.path")
rm(using)

outputpath                      <- paste0(this.dir(),"//","Subject-Area-Mart")

################################## 3. This section generates and stores the SQL statement which selects your SAM Binding Text.
# By default it will include data marts specified in section 1.

SQLSELECT                       <- 
  paste(
    "
SELECT specified.DataMartNM
	,BindingBASE.BindingClassificationCD
	,BindingBASE.BindingNM
  ,BindingBASE.BindingID
  ,BindingBASE.BindingTypeNM
	,BindingTXT.AttributeValueLongTXT
	,BindingTXT.AttributeNM
	,BindingBASE.BindingStatusCD
FROM (
	SELECT DataMartID
		,DataMartNM
	FROM edwadmin.CatalystAdmin.DataMartBASE
	WHERE DataMartNM IN
	(
	",
    samList,
    "
)
	
		AND DataMartTypeDSC = 'Subject Area'
	) specified
INNER JOIN EDWAdmin.CatalystAdmin.BindingBASE ON specified.DataMartID = BindingBASE.DataMartID
INNER JOIN (
	SELECT AttributeValueLongTXT
		,ObjectID
		,AttributeNM
	FROM EDWAdmin.CatalystAdmin.ObjectAttributeBASE
	WHERE AttributeNM in ('UserDefinedSQL','Script')
	AND ObjectTypeCD = 'Binding'
	) BindingTXT ON BindingBASE.BindingID = BindingTXT.ObjectID
	WHERE BindingTypeNM = 'R' and AttributeNM = 'Script'
	OR BindingTypeNM = 'SQL' and AttributeNM = 'UserDefinedSQL'
"
  )

################################## 4. This section makes the server connection and executes the SELECT, storing and cleaning up after
con                             <- RODBC::odbcDriverConnect(
  paste0(
    "driver={SQL Server};
                                                          server=",SQLserver,";
                                                          database=SAM;
                                                          trusted_connection=true
                                                          "
  )
)

queryresult                     <- sqlQuery(con, SQLSELECT)
close(con)
rm(con)

if (nrow(queryresult) == 0) { stop("SAM query returned no results")}
################################## 5. This section removes folders and all they contain effectively wiping the previous version of binding text
# This needs to be wipe and replace because otherwise deletions would not be recognized. Use caution when putting files in to these directories, they will be deleted!
for (binding in 1:nrow(queryresult)) {
  unlink(file.path(outputpath,queryresult$DataMartNM[binding],queryresult$BindingClassificationCD[binding]), recursive = TRUE) 
}

################################## 6. Here a loop sends each binding to files according to its data mart, binding classification, and binding name
for (binding in 1:nrow(queryresult)) {
  
  dir.create(file.path(outputpath), showWarnings = FALSE) 
  dir.create(file.path(outputpath,queryresult$DataMartNM[binding]), showWarnings = FALSE) 
  dir.create(file.path(outputpath,queryresult$DataMartNM[binding],queryresult$BindingClassificationCD[binding]), showWarnings = FALSE)
  
  if (queryresult$BindingTypeNM[binding] == 'SQL') {
    filename <- paste0(toString(queryresult$BindingNM[binding])," ",toString(queryresult$BindingID[binding]),".sql")
  }
  if (queryresult$BindingTypeNM[binding] == 'R') {
    filename <- paste0(toString(queryresult$BindingNM[binding])," ",toString(queryresult$BindingID[binding]),".R")
  }
  
  SAMBindingText <- as.character(queryresult$AttributeValueLongTXT[binding])
  fileconnection <- paste0(file.path(outputpath,
                                     queryresult$DataMartNM[binding],
                                     queryresult$BindingClassificationCD[binding],
                                     filename
  )
  )
  
  writeChar(SAMBindingText, fileconnection,useBytes = TRUE,eos = NULL)
  rm(filename,SAMBindingText)
  
}
rm (queryresult, fileconnection, SQLSELECT)

################################## 7. Prepare a select statement to get a list of objects to be downloaded.
# Here a row represents a server object as columns for the database, schema, and name if that server object is a data entry table.

SQLSELECT                       <- 
  paste(
    "
SELECT 
DatabaseNM,
SchemaNM,
TableNM,
DataMartNM,
CONCAT(DatabaseNM,'.',SchemaNM,'.',TableNM) AS FullObjectNM
FROM EDWAdmin.CatalystAdmin.TableBASE
INNER JOIN EDWAdmin.CatalystAdmin.DataMartBASE
ON TableBase.DatamartID = DatamartBase.DatamartID
WHERE TableBASE.AllowsDataEntryFLG = 1
and DataMartNM IN 
	( ",
    samList,
    "
	)
"
  )

################################## 8. This section makes the server connection and executes the SELECT, storing and cleaning up after
con                             <- RODBC::odbcDriverConnect(
  paste0(
    "driver={SQL Server};
                                                          server=",SQLserver,";
                                                          database=SAM;
                                                          trusted_connection=true
                                                          "
  )
)

queryresult                     <- sqlQuery(con, SQLSELECT)
close(con)
rm(con)

################################## 9. This section removes folders and all they contain effectively wiping the previous version of data entry tables
# This needs to be wipe and replace because otherwise deletions would not be recognized. Use caution when putting files in to these directories, they will be deleted!
for (ServerObjectNumber in 1:nrow(queryresult)) {
  unlink(file.path(outputpath,queryresult$DataMartNM[ServerObjectNumber], "DataEntryTable"), recursive = TRUE) 
}

################################## 10. Here a loop sends each data entry table in CSV form to its datamart folder
if (nrow(queryresult) > 0 )
  
{
  for (ServerObjectNumber in 1:nrow(queryresult)) {
    dir.create(file.path(outputpath), showWarnings = FALSE) 
    dir.create(file.path(outputpath,queryresult$DataMartNM[ServerObjectNumber]), showWarnings = FALSE) 
    dir.create(file.path(outputpath,queryresult$DataMartNM[ServerObjectNumber], "DataEntryTable"), showWarnings = FALSE)
    
    SELECTFROMTABLE                       <- 
      paste(
        "SELECT * FROM ",
        queryresult$FullObjectNM[ServerObjectNumber],
        ""
      )
    
    con                             <- RODBC::odbcDriverConnect(
      paste0(
        "driver={SQL Server};
                                                          server=",SQLserver,";
                                                          database=SAM;
                                                          trusted_connection=true
                                                          "
      )
    )
    
    ServerObject                     <- sqlQuery(con, SELECTFROMTABLE)
    
    filename <- paste0(queryresult$DatabaseNM[ServerObjectNumber],".",queryresult$SchemaNM[ServerObjectNumber],".",queryresult$TableNM[ServerObjectNumber],".csv")
    write.csv(ServerObject,
              paste0(file.path(outputpath,queryresult$DataMartNM[ServerObjectNumber]),"/","DataEntryTable","/",filename), row.names = FALSE, na="")
    close(con)
    
  }
}

rm(con)
################################## 11. This section cleans up after itself, and produces an unused output dataframe to satisfy engine requirements
rm(outputpath,filename,samList,SELECTFROMTABLE,ServerObjectNumber,SQLSELECT,SQLserver, queryresult, ServerObject)
