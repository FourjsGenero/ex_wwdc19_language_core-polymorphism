################################################################################
#
# FOURJS_START_COPYRIGHT(U,2015)
# Property of Four Js*
# (c) Copyright Four Js 2015, 2018. All Rights Reserved.
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

import fgl category

schema officestore

public type categoryType record
    catid like category.catid,
    catorder like category.catorder,
    catname like category.catname,
    catdesc like category.catdesc attributes(XMLNillable, json_null = "null"),
    catpic like category.catpic attributes(XMLNillable, json_null = "null")
end record

public define categoryInterfaceObject categoryType

################################################################################
#+
#+ Method: retrieveResource(requestPayload string) returns()
#+
#+ Description: Performs tasks to retrieve information, 1 or 1,000,000
#+
#+ @code
#+ CALL retrieveResource(requestPayload string) returns(string)
#+
#+ @parameter
#+ requestPayload STRING
#+
#+ @return
#+ NONE
#+
public function (this categoryType) retrieveResource(requestPayload string) returns()
    define thisJSONArr util.JSONArray
    define i, queryException integer

    define query dynamic array of record
        keyName string,
        keyValue string
    end record

    whenever any error raise  -- Let the referencing call handle the errors

    try
        let thisJSONArr = util.JSONArray.parse(requestPayload)

        call logger.logEvent(
            logger.C_LOGDEBUG, sfmt("categoryInterface:%1", __LINE__), "getResource", sfmt("Query filter: %1", requestPayload))

        call thisJSONArr.toFGL(query)

        # Set the query filter values
        call category.initQuery()

        for i = 1 to query.getLength()
            # If the filter key(field) is valid, add to the key/value to the query filter
            if category.isValidQuery(query[i].keyName) then
                call category.addQueryFilter(query[i].keyName, query[i].keyValue)
            else
                # Handle unkown/bad parameters
                call interfaceRequest.setResponse(C_HTTP_BADREQUEST, "ERROR", "unkown/bad parameters", requestPayload)
                let queryException = true
            end if
        end for

        if not queryException then
            # Execute resource query
            call category.getRecords()

            # Set response data
            call interfaceRequest.setResponse(C_HTTP_OK, "SUCCESS", "", category.getJSONEncoding())
        end if

    catch
        # Return some kind of error: must use STATUS before it is reset by next code statment
        call interfaceRequest.setResponse(
            C_HTTP_INTERNALERROR, "ERROR", D_HTTPSTATUSDESC[C_HTTP_INTERNALERROR], sfmt("Query status: %1", STATUS))
        call logger.logEvent(
            logger.C_LOGDEBUG,
            sfmt("categoryInterface:%1", __LINE__),
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
public function (this categoryType) createResource(requestPayload string) returns()
    whenever any error raise  -- Let the referencing call handle the errors

    # Method not allowed for resource
    call interfaceRequest.setResponse(
        C_HTTP_NOTALLOWED, "ERROR", sfmt("Method(%1) not allowed.", interfaceRequest.getRequestMethod()), "[{}]")
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
public function (this categoryType) updateResource(requestPayload string) returns()
    whenever any error raise  -- Let the referencing call handle the errors

    # Method not allowed for resource
    call interfaceRequest.setResponse(
        C_HTTP_NOTALLOWED, "ERROR", sfmt("Method(%1) not allowed.", interfaceRequest.getRequestMethod()), "[{}]")
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
public function (this categoryType) deleteResource(requestPayload string) returns()
    whenever any error raise  -- Let the referencing call handle the errors

    # Method not allowed for resource
    call interfaceRequest.setResponse(
        C_HTTP_NOTALLOWED, "ERROR", sfmt("Method(%1) not allowed.", interfaceRequest.getRequestMethod()), "[{}]")
    return
end function
