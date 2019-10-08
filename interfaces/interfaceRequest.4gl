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
import com
import xml
import os
import util

# Web services helper library
import fgl WSHelper

# Application logging
import fgl logger

# HTTP defintions
import fgl http

# Incoming request
private define mThisRequest com.HttpServiceRequest

# Request type definition
type requestInfoType record
    url string, # Request URL
    method string, # HTTP method
    contentType string, # check the Content-Type
    inputFormat string, # short word for Content Type
    acceptFormat string, # check which format the client accepts
    outputFormat string, # short word for Accept
    scheme string,
    host string,
    port string,
    resource string, # request resource
    path string,
    sessionCookie string,
    query string, # the query string
    items dynamic array of itemType,
    credential string, # client login credential
    payload string # Insert/Update payload
end record

public type itemType record
    keyName string,
    keyValue string
end record

# Class request variable
private define mRequestInfo requestInfoType

# Response type definition
public type responseType record
    code integer, # HTTP response code
    status string, # success, fail, or error
    description string, # used for fail or error message
    data string # response body or error/fail cause or exception name
end record

# Response variable
private define mWrappedResponse responseType

private define mBaseUri string

################################################################################
#+
#+ Method: setRestRequestInfo
#+
#+ Description: Creates an object for the incoming REST request
#+
#+ @code
#+ CALL setRestRequest(request)
#+
#+ @param request : com.HTTPServiceRequest - REST style request for a resource
#+
#+ @return NONE
#+
function setRestRequestInfo(incomingRequest com.HttpServiceRequest) returns()
    define requestTokenizer base.StringTokenizer
    define i integer

    # Set base URI for parsing: default is for standalone GAS("/ws/r/rest/"); otherwise,
    # pointing to dispatcher (ex. "/genero/ws/r/rest/" )
    let mBaseUri = fgl_getenv("GWS_BASEURI")
    let mBaseUri = iif(mBaseUri is not null, mBaseUri, "/ws/r/rest/")

    # Store the current request
    let mThisRequest = incomingRequest

    # Initialize request record
    initialize mRequestInfo.* to null

    # Split the REST request components
    let mRequestInfo.url = mThisRequest.getUrl()
    call WSHelper.SplitURL(mRequestInfo.url)
        returning mRequestInfo.scheme, mRequestInfo.host, mRequestInfo.port, mRequestInfo.path, mRequestInfo.query

    # Populate the query items
    call mThisRequest.getUrlQuery(mRequestInfo.items)

    # Does the path(/ws/r/xcf/country) contain the baseUri(/ws/r/rest/)
    # The resource substring start position can derive from length of baseUri constant rather than looping
    call logger.logEvent(
        logger.C_LOGDEBUG,
        ARG_VAL(0),
        sfmt("Line: %1", __LINE__),
        sfmt("requestTokenizer: %1 ", mRequestInfo.path.subString(mBaseUri.getLength(), mRequestInfo.path.getLength())))

    let i = mRequestInfo.path.getIndexOf(mBaseUri, 1)

    if i then
        if mRequestInfo.path.getIndexOf(mBaseUri, 1) then
            let requestTokenizer =
                base.StringTokenizer.create(
                    mRequestInfo.path.subString(i + mBaseUri.getLength(), mRequestInfo.path.getLength()), "/")
            let mRequestInfo.resource = requestTokenizer.nextToken()

            call logger.logEvent(
                logger.C_LOGDEBUG, ARG_VAL(0), sfmt("Line: %1", __LINE__), sfmt("requestTokenizer: %1", mRequestInfo.path))
            # Check for URL query token http://server/ws/r/rest/countries/{id}
            # Here we transform the {id} as if it were provided as query string:
            # http://server/ws/r/rest/countries?id="value"
            if requestTokenizer.hasMoreTokens() then
                call mRequestInfo.items.appendElement()
                let i = mRequestInfo.items.getLength()
                let mRequestInfo.items[i].keyName = "id"
                let mRequestInfo.items[i].keyValue = requestTokenizer.nextToken()
            end if
            let mRequestInfo.payload = util.JSON.stringify(mRequestInfo.items)
        end if
    end if

    # Get authorization cookie...
    let mRequestInfo.sessionCookie = mThisRequest.findRequestCookie("GeneroAuthZ")

    # Set request method
    let mRequestInfo.method = mThisRequest.getMethod()

    # Set the request payload
    if mRequestInfo.method = "PUT" or mRequestInfo.method = "POST" then
        let mRequestInfo.payload = mThisRequest.readTextRequest()
    end if

    # Get and process Content-Type headers
    let mRequestInfo.contentType = mThisRequest.getRequestHeader("Content-Type")
    call setInputFormat(mRequestInfo.contentType)
    call setOutputFormat(mRequestInfo.contentType)

    # Officestore credentials
    let mRequestInfo.credential = mThisRequest.getRequestHeader("Officestore-Credential")

    return

end function

