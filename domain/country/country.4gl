################################################################################
#
# FOURJS_START_COPYRIGHT(U,2019)
# Property of Four Js*
# (c) Copyright Four Js 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
#
# Four Js and its suppliers do not warrant or guarantee that these samples
# are accurate and suitable for your purposes. Their inclusion is purely for
# information purposes only.
# FOURJS_END_COPYRIGHT
#
################################################################################
#+ This module implements countries class information handling
#+
#+ This code uses the 'officestore' database tables.
#+ countries input, query and list handling functions are defined here.
#+
#+ Only functions determined to be exposed as a resource should be made PUBLIC.
#+

import util

# Logging utility
import fgl logger

# Default compile schema
schema officestore

##############################################################################
#+
#+ CLASS "country" record types:
#+ - Complete table list
#+ - Include for types associated with the "country" object
#+

#
# Standard SQL statement CONSTANTs
#
constant C_SELECTSQL = "SELECT * FROM country"
constant C_UPDATESQL = "UPDATE country SET codedesc = ? WHERE code = ?"
constant C_INSERTSQL = "INSERT INTO country VALUES (?, ?)"
constant C_DELETESQL = "DELETE FROM country WHERE code = ?"

#
# User type definitions
#
type countryType record like country.*

#+
#+ Module variables
#+
define mQuery record
    id string
end record

define mSqlWhere string

public define mRecords dynamic array of countryType

################################################################################
#+
#+ Method: getRecords
#+
#+ Description: Retrieves records using the query filter
#+
#+ @code
#+ CALL getRecords()
#+
#+ @param
#+ NONE
#+
#+ @return
#+ NONE
#+
public function getRecords() returns()
    define i integer
    define sqlStatement string

    whenever any error raise  -- Let the referencing call handle the errors

    # Add query filter to standard SQL
    let sqlStatement = C_SELECTSQL

    let sqlStatement = sfmt("%1 %2", sqlStatement, getQueryFilter())

    call logger.logEvent(logger.C_LOGDEBUG, sfmt("country:%1", __LINE__), "getRecords", sfmt("SQL statement: %1", sqlStatement))

    call mRecords.clear()
    prepare cursorStatement from sqlStatement
    declare curs cursor for cursorStatement
    let i = 1
    foreach curs into mRecords[i].*
        let i = i + 1
    end foreach

    close curs
    free curs

    return
end function

################################################################################
#+
#+ Method: getJSONEncoding
#+
#+ Description: Returns a string representation of the sample storage array in JSON format
#+
#+ @code
#+ CALL getJSONEncoding()
#+
#+ @param
#+ NONE
#+
#+ @return
#+ util.JSON.stringify(mRecords recordType)
#+
function getJSONEncoding() returns(string)
    return util.JSON.stringify(mRecords)
end function

################################################################################
#+
#+ Method: init
#+
#+ Description: Clears the storage array of all records
#+
#+ @code
#+ CALL init()
#+
#+ @param
#+ NONE
#+
#+ @return
#+ NONE
#+
function init() returns()
    call mRecords.clear()
    return
end function

################################################################################
#+
#+ Method: getRecordsList
#+
#+ Description: Always return a list array(pointer).  The idea is that one or many it
#+    doesn't matter, always return a list(array)
#+
#+ @code
#+ CALL getRecordsList()
#+
#+ @param
#+ NONE
#+
#+ @return
#+ mRecords recordType
#+
function getRecordsList() returns(dynamic array of countryType)
    return mRecords
end function

################################################################################
#+
#+ Method: processRecordsUpdate
#+
#+ Description: Processes a list of records to update the changes to the records for storage
#+    to the data source
#+
#+ @code
#+ LET status = processRecordsUpdate(thisData)
#+
#+ @param
#+ thisData STRING : representation of an array of records
#+
#+ @return
#+ stat INTEGER : appropriate HTTP status code
#+
public function processRecordsUpdate(thisData string) returns(integer)
    define thisJSONArr util.JSONArray
    define thisJSONObj util.JSONObject
    define rowsUpdated integer
    define i, stat integer

    whenever any error raise  -- Let the referencing call handle the errors

    if (thisData is not null) then --> Don't allow a NULL key value for update
        prepare recordUpdate from C_UPDATESQL

        # Create and array from the string to walk through...much easier than filling BDL arrays:records:elements
        let thisJSONArr = util.JSONArray.parse(thisData)
        # Walk the JSON Array and update each element to the data source
        for i = 1 to thisJSONArr.getLength()
            let thisJSONObj = thisJSONArr.get(i)
            # Update category by catid
            call updateRecordById(thisJSONObj.toString()) returning rowsUpdated
        end for

        free recordUpdate
    end if

    return 200 --> If an error is encountered, it will be handled by ERROR RAISE
end function

################################################################################
#+
#+ Method: updateRecordById
#+
#+ Description: Executes the update to the given record in the datasource returning
#+    the number of rows processed.  If no rows found, return zero.
#+
#+ @code
#+ CALL updateRecordById(thisID) RETURNING rowsUpdated
#+
#+ @param
#+ thisData STRING : representation of sample record
#+
#+ @return
#+ stat INTEGER : number of rows updated
#+
public function updateRecordById(thisData string) returns(integer)
    define thisRecord countryType
    define parseObject util.JSONObject
    define stat int

    whenever any error raise  -- Let the referencing call handle the errors

    let parseObject = util.JSONObject.parse(thisData)
    call parseObject.toFGL(thisRecord)

    execute recordUpdate using thisRecord.codedesc, thisRecord.code

    # Return the number of rows processed to report success status
    let stat = SQLCA.SQLERRD[3]

    return stat
