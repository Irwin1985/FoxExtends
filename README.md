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
// 16. OFIELDS(tcAliasOrDataSession)
// returns an object mapped with all the table structure info.
// check AFIELDS() documentation for property names.
// ================================================================================
// Example

Use Home(2) + "\northwind\employees.dbf"
laNumbers = ALIST(5, 10, 15, 20, 25, 30, 35, 40)
loFields = OFIELDS('employees')
? ANYTOSTR(loFields) // prints a nice json format :)

// print all properties
? loFields.name
? loFields.field_type
? loFields.field_width
? loFields.decimal_places
? loFields.null_allowed
? loFields.code_page_translation_not_allowed
? loFields.field_validation_expression
? loFields.field_validation_text
? loFields.field_default_value
? loFields.table_validation_expression
? loFields.table_validation_text
? loFields.long_table_name
? loFields.insert_trigger_expression
? loFields.update_trigger_expression
? loFields.delete_trigger_expression
? loFields.table_comment
? loFields.next_value_for_autoincrementing
? loFields.step_for_autoincrementing


```
