# Property of Four Js*
# (c) Copyright Four Js 1995, 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

PUBLIC TYPE cust_type RECORD
    pkey INTEGER,
    nm VARCHAR(50),
    addr VARCHAR(100),
    crea DATETIME YEAR TO FRACTION(5),
    modi DATETIME YEAR TO FRACTION(5),
    orders DYNAMIC ARRAY OF INTEGER
END RECORD

PUBLIC FUNCTION (r cust_type) initializeWithDefaults(name STRING) RETURNS ()
    INITIALIZE r.* TO NULL
    LET r.pkey = 999
    LET r.nm = name
    LET r.addr = "<undefined>"
    LET r.crea = CURRENT
END FUNCTION

PUBLIC FUNCTION (r cust_type) setAddress(addr STRING) RETURNS ()
    LET r.modi = CURRENT
    LET r.addr = addr
END FUNCTION

PUBLIC FUNCTION (r cust_type) addOrder(ordid INTEGER) RETURNS ()
    LET r.modi = CURRENT
    CALL r.orders.appendElement()
    LET r.orders[r.orders.getLength()] = ordid
END FUNCTION

PUBLIC FUNCTION (r cust_type) getOrderCount() RETURNS INTEGER
    RETURN r.orders.getLength()
END FUNCTION

FUNCTION main()

    DEFINE c1 cust_type

    --> Call to initializer method
    CALL c1.initializeWithDefaults("Mike Torn")
    DISPLAY c1.pkey, c1.nm
    --> Call to setter method
    CALL c1.setAddress("5 Matchita St.")
    DISPLAY c1.modi, c1.addr
    --> Calls to mutator methods
    CALL c1.addOrder(485)
    CALL c1.addOrder(948)
    DISPLAY c1.modi, c1.getOrderCount()

END FUNCTION










