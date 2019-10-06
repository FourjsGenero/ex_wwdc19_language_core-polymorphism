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
#+
#+ This module implements resource interface methods for the officestore
#+ domain with the use of domain resource factories.  The concept is that a
#+ factory knows the resources required to create a product.  The factory
#+ invokes the resource methods to mine the raw materials(data) and create the
#+ product(response).
#+
#+ A configurator DICTIONARY is implemented to setup the factory configuration
#+ resources to be referenced by resource name.  The functions create a dictionary
#+ of processing functions allowed to be called by the resource method(GET, PUT,
#+ POST, etc)
#+
import util
import com
import os

# Logging utility
import fgl logger

# HTTP stuff
import fgl http

# REST interface request
import fgl interfaceRequest

# Service INTERFACEs
import fgl categoryInterface
import fgl supplierInterface
import fgl countryInterface

# Resource factory interface(basic C.R.U.D. functionality)
type resourceInterface interface
    createResource(requestPayload string) returns(),
    retrieveResource(requestPayload string) returns(),
    updateResource(requestPayload string) returns(),
    deleteResource(requestPayload string) returns()
end interface

# Dictionary of resource responses
define interfaceResponse dictionary of resourceInterface

# Response interface initializer
function initResponseInterface()
    let interfaceResponse["categories"] = categoryInterfaceObject
    let interfaceResponse["suppliers"] = supplierInterfaceObject
    let interfaceResponse["countries"] = countryInterfaceObject
end function

################################################################################
#+
#+ Method: processRequest()
#+
#+ Description: Process the requested resource
#+
#+ @code
#+ CALL process()
#+
#+ @parameter
#+ NONE
#+
#+ @return
#+ NONE
#+
public function processRequest() returns()
    define statusCode integer
    define requestResource, requestMethod, requestPayload, sessionCookie, applicationError string

    # Initialize the response
    call initResponseInterface()

    # Get processing values and assume success(200) unless otherwise reset
    let statusCode = C_HTTP_OK
    let requestResource = interfaceRequest.getRestResource()
    let sessionCookie = interfaceRequest.getSessionCookie()
    let requestMethod = interfaceRequest.getRequestMethod()

    # Check if resource is valid
    if (isValidResource(requestResource)) then

        # Get the request payload(data/query)
        let requestPayload = interfaceRequest.getRequestPayload()

        # Process the request by named resource
        case requestMethod
            when C_HTTP_GET
                call interfaceResponse[requestResource].retrieveResource(requestPayload)

            when C_HTTP_POST
                call interfaceResponse[requestResource].createResource(requestPayload)

            when C_HTTP_PUT
                call interfaceResponse[requestResource].updateResource(requestPayload)

            when C_HTTP_DELETE
                call interfaceResponse[requestResource].deleteResource(requestPayload)

            otherwise
                # Method not allowed with web service
                let applicationError = sfmt("Method(%1) not allowed.", requestMethod)
                call interfaceRequest.setResponse(C_HTTP_NOTALLOWED, "ERROR", applicationError, "[{}]")
                call logger.logEvent(logger.C_LOGMSG, ARG_VAL(0), sfmt("Line: %1", __LINE__), applicationError)
        end case

    else
        # Resource not found in web service
        let applicationError = sfmt("Resource not found or invalid path.", requestResource)
        call interfaceRequest.setResponse(C_HTTP_NOTFOUND, "ERROR", applicationError, "[{}]")
        call logger.logEvent(logger.C_LOGMSG, ARG_VAL(0), sfmt("Line: %1", __LINE__), applicationError)
    end if

    return
end function

################################################################################
#+
#+ Method: isValidResource()
#+
#+ Description: Determines if the resource is valid for the interface
#+
#+ @code
#+ CALL isValidResource(this STRING)
#+
#+ @parameter
#+ this : STRING : name of interface resource
#+
#+ @return
#+ BOOLEAN

private function isValidResource(this string) returns(boolean)
    return interfaceResponse.contains(this)
end function