################################################################################
#+
#+ Method: sendRequestResponse
#+
#+ Description: Returns the response for the current request
#+
#+ @code
#+ CALL setRestRequest(httpStatus integer, statusDescription string, factoryResponse string)
#+
#+ @param httpStatus : INTEGER - Standard HTTP status value
#+ @param statusDescription : STRING - SUCCESS/ERROR/FAILURE
#+ @param factoryResponse : STRING - XML/JSON formatted response payload
#+
#+ @return NONE
#+
function sendRequestResponse(httpStatus integer, statusDescription string, factoryResponse string) returns()
    # Send the request response
    # The productImages resource requires a "sendFileResponse"
    if getRestResource() = "productImages" then
        if httpStatus = C_HTTP_OK then
            display "this file: ", os.Path.join(fgl_GETENV("IMAGEPATH"), factoryResponse)
            call mThisRequest.sendFileResponse(httpStatus, null, os.Path.join(fgl_GETENV("IMAGEPATH"), factoryResponse))
        else
            call mThisRequest.sendTextResponse(C_HTTP_NOTFOUND, null, "Image not found")
        end if
    else
        # Description is NULL for default value based on status code; otherwise a message can be supplied
        call mThisRequest.sendTextResponse(httpStatus, statusDescription, factoryResponse)
    end if

    return
end function

################################################################################
#+
#+ Method: initRequestResponse
#+
#+ Description: Returns the response for the current request
#+
#+ @code
#+ CALL initRequestResponse()
#+
#+ @param NONE
#+
#+ @return NONE
#+
function initRequestResponse() returns()
    call mThisRequest.setResponseHeader("Content-Type", getRequestOutputFormat())
    call mThisRequest.setResponseHeader("Cache", "no-cache")
    return
end function

################################################################################
#+
#+ Method: setResponse
#+
#+ Description: Returns the response for the current request
#+
#+ @code
#+ CALL setResponse(statusCode string, statusClass string, statusDesc string, responseData string)
#+
#+ @param statusCode : STRING - Standard HTTP status value
#+ @param statusClass : STRING - SUCCESS/ERROR/FAILURE
#+ @param statusDesc : STRING - Error message
#+ @param responseData : STRING - XML/JSON formatted response payload
#+
#+ @return NONE
#+
function setResponse(statusCode string, statusClass string, statusDesc string, responseData string) returns()

    let mWrappedResponse.code = statusCode
    let mWrappedResponse.status = statusClass
    let mWrappedResponse.description = statusDesc
    let mWrappedResponse.data = responseData

    return
end function

################################################################################
#+
#+ Method: setResponseCookies
#+
#+ Description: Adds cookie values to the request response
#+
#+ @code
#+ CALL setResponseCookies(theseCookies WSServerCookiesType)
#+
#+ @param statusCode : ARRAY - WSServerCookiesType
#+
#+ @return NONE
#+
function setResponseCookies(theseCookies WSServerCookiesType) returns()
    call mThisRequest.setResponseCookies(theseCookies)
    return
end function

################################################################################
#+
#+ Mutator for request input content type
#+
#+ TODO: for future in determining request format(JSON/XML)
#+
function setInputFormat(contentHeader string) returns()

    if contentHeader.getIndexOf("/xml", 1) then
        let mRequestInfo.inputFormat = "XML"
    else
        let mRequestInfo.inputFormat = "JSON"
    end if

    return
end function

################################################################################
#+
#+ Mutator for request output type
#+
#+ TODO: for future in determining response format(JSON/XML)
#+
function setOutputFormat(contentHeader string) returns()

    if contentHeader.getIndexOf("/xml", 1) then
        let mRequestInfo.outputFormat = "XML"
    else
        let mRequestInfo.outputFormat = "JSON"
    end if

    return
end function

function getResponse() returns(responseType)
    return mWrappedResponse.*
end function

################################################################################
#
# General accessor methods for the REST request informiation
#
function getRequestRequest() returns(com.HttpServiceRequest)
    return mThisRequest
end function

function getRequestUrl() returns(string)
    return mRequestInfo.url
end function

function getRequestScheme() returns(string)
    return mRequestInfo.scheme
end function

function getRequestHost() returns(string)
    return mRequestInfo.host
end function

function getRequestPort() returns(string)
    return mRequestInfo.port
end function

function getRequestPath() returns(string)
    return mRequestInfo.path
end function

function getRequestQuery() returns(string)
    return mRequestInfo.query
end function

function getSessionCookie() returns(string)
    return mRequestInfo.sessionCookie
end function

function getRestResource() returns(string)
    return mRequestInfo.resource
end function

function getRequestMethod() returns(string)
    return mRequestInfo.method
end function

function getCurrentRequest() returns(com.HttpServiceRequest)
    return mThisRequest
end function

function getRequestQueryItems() returns(dynamic array of itemType)
    return mRequestInfo.items
end function

function getRequestCredential() returns(string)
    return mRequestInfo.credential
end function

function getRequestOutputFormat() returns(string)
    return mRequestInfo.outputFormat
end function

function getRequestPayload() returns(string)
    return mRequestInfo.payload
end function
