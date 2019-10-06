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
#+ This module implements tabname class information handling
#+
#+ This code uses the 'officestore' database tables.
#+ tabname input, query and list handling functions are defined here.
#+

import util
import com
import security

# Logging utility
import fgl logger

# Web services helper library
import fgl WSHelper

# Default compile schema
schema officestore

#
# Standard SQL statement CONSTANTs
#
constant C_SELECTSQL = "SELECT login, firstname, lastname, image FROM credentials"
#CONSTANT C_UPDATESQL = "UPDATE tabname  SET firstname = ?, lastname = ? WHERE userid = ?"
#CONSTANT C_INSERTSQL = "INSERT INTO credentials VALUES (0, ?, ?, ?, ?, ?)"
constant C_DELETESQL = "DELETE FROM credentials WHERE login = ?"

#
# User type definitions
#
type recordType record like credentials.*

public type loginType record
    login varchar(255),
    password varchar(255)
end record

#
# Module variables
#
define mQuery record
    id string,
    fname string,
    lname string
end record

define mSqlWhere string

# Cookie type defintion from WSHelper
type cookiesType WSHelper.WSServerCookiesType

# Cookie jar
define mCookies cookiesType

public define mRecords dynamic array of recordType

private constant C_COOKIE_DURATION = interval(1) day to day

################################################################################
#+
#+ Method: addQueryFilter
#+
#+ Description: Add a valid query key and value to the standard query filter(WHERE 1=1)
#+
#+ @code
#+  CALL account.addQueryFilter(columnKey, columnValue)
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
            let mSqlWhere = sfmt("%1 %2 '%3'", mSqlWhere, " AND login LIKE ", columnValue)
    end case

    return
end function
################################################################################
#+
#+ Method: getQueryFilter
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
private function getQueryFilter() returns(string)
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
        when "password"
            let isValid = true
        otherwise
            let isValid = false
    end case

    return isValid
end function

################################################################################
#+
#+ Method: isValid
#+
#+ Description: Check in User if given user exists, if password is valid
#+  and return its ID (or null in case of error)
#+
#+ @code
#+ CALL getJSONEncoding()
#+
#+ @param
#+ userPassword STRING
#+
#+ @return
#+ BOOLEAN TRUE/FALSE
#+
################################################################################

function isValid(userPassword string) returns(boolean)
    define userIsValid boolean
    define hashPassword string
    define sqlstatement string
    define i integer

    # Add query filter to standard SQL
    let sqlStatement = "SELECT password, first_name, last_name, image_id FROM credentials " || getQueryFilter()

    call logger.logEvent(logger.C_LOGDEBUG, sfmt("credential:%1", __LINE__), "isValid", sfmt("SQL statement: %1", sqlStatement))

    call mRecords.clear()
    declare curs cursor from sqlStatement --"SELECT password, first_name, last_name FROM credentials " || getQueryFilter()
    open curs

    let i = 1
    fetch curs into hashPassword, mRecords[1].first_name, mRecords[1].last_name, mRecords[1].image_id
    if SQLCA.SQLCODE = 0 then
        let userIsValid = security.BCrypt.CheckPassword(userPassword, hashPassword)
    end if

    close curs
    free curs

    return userIsValid
end function

#+
#+ Module mutators
#+
function initQuery() returns()
    initialize mQuery.* to null
    let mSqlWhere = "WHERE 1=1"
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
public function getJSONEncoding() returns(string)
    return util.JSON.stringify(mRecords)
end function

################################################################################
#+
#+ Method: init
#+
#+ Description: Clears the sample storage array of all records
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
public function init() returns()
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
public function getRecordsList() returns(dynamic array of recordType)
    return mRecords
end function

################################################################################
#+
#+ Method: createSessionToken()
#+
#+ Description: Creates a new session cookie(token) in storage
#+
#+ @code
#+ LET sessionToken = getSessionToken(tokenExpiration DATETIME YEAR TO SECOND)
#+
#+ @paramter
#+ tokenExpiration DATETIME YEAR TO SECOND
#+
#+ @return
#+ newToken STRING
#+
function createSessionToken(tokenExpiration datetime year to second) returns varchar(255)
    define newToken varchar(255)

    let newToken = security.randomGenerator.createUUIDString()

    # Clean up expired tokens
    delete from authtokens where expires < current year to second

    # Create a new token
    insert into authtokens(token, expires) values(newToken, tokenExpiration)

    if SQLCA.sqlcode != 0 then
        let newToken = null
    end if

    return newToken
end function

################################################################################
#+
#+ Method: deleteSessionToken()
#+
#+ Description: Removes a new session cookie(token) in storage
#+
#+ @code
#+ CALL deleteSessionToken(thisToken VARCHAR(255))
#+
#+ @paramter
#+ thisToken STRING
#+
#+ @return
#+ Status : SQLCA.SQLCODE
#+
function deleteSessionToken(thisToken varchar(255)) returns(integer)
    delete from authtokens where token = thisToken
    return sqlca.SQLCODE
end function
