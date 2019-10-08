# ex_wwdc19_language_core-polymorphism
This demo implements a REST web service that provides an example of polymorphism using INTERFACE, DICTIONARY, Function Methods and "call by reference".

Using the Genero sample officestore database, the demo creates interface "objects" for the category, supplier and country tables.  A factory defines an INTERFACE to implement C.R.U.D. functions and a DICTIONARY loads the interface objects by a "reference" name derived of the REST request resource.  Then, the C.R.U.D. functions are called by the REST resource name based on the REST method(GET, PUT, POST, DELETE). 

Requires: Genero BDL with Web Services(FGLWS) v3.20 of greater to compile and execute.

The service can be tested with a variety of testing clients(Postman, Browser RESTlet plugin, curl)

Example curl commands

    curl -X GET -i http://localhost:8090/ws/r/rest/categories
    curl -X GET -i http://localhost:8090/ws/r/rest/suppliers
    curl -X GET -i http://localhost:8090/ws/r/rest/countries


C.R.U.D. Testing sequence

  Create:
    
    curl -X POST -i http://localhost:8090/ws/r/rest/countries --data '[{"code":"FJS","codedesc":"FourJs WWDC19"}]'
    
  Read:
    
    curl -X GET -i http://localhost:8090/ws/r/rest/countries/FJS
    curl -X GET -i 'http://localhost:8090/ws/r/rest/countries?id=FJS'
    
  Update:
    
    curl -X PUT -i http://localhost:8090/ws/r/rest/countries --data '[{"code":"FJS","codedesc":"xxx Delete Me xxx"}]'
    
  Delete:
    
    curl -X DELETE -i 'http://localhost:8090/ws/r/rest/countries?id=FJS'
