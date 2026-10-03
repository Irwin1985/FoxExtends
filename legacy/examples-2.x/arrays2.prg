*-----------------------------------------*
* Using arrays
*-----------------------------------------*

* ----> Initialize the FoxExtends library
set default to justpath(Sys(16))
do ..\FoxExtends.prg
=newFoxExtends()
* <---- Initialize the FoxExtends library

clear && clear the screen

local laArray, lbResult

laArray = alist(1, 30, 39, 29, 10, 13)

lbResult = aevery(@laArray, "$0 < 40")

? lbResult

