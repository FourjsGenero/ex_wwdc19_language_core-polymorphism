# Property of Four Js*
# (c) Copyright Four Js 1995, 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

TYPE cust_type RECORD
    pkey INTEGER,
    nm VARCHAR(50),
    addr VARCHAR(100),
    crea DATE
END RECORD

MAIN

    DEFINE rec cust_type

    LET rec.pkey = 834
    LET rec.nm = "Mike Torn"
    LET rec.crea = MDY(12, 24, 2018)

    -- Legacy call passing all record members on the stack
    CALL func_rec_by_val(rec.*) -- .* expands all record members
    DISPLAY "1:", rec.*

    -- Passing record as reference allows to modify it
    CALL func_rec_by_ref(rec) -- Note that .* is not used here!
    DISPLAY "2:", rec.*

END MAIN

FUNCTION func_rec_by_val(r cust_type)
    INITIALIZE r.* TO NULL
    LET r.pkey = 999
    LET r.nm = "<undefined>"
END FUNCTION

FUNCTION func_rec_by_ref(r cust_type INOUT)
    INITIALIZE r.* TO NULL
    LET r.pkey = 999
    LET r.nm = "<undefined>"
END FUNCTION













