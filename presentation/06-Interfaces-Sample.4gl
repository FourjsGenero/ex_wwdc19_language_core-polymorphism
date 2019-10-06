# Property of Four Js*
# (c) Copyright Four Js 1995, 2019. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these
# samples are accurate and suitable for your purposes. Their inclusion is
# purely for information purposes only.

IMPORT util

TYPE Rectangle RECORD
    height, width FLOAT
END RECORD

TYPE Circle RECORD
    diameter FLOAT
END RECORD

TYPE Shape INTERFACE
    area() RETURNS FLOAT,
    kind() RETURNS STRING
END INTERFACE

FUNCTION (r Rectangle) area() RETURNS FLOAT
    RETURN r.height * r.width
END FUNCTION

FUNCTION (r Rectangle) kind() RETURNS STRING
    RETURN "Rectangle"
END FUNCTION

FUNCTION (c Circle) area() RETURNS FLOAT
    RETURN util.Math.pi() * (c.diameter / 2) ** 2
END FUNCTION

FUNCTION (r Circle) kind() RETURNS STRING
    RETURN "Circle"
END FUNCTION









FUNCTION totalArea(shapes DYNAMIC ARRAY OF Shape) RETURNS FLOAT
    DEFINE i INT
    DEFINE area FLOAT
    FOR i = 1 TO shapes.getLength()
        LET area = area + shapes[i].area()
    END FOR
    RETURN area
END FUNCTION

FUNCTION main()
    DEFINE r1 Rectangle = (height: 10, width: 20)
    DEFINE c1 Circle = (diameter: 10)
    DEFINE shapes DYNAMIC ARRAY OF Shape

    LET shapes[1] = r1
    LET shapes[2] = c1

    DISPLAY shapes[1].kind(), shapes[1].area()
    DISPLAY shapes[2].kind(), shapes[2].area()
    DISPLAY "Total:", totalArea(shapes)

END FUNCTION




