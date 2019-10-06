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
#+ This module implements supplier class information handling
#+
#+ This code uses the 'officestore' database tables.
#+ Supplier input, query and list handling functions are defined here.
#+

import util

# Logging utility
import fgl logger

# Default compile schema
schema officestore

##############################################################################
#+
#+ CLASS "supplier" record types:
#+ - Complete table list
#+ - Include for types associated with the "supplier" object
#+

#
# Standard SQL statement CONSTANTs
#
private constant C_SELECTSQL = "SELECT * FROM supplier"
private constant C_UPDATESQL = "UPDATE supplier SET name = ? WHERE suppid = ?"
private constant C_INSERTSQL = "INSERT INTO supplier VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
private constant C_DELETESQL = "DELETE FROM supplier WHERE suppid = ?"

#
# User type definitions
#
type supplierType record like supplier.*
#+
#+ Module variables
#+
define mQuery record
    id string
end record

define mSqlWhere string

#TODO: determine if mutators should be used instead; should be PRIVATE; how to do this for an array
public define mRecords dynamic array of supplierType

################################################################################
#+
#+ Method: getRecords
#+
#+ Description: Retrieves records from data source and stores in the array
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

    whenever any error raise -- Let the referencing call handle the errors

    # Add query filter to standard SQL
    let sqlStatement = sfmt("%1 %2", C_SELECTSQL, getQueryFilter())

    call logger.logEvent(logger.C_LOGDEBUG, sfmt("supplier:%1", __LINE__), "getRecords", sfmt("SQL statement: %1", sqlStatement))

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
#+ Description: Returns a string representation of the storage array in JSON format
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
end function

################################################################################
#+
#+ Method: getRecordsList()
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
function getRecordsList() returns(dynamic array of supplierType)
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

    whenever any error raise -- Let the referencing call handle the errors

    prepare recordUpdate from C_UPDATESQL

    if (thisData is not null) then --> Don't allow a NULL key value for update
        # Create and array from the string to walk through...much easier than filling BDL arrays:records:elements
        let thisJSONArr = util.JSONArray.parse(thisData)
        # Walk the JSON Array and update each element to the data source
        for i = 1 to thisJSONArr.getLength() - 1 --> must account for element "{}"
            let thisJSONObj = thisJSONArr.get(i)
            # Update supplier by suppid
            call updateRecordById(thisJSONObj.toString()) returning rowsUpdated
            display "rowsUpdated: ", rowsUpdated
        end for
    end if

    if (rowsUpdated) then
        let stat = 200
    else
        let stat = 204 --> Just something to show no rows updated.  Should respond
        --> with 200 and message text "no rows updated".
    end if

    free recordUpdate

    # TODO: formulate a JSON style response for an update
    return stat

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
#+ thisData STRING : representation of record
#+
#+ @return
#+ stat INTEGER : number of rows updated
#+
public function updateRecordById(thisData string) returns(integer)
    define thisRecord supplierType
    define parseObject util.JSONObject
    define stat int

    whenever any error raise -- Let the referencing call handle the errors

    let parseObject = util.JSONObject.parse(thisData)
    call parseObject.toFGL(thisRecord)

    #For brevity in demo, only unitcost...it could be all fields
    execute recordUpdate using thisRecord.name, thisRecord.suppid -- a list from the record thisDat.suppid

    # Return the number of rows processed to report success status
    let stat = SQLCA.SQLERRD[3]

    return stat

end function

################################################################################
#+
#+ Method: processRecordInsert
#+
#+ Description: Processes a list of records to insert into the datasource returning success/fail
#+
#+ @code
#+ LET status = processRecordInsert(thisData)
#+
#+ @param
#+ thisData STRING : representation of array
#+
#+ @return
#+ stat INTEGER : HTTP status code
#+
public function processRecordsInsert(thisData string) returns(integer)
    define thisJSONArr util.JSONArray
    define thisJSONObj util.JSONObject
    define i integer

    whenever any error raise -- Let the referencing call handle the errors

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
#+ thisData STRING : representation of record
#+
#+ @return
#+ stat INTEGER : SQLCA.SQLCODE
#+
public function insertRecord(thisData) returns()
    define thisData string
    define thisRecord supplierType
    define parseObject util.JSONObject
    define stat int

    whenever any error raise -- Let the referencing call handle the errors

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

    whenever any error raise -- Let the referencing call handle the errors

    prepare recordDelete from C_DELETESQL

    if (thisData is not null) then --> Don't allow a NULL resource creation
        # Create and array from the string to walk through...much easier than filling BDL arrays:records:elements
        let thisJSONArr = util.JSONArray.parse(thisData)
        # Walk the JSON Array and delete each element from the data source
        for i = 1 to thisJSONArr.getLength()
            let thisJSONObj = thisJSONArr.get(i)
            # Delete record
            call deleteRecordById(thisJSONObj.toString())
        end for

    end if

    free recordDelete

    return 200

end function

################################################################################
#+
#+ Method: deleteRecordById
#+
#+ Description: Executes the delete of the given record in the datasource returning
#+    the number of rows processed.
#+
#+ @code
#+ LET status = deleteRecordById(thisID)
#+
#+ @param
#+ thisID STRING : record key of record
#+
#+ @return
#+ NONE
#+
public function deleteRecordById(thisData string) returns()
    define thisRecord supplierType
    define parseObject util.JSONObject
    define stat int

    whenever any error raise -- Let the referencing call handle the errors

    let parseObject = util.JSONObject.parse(thisData) --> Parse JSON string
    call parseObject.toFGL(thisRecord) --> Put JSON into FGL

    execute recordDelete using thisRecord.suppid
    let stat = SQLCA.SQLCODE

    # TODO: formulate a JSON style response for an update
    return --stat

end function

################################################################################
#+
#+ Method: getQueryFilter
#+
#+ Description: Returns the query filter in the form of a WHERE clause
#+
#+ @code
#+  LET sqlStatement = SFMT("%1 %2", _SELECTSQL, getQueryFilter())
#+
#+ @param
#+ NONE
#+
#+ @return
#+ mSqlWhere STRING : SQL where clause for query
#+
private function getQueryFilter() returns(string)
    return mSqlWhere
end function

################################################################################
#+
#+ Method: isValidQuery()
#+
#+ Description: Boolean method determining valid query filter request
#+
#+ @code
#+ IF supplier.isValidQuery(queryParameter)
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
        when "suppnum"
            let isValid = true
        otherwise
            let isValid = false
    end case

    return isValid
end function

################################################################################
#+
#+ Method: addQueryFilter()
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
        when "suppnum"
            let mSqlWhere = sfmt("%1 %2 '%3'", mSqlWhere, " AND suppid LIKE ", columnValue)
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