end function

################################################################################
#+
#+ Method: processRecordInsert(query STRING)
#+
#+ Description: Processes a list of records to insert into the datasource returning success/fail
#+
#+ @code
#+ LET status = processRecordInsert(thisData)
#+
#+ @param
#+ thisData STRING : representation of sample array
#+
#+ @return
#+ stat INTEGER : HTTP status code
#+
public function processRecordsInsert(thisData string) returns(integer)
    define thisJSONArr util.JSONArray
    define thisJSONObj util.JSONObject
    define i integer

    whenever any error raise  -- Let the referencing call handle the errors

    if (thisData is not null) then --> Don't allow a NULL resource creation
        prepare recordInsert from C_INSERTSQL

        # Create and array from the string to walk through...much easier than filling BDL arrays:records:elements
        let thisJSONArr = util.JSONArray.parse(thisData)
        # Walk the JSON Array and insert each element to the data source
        for i = 1 to thisJSONArr.getLength()
            let thisJSONObj = thisJSONArr.get(i)
            # Insert new record
            call insertRecord(thisJSONObj.toString())
        end for

        free recordInsert
    end if

    return 200
end function

################################################################################
#+
#+ Method: insertRecord
#+
#+ Description: Executes the insert of the given record into the datasource returning
#+    the number of rows processed.  If no rows found, return zero.
#+
#+ @code
#+ LET status = insertRecord(thisData)
#+
#+ @param
#+ thisData STRING : representation of sample record
#+
#+ @return
#+ NONE
#+
public function insertRecord(thisData string) returns()
    define thisRecord countryType
    define parseObject util.JSONObject
    define stat int

    whenever any error raise  -- Let the referencing call handle the errors

    let parseObject = util.JSONObject.parse(thisData) --> Parse JSON string
    call parseObject.toFGL(thisRecord) --> Put JSON into FGL

    execute recordInsert using thisRecord.*

    let stat = SQLCA.SQLCODE

    return
end function

################################################################################
#+
#+ Method: processRecordsDelete
#+
#+ Description: Processes a list of records to delete from the datasource returning
#+    success/fail.
#+
#+ @code
#+ LET status = processRecordsDelete(thisID STRING)
#+
#+ @param
#+ thisData STRING : record key to be deleted
#+
#+ @return
#+ stat INTEGER : HTTP status code
#+
public function processRecordsDelete(thisData string) returns(integer)
    define thisJSONArr util.JSONArray
    define thisJSONObj util.JSONObject
    define i integer

    whenever any error raise  -- Let the referencing call handle the errors

    if (thisData is not null) then --> Don't allow a NULL resource
        prepare recordDelete from C_DELETESQL

        # Create and array from the string to walk through...much easier than filling BDL arrays:records:elements
        let thisJSONArr = util.JSONArray.parse(thisData)
        # Walk the JSON Array and delete each element from the data source
        for i = 1 to thisJSONArr.getLength()
            let thisJSONObj = thisJSONArr.get(i)
            # Delete record
            let thisData = thisJSONObj.get("keyValue")
            execute recordDelete using thisData
        end for

        free recordDelete

    end if

    return 200
end function

################################################################################
#+
#+ Method: getQueryFilter()
#+
#+ Description: Returns the query filter in the form of a WHERE clause
#+
#+ @code
#+ LET sqlStatement = SFMT("%1 %2", _SELECTSQL, getQueryFilter())
#+
#+ @param
#+ NONE
#+
#+ @return
#+ mSqlWhere STRING : SQL where clause for query
#+
private function getQueryFilter() returns string
    return mSqlWhere
end function

################################################################################
#+
#+ Method: isValidQuery
#+
#+ Description: Returns BOOLEAN true/false
#+
#+ @code
#+ IF account.isValidQuery(queryParameter)
#+
#+ @param
#+ queryParameter STRING : Name of query parameter
#+
#+ @return
#+ TRUE/FALSE
#+
public function isValidQuery(queryName string) returns(boolean)
    define isValid boolean

    case (queryName)
        when "id"
            let isValid = true
        otherwise
            let isValid = false
    end case

    return isValid
end function

################################################################################
#+
#+ Method: addQueryFilter
#+
#+ Description: Add a valid query key and value to the standard query filter(WHERE 1=1)
#+
#+ @code
#+ CALL account.addQueryFilter(columnKey, columnValue)
#+
#+ @param
#+ columnKey   STRING : Column name key
#+ columnValue STRING : Column query value
#+
#+ @return
#+ NONE
#+
public function addQueryFilter(columnKey string, columnValue string) returns()

    case (columnKey)
        when "id"
            let mSqlWhere = sfmt("%1 %2 '%3'", mSqlWhere, " AND code LIKE ", columnValue)
    end case

    return
end function

#+
#+ Module mutators
#+
function initQuery() returns()
    initialize mQuery.* to null
    let mSqlWhere = "WHERE 1=1"
    return
end function

function setQueryid(thisID string) returns()
    let mQuery.id = thisID
    return
end function
