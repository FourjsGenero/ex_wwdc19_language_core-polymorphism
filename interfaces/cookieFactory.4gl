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
import com
import security

# GWS Helpers
import fgl WSHelper

# Logging utility
import fgl logger

# HTTP Utility
import fgl http

# Authorization cookies
import fgl credential

# Cookie storage variable
define cookieBox WSServerCookiesType

################################################################################
#+
#+ Method: bakeCookies()
#+
#+ Description: Creates a session cookie for WSHelper
#+
#+ @code
#+ CALL bakeCookies(cookieName STRING, base STRING, http BOOLEAN)
#+
#+ @parameter
#+ cookieName STRING
#+ base STRING
#+ http BOOLEAN
#+
#+ @return
#+ NONE
#+ TODO:Perhaps there is more than one cookie; if so, send an array
#+
function bakeCookies(cookieName string, base string, http boolean) returns()
    define expiration datetime year to second

    call logger.logEvent(logger.C_LOGDEBUG, sfmt("cookieFactory:%1", __LINE__), "bakeCookies", "Baking a cookie")

    let expiration = current + interval(1) day to day

    let cookieBox[1].NAME = cookieName
    let cookieBox[1].path = base
    let cookieBox[1].httpOnly = http
    let cookieBox[1].expires = expiration

    # get a token for the cookie
    # set the token in the cookie record

    let cookieBox[1].VALUE = credential.createSessionToken(expiration)
    # ? other cookie values

    return
end function

################################################################################
#+
#+ Method: getCookies()
#+
#+ Description: Returns pointer to the session cookie(s) for WSHelper
#+
#+ @code
#+ CALL getCookies() RETURNS WSServerCookiesType
#+
#+ @parameter
#+ NONE
#+
#+ @return
#+ Return: a box(array pointer) of cookies
#+
function getCookies() returns(WSServerCookiesType) -- box of cookies

    call logger.logEvent(logger.C_LOGDEBUG, sfmt("cookieFactory:%1", __LINE__), "getCookies", "Getting a cookie")

    return cookieBox
end function

################################################################################
#+
#+ Method: checkCookie()
#+
#+ Description: Is the cookie good?
#+
#+ @code
#+ CALL checkCookies(thisCookieToken STRING) RETURNS BOOLEAN
#+
#+ @parameter
#+ NONE
#+
#+ @return
#+ BOOLEAN    TRUE=cookie hasn't expired
#+            FALSE=cookie is past it's prime(expired)
#+
function checkCookies(thisCookieToken string) returns(boolean)
    define clockTime datetime year to second
    define isValidCookie boolean

    call logger.logEvent(
        logger.C_LOGDEBUG, sfmt("cookieFactory:%1", __LINE__), "checkCookies", "Checking if a cookie is good(not expired)")

    let clockTime = current

    # Query the cookie token
    # Is it not found or expired?
    select token from authtokens where token = thisCookieToken and expires > clockTime

    if SQLCA.sqlcode == 0 then
        let isValidCookie = true # Found valid token
    end if

    return isValidCookie
end function

################################################################################
#+
#+ Method: eatCookies()
#+
#+ Description: Deletes a session cookie(token)
#+
#+ @code
#+ CALL eatCookies(thisCookie STRING)
#+
#+ @parameter
#+ thisCookie STRING
#+
#+ @return
#+ NONE
#+
function eatCookies(thisCookie string) returns()
    call logger.logEvent(logger.C_LOGDEBUG, sfmt("cookieFactory:%1", __LINE__), "eatCookies", "Mmmmm, COOKIE!")
    # delete the cookie token

    return
end function
