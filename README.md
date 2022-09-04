FoxExtends
==========

> I like to think that the following features are what they would have implemented in version 10 of Visual FoxPro
>
> Suggestions are welcome!

Do you like or benefit from my work? please consider make a donation, a cup of coffee would be nice!

[![DONATE!](http://www.pngall.com/wp-content/uploads/2016/05/PayPal-Donate-Button-PNG-File-180x100.png)](https://www.paypal.com/donate/?hosted_button_id=LXQYXFP77AD2G) 

## Function documentation

```xBase

// ================================================================================
// 1. PAIR(tvKey, tvValue): create a Key-Value object with the data provided:
// ================================================================================

// Example

loPair = PAIR("name", "John")
? loPair.key, loPair.value

// ================================================================================
// 2. ANYTOSTR(tvValue): convert any object into string (including Collections):
// ================================================================================

// Example
? ANYTOSTR(_SCREEN) // the whole screen object :)

// ================================================================================
// 3. APUSH(tArray, tvItem): adds an element into the array 
// NOTE: YOU MUST PASS THE ARRAY AS REFERENCE
// ================================================================================
// Example

DIMENSION laCountries[1]
laCountries[1] = "USA"
APUSH(@laCountries, "COLOMBIA")
APUSH(@laCountries, "ARGENTINA")
APUSH(@laCountries, "ESPAÑA")

// ================================================================================
// 4. APOP(tArray): removes an element from the top of the array. 
// NOTE: YOU MUST PASS THE ARRAY AS REFERENCE
// ================================================================================
// Example

DIMENSION laCountries[4]
laCountries[1] = "USA"
laCountries[2] = "COLOMBIA"
laCountries[3] = "ARGENTINA"
laCountries[4] = "ESPAÑA"
// Remove and retrieve the removed element
? APOP(@laCountries) // print ESPAÑA

// ================================================================================
// 5. AJOIN(tArray, tcStep): return a string with all array elements delitemited by tcStep
// ================================================================================
// Example

DIMENSION laCountries[4]
laCountries[1] = "USA"
laCountries[2] = "COLOMBIA"
laCountries[3] = "ARGENTINA"
laCountries[4] = "ESPAÑA"

? AJOIN(@laCountries, ', ') // prints USA, COLOMBIA, ARGENTINA, ESPAÑA

// ================================================================================
// 6. ASPLIT(tcString, tcDelimiter): Creates an array with all matches in the string provided.
// ================================================================================
// Example

laColors = ASPLIT("Red, Yellow, Blue, Green, Purple", ',')
FOR EACH lcColor IN laColors
  ? lcColor
ENDFOR

// ================================================================================
// 7. MATCH(tcString, tcPattern): check if the tcPattern matches in the string provided. 
// NOTE: this function relies on VBScript.RegExp
// ================================================================================
// Example

// Validate an email format
? MATCH("rodriguez.irwin@gmail.com", "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$") // print .T.


// ================================================================================
// 8. REVERSE(tcString): reverses a string
// ================================================================================
// Example

? REVERSE("Irwin") // niwrI

// ================================================================================
// 9. STRTOJSON(tcJSONStr): receive a json string and creates a Foxpro equivalent object.
// NOTE: this function relies on JSONFOX: https://github.com/Irwin1985/JSONFox
// ================================================================================
// Example

loMyJson = STRTOJSON('{"name": "John", "age": 36}')
? loMyJson.name
? loMyJson.age

// ================================================================================
// 10. JSONTOSTR(tvJsonObj): pretty print the Foxpro equivalent json object.
// ================================================================================
// Example

? JSONTOSTR(loMyJson) // {"name": "John", "age": 36}

// ================================================================================
// 11. PRINTF(tcFormat, tvVal0...tvVal10): pretty prints up to ten values.
// you can even escape some special characters like: \t, \r, \n, \", \'
// NOTE: sorry for this limitation of ten arguments.
// ================================================================================
// Example

? PRINTF("Hello ${0}! My name is ${1} and I'm glad to ${2} you!", "world", "John", "meet")

// ================================================================================
// 12. ALIST(tvVal1, tvVal2, tvVal3,...tvVal10): creates an array up to ten 
// heterogeneous elements.
// 
// NOTE: sorry for this limitation of ten arguments.
// ================================================================================
// Example

laData = ALIST("John", 36, .T., .F., .Null., PAIR("Bank of America", "NL40RABO8933084452"), "john@gmail.com")
FOR EACH lItem IN laData
  ? lItem
ENDFOR

// print the pair (at index 6!!!)
? laData[6].key // prints Bank of America
? laData[6].value // prints NL40RABO8933084452

// ================================================================================
// 13. CLAMP(tcString, tnFrom, tnTo): captures a range of characters. 
// ================================================================================
// Example

lcString = "This is a string"
? CLAMP(lcString, 6, 10) // prints "is a"

// ================================================================================
// 14. AMAP(tArray, tcPredicate): returns an array with tcPredicate expression
// applied.
//
// LIMITATIONS: the array must be one-dimensional and homogeneous.
// ================================================================================
// Example

laNumbers = ALIST(5, 10, 15, 20, 25, 30, 35, 40)
laResult = AMAP(@laNumbers, "$0 + 5")
? ANYTOSTR(@laResult) // prints [10,15,20,25,30,35,40,45]

// ================================================================================
// 15. AFILTER(tArray, tcPredicate): returns all items from tArray that returns .T.
// by applying the tcPredicate expression.
//
// LIMITATIONS: the array must be one-dimensional and homogeneous.
// ================================================================================
// Example

laNumbers = ALIST(5, 10, 15, 20, 25, 30, 35, 40)
laResult = AFILTER(@laNumeros, "BETWEEN($0, 20,  30)") // filter just those items with this range (20 and 30)
? ANYTOSTR(@laResult) // prints [20,25,30]

// ================================================================================
// 15. AFILTER(tArray, tcPredicate): returns all items from tArray that returns .T.
// by applying the tcPredicate expression.
//
// LIMITATIONS: the array must be one-dimensional and homogeneous.
// ================================================================================
// Example

laNumbers = ALIST(5, 10, 15, 20, 25, 30, 35, 40)
laResult = AFILTER(@laNumeros, "BETWEEN($0, 20,  30)") // filter just those items with this range (20 and 30)
? ANYTOSTR(@laResult) // prints [20,25,30]

// ================================================================================
// 16. AFIELDSOBJ(tcAliasOrDataSession)
// returns an array mapped with all the table structure info.
// check AFIELDS() documentation for property names.
// ================================================================================
// Example

Use Home(2) + "\northwind\employees.dbf"
laFields = AFIELDSOBJ('employees')
? ANYTOSTR(laFields) // prints a nice json format :)

// print all properties
FOR EACH loItem IN laFields
  ? loItem.name
  ? loItem.field_type
  ? loItem.field_width
  ? loItem.decimal_places
  ? loItem.null_allowed
  ? loItem.code_page_translation_not_allowed
  ? loItem.field_validation_expression
  ? loItem.field_validation_text
  ? loItem.field_default_value
  ? loItem.table_validation_expression
  ? loItem.table_validation_text
  ? loItem.long_table_name
  ? loItem.insert_trigger_expression
  ? loItem.update_trigger_expression
  ? loItem.delete_trigger_expression
  ? loItem.table_comment
  ? loItem.next_value_for_autoincrementing
  ? loItem.step_for_autoincrementing
ENDFOR

// ================================================================================
// 17. ADIROBJ(tcFileSkeleton, [tcAttribute, [tnFlags]])
// returns an array mapped with all the files structure info.
// check ADIR() documentation for property names.
// ================================================================================
// Example

laDir = ADIROBJ("c:\my\path\*.txt")
? ANYTOSTR(laDir) // prints a nice json format :)

// print all properties
FOR EACH loItem IN laDir
  ? loItem.file_name
  ? loItem.file_size
  ? loItem.date_last_modified
  ? loItem.time_last_modified
  ? loItem.file_attributes
ENDFOR

// ================================================================================
// 18. SECRETBOX(tcPrompt, [tcCaption])
// Displays a modal dialog used for typing secret passwords.
// NOTE: the result string is not encrypted, it's just a raw string.
// ================================================================================
// Example

lcPassword = SECRETBOX("Login", "Please type your password")
IF lcPassword != "Admin" THEN
  ? "Access Denied!"
  RETURN
ENDIF

? "Welcome!"

// ================================================================================
// 19. Variadic functions with ARGS() and APARAMS()
// This implementation allows us to simulate variadic functions and avoid passing
// a lot of arguments.
// ARGS(arg1, arg2, argn): wraps all arguments inside a special object. (caller)
// APARAMS(toArgs): unwraps all arguments into an array. (function body)
// ================================================================================
// Example
? arithmeticOperation("+", ARGS(5, 10, 15, 20, 25, 30))

FUNCTION arithmeticOperation(tcOperator, toOperands)
  LOCAL lnResult, laParams
  lnResult = 0
  laParams = APARAMS(toOperands) // unwrap arguments	
  FOR EACH lnOperand IN laParams
    lnResult = lnResult &tcOperator lnOperand
  ENDFOR
  
  RETURN lnResult
ENDFUNC

// ================================================================================
// 20. STRINGLIST(): creates an string object that enhance the string manipulation
// NOTE: it's constructor accepts ARGS() parameters. See ARGS() and APARAMS()
// ================================================================================
// Example
laLanguages = STRINGLIST() // empty stringlist
laLanguages.Add("Visual FoxPro")
laLanguages.Add("Swift")
laLanguages.Add("Nim")
laLanguages.Add("V")
? laLanguages.Join(', ') // print "Visual FoxPro, Swift, Nim, V"

// Example 2: using the constructor.
laStuffs = STRINGLIST(ARGS("House", "Horse", "Pencil"))
laStuffs.Add("Red")
laStuffs.Add("Person")
laStuffs.Add("Table")

? laStuffs.Join(', ')

// ================================================================================
// 21. AZIP(tArray1, tArray2): returns a new array with the combination of two
// arrays provided. Each element must be accessed by using the 'left' and 'right'
// properties.
// ================================================================================
// Example

laFruits = ALIST("Apples", "Bananas", "Strawberry")
laVegetables = ALIST("Tomato", "Carrot", "Pumpkins")

laFusion = AZIP(@laFruits, @laVegetables)

FOR EACH loItem IN laFusion
  ? loItem.left
  ? loItem.right
ENDFOR

// ================================================================================
// 22. HASHTABLE(tcKey2, tcValue1 [,...]): creates a dictionary with the given
// keys and values.
// LIMITATION:
// 1. keys must be strings
// 2. the function takes up to 50 key-values params.
// ================================================================================
// Example

loDictionary = HASHTABLE("name", "John", "age", 36, "gender", "M", "salary", 3000)

? loDictionary.name
? loDictionary.age
? loDictionary.gender
? loDictionary.salary

// ================================================================================
// 23. HASKEY(toDictionary, tcKey): determines if tcKey exists in toDictionary
// ================================================================================
// Example

loDictionary = HASHTABLE("name", "John", "age", 36, "gender", "M", "salary", 3000)
? HASKEY(loDictionary, "name") // .T.
? HASKEY(loDictionary, "address") // .F.

// ================================================================================
// 24. AKEYS(toDictionary): returns an array with all keys found in toDictionary
// ================================================================================
// Example
loDictionary = HASHTABLE("name", "John", "age", 36, "gender", "M", "salary", 3000)
laKeys = AKEYS(loDictionary)
?ANYTOSTR(@laKeys) // ["NAME", "AGE", "GENDER", "SALARY"]

// ================================================================================
// 25. ASLICE(tArray, tcRange): creates an array with the range provided.
// ================================================================================
// Example

laFruits = ALIST("apple", "banana", "blackberry", "grape", "lemon", "mango", "raspberry")
laSlice = ASLICE(@laFruits, "2..3") // from index 2 until index 3
? ANYTOSTR(@laSlice) // ["banana", "blackberry"]

laSlice = ASLICE(@laFruits, "..3") // from index 1 up to 3
? ANYTOSTR(@laSlice) // ["apple", "banana", "blackberry"]

laSlice = ASLICE(@laFruits, "5..") // from index 5 up to the end of the array.
? ANYTOSTR(@laSlice) // ["lemon", "mango", "raspberry"]

laSlice = ASLICE(@laFruits, "3") // first 3 elements
? ANYTOSTR(@laSlice) // ["apple", "banana", "blackberry"]

laSlice = ASLICE(@laFruits, "-2") // last 2 elements
? ANYTOSTR(@laSlice) // ["mango", "raspberry"]

// ================================================================================
// 26. AMATCH(tcString, tcPattern, tcOccurrences): creates an array with the
// ocurrences found in tcString by applying the tcPattern regular expression.
// ================================================================================
// Example

lcString = "Hi, foxextends has more than 20 functions...! can you help me to make it 100?"
laResult = AMATCH(lcString, "\w+", 1) // first number
? laResult[1] // 20

laResult = AMATCH(lcString, "\w+", 2) // second number
? laResult[1] // 100

```
