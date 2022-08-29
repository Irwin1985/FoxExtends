**********************************************************************
* VFP extended methods
**********************************************************************

#IFNDEF FUNCTION_ARG_VALUE_INVALID
	#Define FUNCTION_ARG_VALUE_INVALID 11
#Endif

#IFNDEF JSONFOX_NOT_FOUND
	#Define JSONFOX_NOT_FOUND 'JSONFOX.APP does not exist in your PATH() directories. Please make sure JSONFOX.APP can be found by your application.'
#Endif

If Type('_vfp.foxExtendsRegEx') != 'O'
	=AddProperty(_vfp, 'foxExtendsRegEx', CreateObject("VBScript.RegExp"))
	_vfp.foxExtendsRegEx.IgnoreCase = .T.
	_vfp.foxExtendsRegEx.Global = .T.	
EndIf

Function PAIR(tvKey, tvValue)
	Local loPair
	loPair = Createobject('Empty')
	=AddProperty(loPair, 'key', tvKey)
	=AddProperty(loPair, 'value', tvValue)
	Return loPair
Endfunc

Function ANYTOSTR(tvValue)
	Local loAnyToStr
	loAnyToStr = Createobject("AnyToString")
	Return loAnyToStr.ANYTOSTR(@tvValue)
Endfunc

Function APUSH(tArray, tvItem)
	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	Endif
	Local lnIndex
	lnIndex = Alen(tArray, 1) + 1
	Dimension tArray[lnIndex]
	tArray[lnIndex] = tvItem
Endfunc

Function APOP(tArray)
	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	Endif
	Local lnIndex, lvOldVal
	lnIndex = Alen(tArray, 1)
	lnIndex = lnIndex - 1
	If lnIndex <= 0
		lnIndex = 1
		Dimension tArray[lnIndex]
		Return
	Endif
	lvOldVal = tArray[lnIndex+1]
	Dimension tArray[lnIndex]

	Return lvOldVal
Endfunc

Function Join(tArray, tcSep)
	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	Endif

	Local lcStr, i, lcVal
	lcStr = ''
	For i = 1 To Alen(tArray)
		lcVal = tArray[i]
		If i = 1 Then
			lcStr = lcVal
		Else
			lcStr = lcStr + Iif(!Empty(tcSep), tcSep + lcVal, lcVal)
		Endif
	Endfor
	Return lcStr
Endfunc

Function Split(tcString, tcDelimiter)
	Local loString
	loString = Createobject("TString", tcString)
	Return loString.Split(tcDelimiter)
Endfunc

Function MATCHES(tcString, tcPattern)
	_vfp.foxExtendsRegEx.Pattern = tcPattern
	Return _vfp.foxExtendsRegEx.test(tcString)
Endfunc

Function REVERSE(tcString)
	Local lcValue, i
	lcValue = ''
	For i = Len(Alltrim(tcString)) To 1 Step -1
		lcValue = lcValue + Substr(tcString, i, 1)
	Endfor

	Return lcValue
Endfunc

Function JSONTOSTR(tvJsonObj)
	If !CHECKJSONAPP()
		Return ''
	Endif

	Return _Screen.JSON.STRINGIFY(tvJsonObj)
Endfunc

Function STRTOJSON(tcJSONString)
	If !CHECKJSONAPP()
		Return .Null.
	Endif

	Return _Screen.JSON.PARSE(tcJSONString)
Endfunc

Function PRINTF(tcFormat, tvVal0, tvVal1, tvVal2, tvVal3, tvVal4, tvVal5, tvVal6, tvVal7, tvVal8, tvVal9, tvVal10, tvVal11)
	Local loResult, i, loItem, lcValue, j

	_vfp.foxExtendsRegEx.Pattern = "\${\d+}"
	loResult = _vfp.foxExtendsRegEx.Execute(tcFormat)

	If Type('loResult') != 'O'
		Return tcFormat
	Endif

	For i = 1 To loResult.Count
		loItem = loResult.Item[i-1] && zero based
		j = Strextract(tcFormat, '${', '}')
		lcValue = Evaluate("tvVal" + j)
		tcFormat = Strtran(tcFormat, loItem.Value, Transform(lcValue))
	Endfor

	Return tcFormat
Endfunc

