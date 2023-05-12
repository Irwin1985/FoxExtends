*-------------------------------------*
* Using Enumerations
*-------------------------------------*

* ----> Initialize the FoxExtends library
* set default to justpath(Sys(16))
do ..\FoxExtends.prg
=newFoxExtends()
* <---- Initialize the FoxExtends library

clear && clear the screen

local loDow
loDow = enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')

? loDow.Monday && 1
? loDow.Tuesday && 2
? loDow.Wednesday && 3
? loDow.Thursday && 4
? loDow.Friday && 5
? loDow.Saturday && 6
? loDow.Sunday && 7
