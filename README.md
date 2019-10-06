# ex_wwdc19_language_core
This demo implements a REST web service that provides a an example of polymorphism using INTERFACE, DICTIONARY, Function Methods and "call by reference".

Using the Genero sample officestore database, the demo creates interface "objects" for the category, supplier and country tables.  A factory defines an INTERFACE to implement C.R.U.D. functions and a DICTIONARY loads the interface objects by a "reference" name derived of the REST request resource.  Then, the C.R.U.D. functions are called by the REST resource name based on the REST method(GET, PUT, POST, DELETE). 

Requires: Genero BDL with Web Services(FGLWS) v3.20 of greater to compile and execute.