* ========================================================================================== *
* HELPER FUNCTIONS
* ========================================================================================== *
Function CHECKJSONAPP
	* ¿DOES JSONFOX.APP EXIST?
	If !File("JSONFOX.APP")
		Error JSONFOX_NOT_FOUND
		Return .F.
	Endif

	If Type('_SCREEN.JSON') == 'O'
		_Screen.JSON = .Null.
		=Removeproperty(_Screen, 'JSON')
	Endif

	Do "JSONFOX.APP"
	Return .T.
Endfunc

* AnyToString
Define Class AnyToString As Custom
	#Define USER_DEFINED_PEMS	'U'
	#Define ALL_MEMBERS			"PHGNUCIBR"
	lCentury = .F.
	cDateAct = ''
	nOrden   = 0
	cFlags 	 = ''

	Function Init
		This.lCentury = Set("Century") == "OFF"
		This.cDateAct = Set("Date")
		Set Century On
		Set Date Ansi
		Mvcount = 60000
	Endfunc

	Function ToString(toRefObj, tcFlags)
		lPassByRef = .T.
		Try
			External Array toRefObj
		Catch
			lPassByRef = .F.
		Endtry
		This.cFlags = Evl(tcFlags, ALL_MEMBERS)
		If lPassByRef
			Return This.ANYTOSTR(@toRefObj)
		Else
			Return This.ANYTOSTR(toRefObj)
		Endif
	Endfunc

	Function ANYTOSTR As Memo
		Lparameters tValue As variant
		Try
			External Array tValue
		Catch
		Endtry
		Do Case
		Case Type("tValue", 1) = 'A'
			Local k, j, lcArray
			If Alen(tValue, 2) == 0
				*# Unidimensional array
				lcArray = '['
				For k = 1 To Alen(tValue)
					lcArray = lcArray + Iif(Len(lcArray) > 1, ',', '')
					Try
						=Acopy(tValue[k], aLista)
						lcArray = lcArray + This.ANYTOSTR(@aLista)
					Catch
						lcArray = lcArray + This.ANYTOSTR(tValue[k])
					Endtry
				Endfor
				lcArray = lcArray + ']'
			Else
				*# Multidimensional array support
				lcArray = '['
				For k = 1 To Alen(tValue, 1)
					lcArray = lcArray + Iif(Len(lcArray) > 1, ',', '')

					* # begin of rows
					lcArray = lcArray + '['
					For j = 1 To Alen(tValue, 2)
						If j > 1
							lcArray = lcArray + ','
						Endif
						Try
							=Acopy(tValue[k, j], aLista)
							lcArray = lcArray + This.ANYTOSTR(@aLista)
						Catch
							lcArray = lcArray + This.ANYTOSTR(tValue[k, j])
						Endtry
					Endfor
					lcArray = lcArray + ']'
					* # end of rows
				Endfor
				lcArray = lcArray + ']'
			Endif
			Return lcArray

		Case Vartype(tValue) = 'O'
			Local j, lcStr, lnTot
			Local Array gaMembers(1)

			lcStr = '{'
			lnTot = Amembers(gaMembers, tValue, 0, This.cFlags)
			For j=1 To lnTot
				lcProp = Lower(Alltrim(gaMembers[j]))
				lcStr = lcStr + Iif(Len(lcStr) > 1, ',', '') + '"' + lcProp + '":'
				Try
					=Acopy(tValue. &gaMembers[j], aCopia)
					lcStr = lcStr + This.ANYTOSTR(@aCopia)
				Catch
					Try
						lcStr = lcStr + This.ANYTOSTR(tValue. &gaMembers[j])
					Catch
						lcStr = lcStr + "{}"
					Endtry
				Endtry
			Endfor

			*//> Collection based class object support
			llIsCollection = .F.
			Try
				llIsCollection = (tValue.BaseClass == "Collection" And tValue.Class == "Collection" And tValue.Name == "Collection")
			Catch
			Endtry
			If llIsCollection
				lcComma   = Iif(Right(lcStr, 1) != '{', ',', '')
				lcStr = lcStr + lcComma + '"Collection":['
				For i=1 To tValue.Count
					lcStr = lcStr + Iif(i>1,',','') + This.ANYTOSTR(tValue.Item(i))
				Endfor
				lcStr = lcStr + ']'
			Endif
			*//> Collection based class object support

			lcStr = lcStr + '}'
			Return lcStr
		Otherwise
			Return This.GetValue(tValue, Vartype(tValue))
		Endcase
	Endfunc

	Function Destroy
		If This.lCentury
			Set Century Off
		Endif
		lcDateAct = This.cDateAct
		Set Date &lcDateAct
	Endfunc

	Function GetValue As String
		Lparameters tcValue As String, tctype As Character
		Do Case
		Case tctype $ "CDTBGMQVWX"
			Do Case
			Case tctype = "D"
				tcValue = '"' + Strtran(Dtoc(tcValue), ".", "-") + '"'
			Case tctype = "T"
				tcValue = '"' + Strtran(Ttoc(tcValue), ".", "-") + '"'
			Otherwise
				If tctype = "X"
					tcValue = "null"
				Else
					tcValue = This.getstring(tcValue)
				Endif
			Endcase
			tcValue = Alltrim(tcValue)
		Case tctype $ "YFIN"
			tcValue = Strtran(Transform(tcValue), ',', '.')
		Case tctype = "L"
			tcValue = Iif(tcValue, "true", "false")
		Endcase
		Return tcValue
	Endfunc

	Function getstring As String
		Lparameters tcString As String, tlParseUtf8 As Boolean
		tcString = Allt(tcString)
		tcString = Strtran(tcString, '\', '\\' )
		tcString = Strtran(tcString, Chr(9),  '\t' )
		tcString = Strtran(tcString, Chr(10), '\n' )
		tcString = Strtran(tcString, Chr(13), '\r' )
		tcString = Strtran(tcString, '"', '\"' )

		If tlParseUtf8
			tcString = Strtran(tcString,"&","\u0026")
			tcString = Strtran(tcString,"+","\u002b")
			tcString = Strtran(tcString,"-","\u002d")
			tcString = Strtran(tcString,"#","\u0023")
			tcString = Strtran(tcString,"%","\u0025")
			tcString = Strtran(tcString,"²","\u00b2")
			tcString = Strtran(tcString,'à','\u00e0')
			tcString = Strtran(tcString,'á','\u00e1')
			tcString = Strtran(tcString,'è','\u00e8')
			tcString = Strtran(tcString,'é','\u00e9')
			tcString = Strtran(tcString,'ì','\u00ec')
			tcString = Strtran(tcString,'í','\u00ed')
			tcString = Strtran(tcString,'ò','\u00f2')
			tcString = Strtran(tcString,'ó','\u00f3')
			tcString = Strtran(tcString,'ù','\u00f9')
			tcString = Strtran(tcString,'ú','\u00fa')
			tcString = Strtran(tcString,'ü','\u00fc')
			tcString = Strtran(tcString,'À','\u00c0')
			tcString = Strtran(tcString,'Á','\u00c1')
			tcString = Strtran(tcString,'È','\u00c8')
			tcString = Strtran(tcString,'É','\u00c9')
			tcString = Strtran(tcString,'Ì','\u00cc')
			tcString = Strtran(tcString,'Í','\u00cd')
			tcString = Strtran(tcString,'Ò','\u00d2')
			tcString = Strtran(tcString,'Ó','\u00d3')
			tcString = Strtran(tcString,'Ù','\u00d9')
			tcString = Strtran(tcString,'Ú','\u00da')
			tcString = Strtran(tcString,'Ü','\u00dc')
			tcString = Strtran(tcString,'ñ','\u00f1')
			tcString = Strtran(tcString,'Ñ','\u00d1')
			tcString = Strtran(tcString,'©','\u00a9')
			tcString = Strtran(tcString,'®','\u00ae')
			tcString = Strtran(tcString,'ç','\u00e7')
		Endif

		Return '"' +tcString + '"'
	Endfunc
Enddefine


Define Class TString As Custom
	Value = ''
	Dimension aWords[1]
	Function Init(tcStartValue)
		If Pcount() = 1
			If Type('tcStartValue') == 'C'
				This.Value = tcStartValue
			Else
				Error 'Invalid data type for string.'
			Endif
		Else
			This.Value = Space(1)
		Endif
	Endfunc

	Function Split(tcDelimiter)
		Local tcWord, i
		For i = 1 To Getwordcount(This.Value, tcDelimiter)
			Dimension This.aWords[i]
			This.aWords[i] = Getwordnum(This.Value, i, tcDelimiter)
		Endfor
		Return @This.aWords
	Endfunc

	Function LineS
		Local tcWord, i, lcValue
		lcValue = Strtran(This.Value, Chr(10))
		For i = 1 To Getwordcount(lcValue, Chr(13))
			Dimension This.aWords[i]
			This.aWords[i] = Getwordnum(lcValue, i, Chr(13))
		Endfor
		Return @This.aWords
	Endfunc

Enddefine
