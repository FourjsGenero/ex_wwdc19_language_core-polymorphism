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

# HTTP stuff
import fgl http

# Application logging
import fgl logger

# Interface request object
import fgl interfaceRequest

# Supplier domain
import fgl supplier

# Compilation database
schema officestore

# Domain record type
type supplierType record
    suppid like supplier.suppid,
    name like supplier.name,
    sustatus like supplier.sustatus,
    addr1 like supplier.addr1 attributes(XMLNillable, json_null = "null"),
    addr2 like supplier.addr2 attributes(XMLNillable, json_null = "null"),
    city like supplier.city attributes(XMLNillable, json_null = "null"),
    state like supplier.state attributes(XMLNillable, json_null = "null"),
    zip like supplier.zip attributes(XMLNillable, json_null = "null"),
    phone like supplier.phone attributes(XMLNillable, json_null = "null")
end record

# Domain interface record
public define supplierInterfaceObject supplierType

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
public function (this supplierType) retrieveResource(requestPayload string) returns()

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
            logger.C_LOGDEBUG, sfmt("supplierInterface:%1", __LINE__), "getResource", sfmt("Query filter: %1", requestPayload))

        call thisJSONArr.toFGL(query)

        # Set the query filter values
        call supplier.initQuery()

        for i = 1 to query.getLength()
            # If the filter key(field) is valid, add to the key/value to the query filter
            if supplier.isValidQuery(query[i].keyName) then
                call supplier.addQueryFilter(query[i].keyName, query[i].keyValue)
            else
                # Handle unkown/bad parameters
                call interfaceRequest.setResponse(C_HTTP_BADREQUEST, "ERROR", "unkown/bad parameters", requestPayload)
                let queryException = true
            end if
        end for

        # If no exceptions in the query request, retrieve the resource
        if not queryException then
            # Execute resource query
            call supplier.getRecords()

            # Set response data
            call interfaceRequest.setResponse(C_HTTP_OK, "SUCCESS", "", supplier.getJSONEncoding())
        end if

    catch
        # Return some kind of error: must use STATUS before it is reset by next code statment
        call interfaceRequest.setResponse(
            C_HTTP_INTERNALERROR, "ERROR", D_HTTPSTATUSDESC[C_HTTP_INTERNALERROR], sfmt("Query status: %1", STATUS))
        call logger.logEvent(
            logger.C_LOGDEBUG,
            sfmt("supplierInterface:%1", __LINE__),
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
public function (this supplierType) createResource(requestPayload string) returns()
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
public function (this supplierType) updateResource(requestPayload string) returns()
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
public function (this supplierType) deleteResource(requestPayload string) returns()
    whenever any error raise  -- Let the referencing call handle the errors

    # Method not allowed for resource
    call interfaceRequest.setResponse(
        C_HTTP_NOTALLOWED, "ERROR", sfmt("Method(%1) not allowed.", interfaceRequest.getRequestMethod()), "[{}]")
    return
end function
