# Property of Four Js*
# (c) Copyright Four Js 1995, 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

TYPE type1 RECORD
    pkey INTEGER,
    nm VARCHAR(50),
    addr VARCHAR(100),
    crea DATE,
    orders DYNAMIC ARRAY OF INTEGER
END RECORD

MAIN
    DEFINE rec1
        type1 -- All members are initialized
        = (pkey: 834,
            nm: "Mike Torn",
            addr: "5 Big Mountain St.",
            crea: MDY(12, 24, 1997),
            orders:[234, 435, 456])
    DEFINE rec2
        type1 -- Some members are initialized
        = (pkey: 0, nm: "<undefined>", addr: "<undefined>")

    DISPLAY rec1.nm, rec1.crea
    DISPLAY rec1.orders.getLength()

    DISPLAY rec2.pkey, rec2.nm

END MAIN
