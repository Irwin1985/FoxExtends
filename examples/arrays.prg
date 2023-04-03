*-----------------------------------------*
* Using arrays
*-----------------------------------------*

* ----> Initialize the FoxExtends library
set default to justpath(Sys(16))
do ..\FoxExtends.prg
=newFoxExtends()
* <---- Initialize the FoxExtends library

clear && clear the screen

* Create an array of 5 elements
local laFruits
laFruits = alist("Apple", "Banana", "Orange", "Pineapple", "Strawberry")

* Add an element to the end of the array
* NOTE: we use the @ prefix to pass the array by reference
apush(@laFruits, "Kiwi")

? anyToStr(@laFruits)

* Remove the last element of the array
apop(@laFruits)

? anyToStr(@laFruits)

* Joins the elements of the array into a string
? aJoin(@laFruits, ", ")

* Let's add some bitter fruits to the array laFruits
aPush(@laFruits, "Grapefruit")
aPush(@laFruits, "Lemon")
aPush(@laFruits, "Lime")

local laBitterFruits
laBitterFruits = alist("Grapefruit", "Lemon", "Lime", "Mandarin", "Tangerine")

* Let's intersect the two arrays and get the common elements (bitter fruits)
local laCommonFruits
laCommonFruits = aIntersect(@laFruits, @laBitterFruits)

? anyToStr(@laCommonFruits)

* Reverse the array
laReversedFruits = aReverse(@laFruits)
? anyToStr(@laReversedFruits)

* Create some duplicated elements
aPush(@laFruits, "Apple")
aPush(@laFruits, "Banana")
aPush(@laFruits, "Orange")

* Get the unique elements of the array
local laUniqueFruits
laUniqueFruits = aUnique(@laFruits)

? "Unique fruits: ", anyToStr(@laUniqueFruits)


? "The array has " + transform(alen(laFruits)) + " elements"

* Clone the array
local laClonedFruits
laClonedFruits = aClone(@laFruits)

? "Cloned fruits: ", anyToStr(@laClonedFruits)
