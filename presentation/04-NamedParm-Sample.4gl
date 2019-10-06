# Property of Four Js*
# (c) Copyright Four Js 1995, 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

MAIN
    CALL func1(id: 999, description: "This is a demo", rate: 1.34)

    --> name does not match
    CALL func1(id:999, desc: “This is a demo”, rate: 1.34)
    --> order does not match
    CALL func1(description: “This is a demo”, rate: 1.34, id:999)
    --> omitted "rate"
    CALL func1(id:999, description: “This is a demo”)

END MAIN

FUNCTION func1(id INTEGER, description STRING, rate FLOAT)
    DEFINE sb base.StringBuffer

    --> Can be used with built-in libraries
    LET sb = base.StringBuffer.create()
    CALL sb.append(str:description)
    CALL sb.replace(oldStr:"foo", newStr:"bar", occurrences:0)

    DISPLAY id, description, rate
END function








