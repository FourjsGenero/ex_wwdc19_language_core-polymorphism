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


import util

import fgl http
import fgl logger
import fgl interfaceRequest

import fgl country

schema officestore

public type countryType record
    code like country.code,
    codedesc like country.codedesc
end record

public define countryInterfaceObject countryType

public function (this countryType) retrieveResource(requestPayload string) returns()
    define thisJSONArr util.JSONArray
    define i, queryException integer

    define query dynamic array of record
        keyName string,
        keyValue string
    end record

    whenever any error raise -- Let the referencing call handle the errors

    try
        if (requestPayload is not null) then
            #let thisJSONArr = util.JSONArray.parse(interfaceRequest.getRequestPayload())
            let thisJSONArr = util.JSONArray.parse(requestPayload)

            call logger.logEvent(
                logger.C_LOGDEBUG, sfmt("countryInterface:%1", __LINE__), "getResource", sfmt("Query filter: %1", requestPayload))

            call thisJSONArr.toFGL(query)
        end if

        # Set the query filter values
        call country.initQuery()

        for i = 1 to query.getLength()
            # If the filter key(field) is valid, add to the key/value to the query filter
            if country.isValidQuery(query[i].keyName) then
                call country.addQueryFilter(query[i].keyName, query[i].keyValue)
            else
                # Handle unkown/bad parameters
                call interfaceRequest.setResponse(C_HTTP_BADREQUEST, "ERROR", "unkown/bad parameters", requestPayload)
                let queryException = true
            end if
        end for

        if not queryException then
            # Execute resource query
            call country.getRecords()

            # Set response data
            call interfaceRequest.setResponse(C_HTTP_OK, "SUCCESS", "", country.getJSONEncoding())
        end if

    catch
        # Return some kind of error: must use STATUS before it is reset by next code statment
        call interfaceRequest.setResponse(
            C_HTTP_INTERNALERROR, "ERROR", D_HTTPSTATUSDESC[C_HTTP_INTERNALERROR], sfmt("Query status: %1", STATUS))
        call logger.logEvent(
            logger.C_LOGDEBUG,
            sfmt("countryInterface:%1", __LINE__),
            "getResource",
            sfmt("SQLSTATE: %1 SQLERRMESSAGE: %2", sqlstate, sqlerrmessage))
    end try

    return
end function

################################################################################
#+
#+ Method: createResource(requestPayload string) returns()
#+
#+ Description: Performs tasks to insert resource information
#+
#+ @code
#+ CALL createResource(requestPayload string) returns()
#+
#+ @parameter
#+ requestPayload STRING
#+
#+ @return
#+ NONE
#+
public function (this countryType) createResource(requestPayload string) returns()
    define tempString string

    whenever any error raise -- Let the referencing call handle the errors

    try
        call logger.logEvent(
            logger.C_LOGDEBUG, sfmt("countryInterface:%1", __LINE__), "createResource", sfmt("Insert payload: %1", requestPayload))

        # Process the update payload
        call country.init()
        call country.initQuery()

        call interfaceRequest.setResponse(country.processRecordsInsert(requestPayload), "SUCCESS", "", country.getJSONEncoding())

    catch
        # Return some kind of error: must use STATUS before it is reset by next code statment
        let tempString = sfmt("Insert status: %1", STATUS)
        call interfaceRequest.setResponse(C_HTTP_INTERNALERROR, "ERROR", "resource insert failed", tempString)
        call logger.logEvent(
            logger.C_LOGDEBUG,
            sfmt("countryInterface:%1", __LINE__),
            "createResource",
            sfmt("SQLSTATE: %1 SQLERRMESSAGE: %2", sqlstate, sqlerrmessage))
    end try

    return
end function

################################################################################
#+
#+ Method: updateResource(requestPayload string) returns()
#+
#+ Description: Performs tasks to update resource information
#+
#+ @code
#+ CALL updateResource(requestPayload string) returns()
#+
#+ @parameter
#+ requestPayload STRING
#+
#+ @return
#+ NONE
#+
public function (this countryType) updateResource(requestPayload string) returns()
    define tempString string

    whenever any error raise -- Let the referencing call handle the errors

    try
        call logger.logEvent(
            logger.C_LOGDEBUG, sfmt("countryInterface:%1", __LINE__), "updateResource", sfmt("Update payload: %1", requestPayload))

        # Process the update payload
        call country.init()
        call country.initQuery()

        call interfaceRequest.setResponse(country.processRecordsUpdate(requestPayload), "SUCCESS", "", country.getJSONEncoding())

    catch
        # Return some kind of error: must use STATUS before it is reset by next code statment
        let tempString = sfmt("Update status: %1", STATUS)
        call interfaceRequest.setResponse(C_HTTP_INTERNALERROR, "ERROR", "resource update failed", tempString)
        call logger.logEvent(
            logger.C_LOGDEBUG,
            sfmt("countryInterface:%1", __LINE__),
            "updateResource",
            sfmt("SQLSTATE: %1 SQLERRMESSAGE: %2", sqlstate, sqlerrmessage))

    end try

    return
end function

################################################################################
#+
#+ Method: deleteResource(requestPayload string) returns()
#+
#+ Description: Performs tasks to delete resource information
#+
#+ @code
#+ CALL deleteResource(requestPayload string) returns()
#+
#+ @parameter
#+ requestPayload STRING
#+
#+ @return
#+ NONE
#+
public function (this countryType) deleteResource(requestPayload string) returns()
    define tempString string

    whenever any error raise -- Let the referencing call handle the errors

    try
        call logger.logEvent(
            logger.C_LOGDEBUG, sfmt("countryInterface:%1", __LINE__), "deleteResource", sfmt("Delete record: %1", requestPayload))

        # Process the update payload
        call country.init()
        call country.initQuery()

        call interfaceRequest.setResponse(country.processRecordsDelete(requestPayload), "SUCCESS", "", country.getJSONEncoding())

    catch
        # Return some kind of error: must use STATUS before it is reset by next code statment
        let tempString = sfmt("Insert status: %1", STATUS)
        call interfaceRequest.setResponse(C_HTTP_INTERNALERROR, "ERROR", "resource delete failed", tempString)
        call logger.logEvent(
            logger.C_LOGDEBUG,
            sfmt("countryInterface:%1", __LINE__),
            "deleteResource",
            sfmt("SQLSTATE: %1 SQLERRMESSAGE: %2", sqlstate, sqlerrmessage))

    end try

    return
end function
