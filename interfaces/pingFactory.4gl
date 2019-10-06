################################################################################
#
# FOURJS_START_COPYRIGHT(U,2015)
# Property of Four Js*
# (c) Copyright Four Js 2015, 2017. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
#
# Four Js and its suppliers do not warrant or guarantee that these samples
# are accurate and suitable for your purposes. Their inclusion is purely for
# information purposes only.
# FOURJS_END_COPYRIGHT
#
import util
import security

# HTTP stuff
import fgl http

# Application logging
import fgl logger

# Interface request object
import fgl interfaceRequest

# Resource domain
import fgl credential

# Cookie factory
import fgl cookieFactory

# Compilation database
schema officestore

# Domain record type
type pingType record
    payload string
end record

# Domain interface record
public define ping pingType

define wrappedResponse record
    code integer, # HTTP response code
    status string, # success, fail, or error
    message string, # used for fail or error message
    data string # response body or error/fail cause or exception name
end record

################################################################################
#+
#+ Method: isValidCredential
#+
#+ Description: Performs tasks to validate a user login
#+
#+ @code
#+ CALL isValidCredential() RETURNS (BOOLEAN)
#+
#+ @parameter
#+ NONE
#+
#+ @return
#+ NONE
#+
#+ @return
#+ TRUE/FALSE
#+
public function isValidCredential() returns(boolean)
    define credentialString string
    define queryException integer
    define isValid boolean = false
    define tokenizer base.StringTokenizer
    define sessionCookie, authorizationMethod, userId, password string

    # Let the referencing entity handle errors
    whenever any error raise
    let credentialString = interfaceRequest.getRequestCredential().trimWhiteSpace()

{
    case
    when ( credentialString.getLength() = 0 )

        # Check authorization cookie...
        let sessionCookie = interfaceRequest.getSessionCookie()

        IF (cookieFactory.checkCookies(sessionCookie) != true ) then
        call interfaceRequest.setResponse(
            C_HTTP_NOTAUTH,
            "ERROR",
            D_HTTPSTATUSDESC[C_HTTP_NOTAUTH],
            "Invalid session token.  Check token or re-login.")
        end if
    otherwise
        }
    if interfaceRequest.getRequestMethod() == C_HTTP_POST then
        try
            call logger.logEvent(
                logger.C_LOGDEBUG,
                sfmt("pingInterface:%1", __LINE__),
                "isValidCredential",
                sfmt("Query filter: %1", credentialString))

            # Parse for method and credentials
            let tokenizer = base.StringTokenizer.create(credentialString, " ")
            let authorizationMethod = tokenizer.nextToken()
            let credentialString = tokenizer.nextToken()

            # Parse for id and password
            let credentialString = security.Base64.ToString(credentialString)
            let tokenizer = base.StringTokenizer.create(credentialString, ":")
            let userId = tokenizer.nextToken()
            let password = tokenizer.nextToken()

            # Set the query filter values
            call credential.initQuery()
            if (userId) is null or (password) is null then
                call interfaceRequest.setResponse(
                    C_HTTP_BADREQUEST,
                    "ERROR",
                    D_HTTPSTATUSDESC[C_HTTP_BADREQUEST],
                    sfmt("[{\"message\":\"Missing valid credentials: %1)\"", credentialString))
            else
                call credential.addQueryFilter("id", userId)
            end if

            # Validate the credentials
            if not queryException and credential.isValid(password) then
                let isValid = true
                # Create a session token
                call interfaceRequest.setResponse(C_HTTP_OK, "SUCCESS", "", credential.getJSONEncoding())
            else
                # Process !isValid
                call interfaceRequest.setResponse(
                    C_HTTP_NOTAUTH, "ERROR", D_HTTPSTATUSDESC[C_HTTP_NOTAUTH], "User credentials are not valid.")
            end if

        catch
            # Return some kind of error: must use STATUS before it is reset by next code statment
            call interfaceRequest.setResponse(C_HTTP_INTERNALERROR, "ERROR", D_HTTPSTATUSDESC[C_HTTP_INTERNALERROR], "")
            call logger.logEvent(
                logger.C_LOGDEBUG,
                sfmt("pingInterface:%1", __LINE__),
                "isValidCredential",
                sfmt("SQLSTATE: %1 SQLERRMESSAGE: %2", sqlstate, sqlerrmessage))
        end try
    else
        # Process !isValid
        call interfaceRequest.setResponse(
            C_HTTP_NOTALLOWED,
            "ERROR",
            D_HTTPSTATUSDESC[C_HTTP_NOTALLOWED],
            sfmt("Method(%1) not supported.", interfaceRequest.getRequestMethod()))
    end if
#    end case

    return isValid
end function
