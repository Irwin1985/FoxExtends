FoxExtends
==========

> I like to think that the following features are what they would have implemented in version 10 of Visual FoxPro
>
> Suggestions are welcome!

Do you like or benefit from my work? please consider make a donation, a cup of coffee would be nice!

[![DONATE!](http://www.pngall.com/wp-content/uploads/2016/05/PayPal-Donate-Button-PNG-File-180x100.png)](https://www.paypal.com/donate/?hosted_button_id=LXQYXFP77AD2G) 

## Examples

```diff
@@ PAIR(tvKey, tvValue): create a *Key-Value* object with the data provided.
```

```xBase
loPair = PAIR("name", "John")
? loPair.key, loPair.value
```

`- ANYTOSTR(tvValue): convert any object into string (including Collections)`
```xBase
? ANYTOSTR(_SCREEN) && the whole screen object :)
```

`- APUSH(tArray, tvItem): adds an element into the array (NOTE: YOU MUST PASS THE ARRAY AS REFERENCE)`
```xBase
dimension laCountries[1]
laCountries[1] = "USA"
APUSH(@laCountries, "COLOMBIA"
APUSH(@laCountries, "ARGENTINA")
APUSH(@laCountries, "ESPAÑA")
```

`- APOP(tArray): removes an element from the top of the array. (NOTE: YOU MUST PASS THE ARRAY AS REFERENCE)`
```xBase
dimension laCountries[4]
laCountries[1] = "USA"
laCountries[2] = "COLOMBIA"
laCountries[3] = "ARGENTINA")
laCountries[4] = "ESPAÑA"
* Remove and retrieve the removed element
? APOP(@laCountries) && print ESPAÑA
```

`- JOIN(tArray, tcStep): return a string with all array elements delitemited by **tcStep**`
```xBase
dimension laCountries[4]
laCountries[1] = "USA"
laCountries[2] = "COLOMBIA"
laCountries[3] = "ARGENTINA")
laCountries[4] = "ESPAÑA"

? JOIN(@laCountries, ', ') && prints USA, COLOMBIA, ARGENTINA, ESPAÑA
```

`- SPLIT(tcString, tcDelimiter): Creates an array with all matches found in the string provided.`
```xBase
laColors = SPLIT("Red, Yellow, Blue, Green, Purple", ',')
FOR EACH lcColor in laColors
  ? lcColor
ENDFOR
```

`- MATCHES(tcString, tcPattern): check if the **tcPattern** matches in the string provided. (depends on **VBScript.RegExp** lib.)`
```xBase
* Validate an email format
? MATCHES("rodriguez.irwin@gmail.com", "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$") && print .T.
```

`- REVERSE(tcString): reverses a string`
```xBase
? REVERSE("Irwin") && niwrI
```

`- STRTOJSON(tcJSONStr): receive a json string and converts it to Foxpro equivalent object.`
```xBase
loMyJson = STRTOJSON('{"name": "John", "age": 36}')
? loMyJson.name
? loMyJson.age
```

`- JSONTOSTR(tvJsonObj): takes the json object *(FoxPro equivalent object)* and return the string representation.`
```xBase
? JSONTOSTR(loMyJson) && {"name": "John", "age": 36}
```

`- PRINTF(tcFormat, tvVal0, tvVal1, tvVal2, tvVal3, tvVal4, tvVal5, tvVal6, tvVal7, tvVal8, tvVal9, tvVal10): pretty prints up to ten values (sorry for this limitation).`
```xBase
? PRINTF("Hello ${0}! My name is ${1} and I'm glad to ${2} you!", "world", "John", "meet")
```

