# Property of Four Js*
# (c) Copyright Four Js 1995, 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

MAIN
    DEFINE arr1 DYNAMIC ARRAY OF RECORD
        pkey INTEGER,
        name VARCHAR(50)
    END RECORD
        = [(pkey: 834, name: "Mike Torn"),
           (pkey: 981, name: "Blake Crystal"),
           (pkey: 993, name: "Tom Yorp")]

    DISPLAY arr1.getLength()

END MAIN











