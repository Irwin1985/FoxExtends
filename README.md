FoxExtends
==========

> I like to think that the following features are what they would have implemented in version 10 of Visual FoxPro
>
> Suggestions are welcome!

Do you like or benefit from my work? please consider make a donation, a cup of coffee would be nice!

[![DONATE!](http://www.pngall.com/wp-content/uploads/2016/05/PayPal-Donate-Button-PNG-File-180x100.png)](https://www.paypal.com/donate/?hosted_button_id=LXQYXFP77AD2G) 

## Function documentation

```js 
1. PAIR(tvKey, tvValue): create a Key-Value object with the data provided.
```
### Example
```xBase
loPair = PAIR("name", "John")
? loPair.key, loPair.value
```

```js 
2. ANYTOSTR(tvValue): convert any object into string (including Collections)
```
### Example

```xBase
? ANYTOSTR(_SCREEN) && the whole screen object :)
```

```js 
3. APUSH(tArray, tvItem): adds an element into the array (NOTE: YOU MUST PASS THE ARRAY AS REFERENCE)
```
### Example

```xBase
dimension laCountries[1]
laCountries[1] = "USA"
APUSH(@laCountries, "COLOMBIA"
APUSH(@laCountries, "ARGENTINA")
APUSH(@laCountries, "ESPAÑA")
```

```js 
4. APOP(tArray): removes an element from the top of the array. (NOTE: YOU MUST PASS THE ARRAY AS REFERENCE)
```
### Example

```xBase
dimension laCountries[4]
laCountries[1] = "USA"
laCountries[2] = "COLOMBIA"
laCountries[3] = "ARGENTINA")
laCountries[4] = "ESPAÑA"
* Remove and retrieve the removed element
? APOP(@laCountries) && print ESPAÑA
```

```js 
5. JOIN(tArray, tcStep): return a string with all array elements delitemited by tcStep
```
### Example

```xBase
dimension laCountries[4]
laCountries[1] = "USA"
laCountries[2] = "COLOMBIA"
laCountries[3] = "ARGENTINA")
laCountries[4] = "ESPAÑA"

? JOIN(@laCountries, ', ') && prints USA, COLOMBIA, ARGENTINA, ESPAÑA
```

```js 
6. SPLIT(tcString, tcDelimiter): Creates an array with all matches found in the string provided.
```
### Example

```xBase
laColors = SPLIT("Red, Yellow, Blue, Green, Purple", ',')
FOR EACH lcColor in laColors
  ? lcColor
ENDFOR
```

```js 
7. MATCHES(tcString, tcPattern): check if the **tcPattern** matches in the string provided. (depends on **VBScript.RegExp** lib.)
```
### Example

```xBase
* Validate an email format
? MATCHES("rodriguez.irwin@gmail.com", "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$") && print .T.
```
```js 
8. REVERSE(tcString): reverses a string
```
### Example

```xBase
? REVERSE("Irwin") && niwrI
```

```js 
9. STRTOJSON(tcJSONStr): receive a json string and converts it to Foxpro equivalent object.
```
### Example

```xBase
loMyJson = STRTOJSON('{"name": "John", "age": 36}')
? loMyJson.name
? loMyJson.age
```

```js 
10. JSONTOSTR(tvJsonObj): takes the json object *(FoxPro equivalent object)* and return the string representation.
```
### Example

```xBase
? JSONTOSTR(loMyJson) && {"name": "John", "age": 36}
```

```js 
11. PRINTF(tcFormat, tvVal0, tvVal1, tvVal2, tvVal3, tvVal4, tvVal5, tvVal6, tvVal7, tvVal8, tvVal9, tvVal10): pretty prints up to ten values (sorry for this limitation).
```
### Example

```xBase
? PRINTF("Hello ${0}! My name is ${1} and I'm glad to ${2} you!", "world", "John", "meet")
```

