**********************************************************************
* VFP extended methods
**********************************************************************

#IFNDEF FUNCTION_ARG_VALUE_INVALID
#Define FUNCTION_ARG_VALUE_INVALID 11
#Endif

#IFNDEF TOO_FEW_ARGUMENTS
#Define TOO_FEW_ARGUMENTS 1229
#Endif

#IFNDEF JSONFOX_NOT_FOUND
#Define JSONFOX_NOT_FOUND 'JSONFOX.APP does not exist in your PATH() directories. Please make sure JSONFOX.APP can be found by your application.'
#Endif

#IFNDEF HASHTABLE_PARAMS_MISTMATCH
#Define HASHTABLE_PARAMS_MISTMATCH 'keys does not match values'
#Endif

#IFNDEF HASHTABLE_INVALID_KEY
#Define HASHTABLE_INVALID_KEY 'Invalid key'
#Endif


If Type('_vfp.foxExtendsRegEx') != 'O'
	=AddProperty(_vfp, 'foxExtendsRegEx', Createobject("VBScript.RegExp"))
	_vfp.foxExtendsRegEx.IgnoreCase = .T.
	_vfp.foxExtendsRegEx.Global = .T.
Endif

If Type('_vfp.fxAnyToString') = 'U'
	AddProperty(_vfp, 'fxAnyToString', .Null.)
Endif
_vfp.fxAnyToString = Createobject('AnyToString')

Function PAIR(tvKey, tvValue)
	Local loPair
	loPair = Createobject('Empty')
	=AddProperty(loPair, 'key', tvKey)
	=AddProperty(loPair, 'value', tvValue)
	Return loPair
Endfunc

Function ANYTOSTR(tvValue)
	Return _vfp.fxAnyToString.ToString(@tvValue)
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

Function AJOIN(tArray, tcSep)
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

Function ASPLIT(tcString, tcDelimiter)
	Local loString
	loString = Createobject("TString", tcString)
	Return loString.Split(tcDelimiter)
Endfunc

Function MATCH(tcString, tcPattern)
	_vfp.foxExtendsRegEx.Pattern = tcPattern
	Return _vfp.foxExtendsRegEx.test(tcString)
Endfunc

Function AMATCH(tcString, tcPattern, tnOccurrences)
	Local loResult, laItems, i
	_vfp.foxExtendsRegEx.Pattern = tcPattern
	loResult = _vfp.foxExtendsRegEx.Execute(tcString)
	If Type('loResult') != 'O'
		Return ""
	Endif

	If Empty(tnOccurrences) Or !Between(tnOccurrences, 1, loResult.Count)
		tnOccurrences = loResult.Count
	Endif
	If Type('loResult.Item[tnOccurrences-1]') != 'O'
		Return ""
	Endif
	laItems = Createobject("TFoxExtendsInternalArray")
	laItems.Push(loResult.Item[tnOccurrences-1].Value)

	Return laItems.GetArray()
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
	* Convert escaping charcters
	If At('\t', tcFormat) > 0
		tcFormat = Strtran(tcFormat, '\t', Chr(9))
	Endif
	If At('\r', tcFormat) > 0
		tcFormat = Strtran(tcFormat, '\r', Chr(13))
	Endif
	If At('\n', tcFormat) > 0
		tcFormat = Strtran(tcFormat, '\n', Chr(10))
	Endif
	If At('\"', tcFormat) > 0
		tcFormat = Strtran(tcFormat, '\"', '"')
	Endif
	If At("\'", tcFormat) > 0
		tcFormat = Strtran(tcFormat, "\'", "'")
	Endif

	Return tcFormat
Endfunc

Function ALIST(tvVal1, tvVal2, tvVal3, tvVal4, tvVal5, tvVal6, tvVal7, tvVal8, tvVal9, tvVal10, ;
		tvVal11, tvVal12, tvVal13, tvVal14, tvVal15, tvVal16, tvVal17, tvVal18, tvVal19, tvVal20)
	Local laTuple, i
	laTuple = Createobject("TFoxExtendsInternalArray")
	For i = 1 To Pcount()
		laTuple.Push(Evaluate("tvVal" + Alltrim(Str(i))))
	Endfor
	Return laTuple.GetArray()
Endfunc

Function CLAMP(tcString, tnFrom, tnTo)
	Return Substr(tcString, tnFrom, tnTo - tnFrom)
Endfunc

Function AMAP(tArray, tcPredicate)
	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	Endif
	Local laResult, i, lcExp
	laResult = Createobject("TFoxExtendsInternalArray")
	For i = 1 To Alen(tArray, 1)
		lcExp = Strtran(tcPredicate, "$0", Transform(tArray[i]))
		laResult.Push(Evaluate(lcExp))
	Endfor
	Return laResult.GetArray()
Endfunc

Function AFILTER(tArray, tcPredicate)
	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	Endif
	Local laResult, i, lcExp
	laResult = Createobject("TFoxExtendsInternalArray")
	For i = 1 To Alen(tArray, 1)
		lcExp = Strtran(tcPredicate, "$0", Transform(tArray[i]))
		If Evaluate(lcExp)
			laResult.Push(tArray[i])
		Endif
	Endfor
	Return laResult.GetArray()
Endfunc

Function AFIELDSOBJ(tvAliasOrDataSession)
	Local i, j, k, laData, laProperties, loFieldStruct
	i = Afields(laFields, tvAliasOrDataSession)
	laProperties = ALIST("name", ;
		"field_type", ;
		"field_width", ;
		"decimal_places", ;
		"null_allowed", ;
		"code_page_translation_not_allowed", ;
		"field_validation_expression", ;
		"field_validation_text", ;
		"field_default_value", ;
		"table_validation_expression", ;
		"table_validation_text", ;
		"long_table_name", ;
		"insert_trigger_expression", ;
		"update_trigger_expression", ;
		"delete_trigger_expression", ;
		"table_comment", ;
		"next_value_for_autoincrementing", ;
		"step_for_autoincrementing")

	laData = Createobject('TFoxExtendsInternalArray')
	For j = 1 To i
		loFieldStruct = Createobject('Empty')
		For k = 1 To Alen(laProperties)
			=AddProperty(loFieldStruct, laProperties[k], laFields[j, k])
		Endfor
		laData.Push(loFieldStruct)
	Endfor

	Return laData.GetArray()
Endfunc

Function ADIROBJ(tcFileSkeleton, tcAttribute, tnFlags)
	Local i, j, k, laData, laProperties, loDirStruct
	Do Case
	Case Pcount() = 1
		i = Adir(laDir, tcFileSkeleton)
	Case Pcount() = 2
		i = Adir(laDir, tcFileSkeleton, tcAttribute)
	Case Pcount() = 3
		i = Adir(laDir, tcFileSkeleton, tcAttribute, tnFlags)
	Otherwise
		Return .Null.
	Endcase

	laProperties = ALIST("file_name", ;
		"file_size", ;
		"date_last_modified", ;
		"time_last_modified", ;
		"file_attributes")

	laData = Createobject('TFoxExtendsInternalArray')
	For j = 1 To i
		loDirStruct = Createobject('Empty')
		For k = 1 To Alen(laProperties)
			=AddProperty(loDirStruct, laProperties[k], laDir[j, k])
		Endfor
		laData.Push(loDirStruct)
	Endfor

	Return laData.GetArray()
Endfunc

Function SECRETBOX(tcPrompt, tcCaption)

	If Empty(Pcount())
		Error TOO_FEW_ARGUMENTS
	Endif

	Local lcPrompt, lcCaption, lcResult, loSecret
	Store '' To lcPrompt, lcCaption

	Do Case
	Case Pcount() = 1
		lcPrompt = tcPrompt
	Case Pcount() = 2
		lcPrompt = tcPrompt
		lcCaption = tcCaption
	Endcase
	lcResult = ''

	loSecret = Createobject("TFoxExtendsFrmSecret", lcPrompt, lcCaption)
	loSecret.Show(1)
	lcResult = loSecret.cResult
	Release loSecret

	Return Alltrim(lcResult)

Endfunc

Function ARGS(tvPar1, tvPar2, tvPar3, tvPar4, tvPar5, tvPar6, tvPar7, tvPar8, tvPar9, tvPar10, ;
		tvPar11, tvPar12, tvPar13, tvPar14, tvPar15, tvPar16, tvPar17, tvPar18, tvPar19, tvPar20, ;
		tvPar21, tvPar22, tvPar23, tvPar24, tvPar25, tvPar26, tvPar27, tvPar28, tvPar29, tvPar30, ;
		tvPar31, tvPar32, tvPar33, tvPar34, tvPar35, tvPar36, tvPar37, tvPar38, tvPar39, tvPar40, ;
		tvPar41, tvPar42, tvPar43, tvPar44, tvPar45, tvPar46, tvPar47, tvPar48, tvPar49, tvPar50, ;
		tvPar51, tvPar52, tvPar53, tvPar54, tvPar55, tvPar56, tvPar57, tvPar58, tvPar59, tvPar60, ;
		tvPar61, tvPar62, tvPar63, tvPar64, tvPar65, tvPar66, tvPar67, tvPar68, tvPar69, tvPar70, ;
		tvPar71, tvPar72, tvPar73, tvPar74, tvPar75, tvPar76, tvPar77, tvPar78, tvPar79, tvPar80, ;
		tvPar81, tvPar82, tvPar83, tvPar84, tvPar85, tvPar86, tvPar87, tvPar88, tvPar89, tvPar90, ;
		tvPar91, tvPar92, tvPar93, tvPar94, tvPar95, tvPar96, tvPar97, tvPar98, tvPar99, tvPar100)
	Local loVarArg, i
	loVarArg = Createobject('Empty')
	=AddProperty(loVarArg, 'args[' + Alltrim(Str(Pcount())) + ']', .Null.)
	For i = 1 To Pcount()
		loVarArg.ARGS[i] = Evaluate("tvPar" + Alltrim(Str(i)))
	Endfor
	Return loVarArg
Endfunc

Function APARAMS(toArgs)
	Local lnNumArgs, laArgs, i
	lnNumArgs = 0
	Try
		lnNumArgs = Alen(toArgs.ARGS)
	Catch
		Error FUNCTION_ARG_VALUE_INVALID
	Endtry

	laArgs = Createobject("TFoxExtendsInternalArray")
	For i = 1 To lnNumArgs
		laArgs.Push(toArgs.ARGS[i])
	Endfor

	Return laArgs.GetArray()
Endfunc

Function STRINGLIST(toStrList)
	Local lnCount, i, loStringList
	lnCount = 0
	Try
		lnCount = Alen(toStrList.ARGS)
	Catch
	Endtry
	loStringList = Createobject("TStringList")
	For i = 1 To lnCount
		loStringList.Add(toStrList.ARGS[i])
	Endfor

	Return loStringList
Endfunc

Function AZIP(tArray1, tArray2)
	If Type('tArray1', 1) != 'A' Or Type('tArray2', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	Endif
	Local lnLenArray1, lnLenArray2, i, lnCount, laResult, loPair
	lnLenArray1 = Alen(tArray1, 1)
	lnLenArray2 = Alen(tArray2, 1)
	If lnLenArray1 < lnLenArray2
		lnCount = lnLenArray1
	Else
		lnCount = lnLenArray2
	Endif
	laResult = Createobject("TFoxExtendsInternalArray")

	For i = 1 To lnCount
		loPair = Createobject('Empty')
		=AddProperty(loPair, 'left', tArray1[i])
		=AddProperty(loPair, 'right', tArray2[i])
		laResult.Push(loPair)
	Endfor

	Return laResult.GetArray()
Endfunc

Function HASHTABLE(tvPar1, tvPar2, tvPar3, tvPar4, tvPar5, tvPar6, tvPar7, tvPar8, tvPar9, tvPar10, ;
		tvPar11, tvPar12, tvPar13, tvPar14, tvPar15, tvPar16, tvPar17, tvPar18, tvPar19, tvPar20, ;
		tvPar21, tvPar22, tvPar23, tvPar24, tvPar25, tvPar26, tvPar27, tvPar28, tvPar29, tvPar30, ;
		tvPar31, tvPar32, tvPar33, tvPar34, tvPar35, tvPar36, tvPar37, tvPar38, tvPar39, tvPar40, ;
		tvPar41, tvPar42, tvPar43, tvPar44, tvPar45, tvPar46, tvPar47, tvPar48, tvPar49, tvPar50, ;
		tvPar51, tvPar52, tvPar53, tvPar54, tvPar55, tvPar56, tvPar57, tvPar58, tvPar59, tvPar60, ;
		tvPar61, tvPar62, tvPar63, tvPar64, tvPar65, tvPar66, tvPar67, tvPar68, tvPar69, tvPar70, ;
		tvPar71, tvPar72, tvPar73, tvPar74, tvPar75, tvPar76, tvPar77, tvPar78, tvPar79, tvPar80, ;
		tvPar81, tvPar82, tvPar83, tvPar84, tvPar85, tvPar86, tvPar87, tvPar88, tvPar89, tvPar90, ;
		tvPar91, tvPar92, tvPar93, tvPar94, tvPar95, tvPar96, tvPar97, tvPar98, tvPar99, tvPar100)
	If Mod(Pcount(), 2) = 1
		Error HASHTABLE_PARAMS_MISTMATCH
	Endif
	Local i, loDict
	loDict = Createobject('Empty')
	For i = 1 To Pcount() Step 2
		If Type("tvPar" + Alltrim(Str(i))) != 'C'
			Error HASHTABLE_INVALID_KEY
		Endif
		=AddProperty(loDict, Evaluate("tvPar" + Alltrim(Str(i))), Evaluate("tvPar" + Alltrim(Str(i+1))))
	Endfor
	Return loDict
Endfunc


Function HASKEY(toDict, tcKey)
	Local lbResult
	Try
		lbResult = Type('toDict.' + tcKey) != 'U'
	Catch
		lbResult = .F.
	Endtry

	Return lbResult
Endfunc


Function ADDKEY(toDict, tcKey, tvValue)
	If !HASKEY(toDict, tcKey)
		=AddProperty(toDict, tcKey, tvValue)
	Endif
Endfunc

Function REMOVEKEY(toDict, tcKey)
	If Type('toDict') != 'O'
		Return .F.
	Endif
	If HASKEY(toDict, tcKey)
		=Removeproperty(toDict, tcKey)
		Return .T.
	Endif
	Return .F.
Endfunc

Function GETVALUE(toDict, tcKey)
	If Type('toDict') != 'O'
		Return .Null.
	Endif
	If HASKEY(toDict, tcKey)
		Return Evaluate("toDict." + tcKey)
	Endif
	Return .Null.
Endfunc

Function AKEYS(toDict)
	Local i, laResult, lnCount
	lnCount = Amembers(laKeys, toDict, 0, "PHGNUCIBR")
	If lnCount > 0
		laResult = Createobject("TFoxExtendsInternalArray")
		For i = 1 To lnCount
			laResult.Push(laKeys[i])
		Endfor
		Return laResult.GetArray()
	Else
		Return .Null.
	Endif
Endfunc

Function ASLICE(tArray, tcRange)
	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	Endif
	Local laSlice, lnFirst, lnLast, lnLen, i
	laSlice = Createobject("TFoxExtendsInternalArray")
	lnLen = Alen(tArray, 1)
	Do Case
	Case MATCH(tcRange, '^\w+\.\.\w+$') && DIGIT .. DIGIT
		lnFirst = AMATCH(tcRange, '\w+', 1)
		lnFirst = Val(lnFirst[1])
		lnLast = AMATCH(tcRange, '\w+', 2)
		lnLast = Val(lnLast[1])

	Case MATCH(tcRange, '^\.\.\w+$')	&& .. DIGIT
		lnFirst = 1
		lnLast = AMATCH(tcRange, '\w+', 2)
		lnLast = Val(lnLast[1])

	Case MATCH(tcRange, '^\w+\.\.$')	&& DIGIT ..
		lnFirst = AMATCH(tcRange, '\w+', 1)
		lnFirst = Val(lnFirst[1])
		lnLast = lnLen

	Case MATCH(tcRange, '^\w+$')	&& +DIGIT
		lnFirst = 1
		lnLast = Val(tcRange)
	Case MATCH(tcRange, '^\-\w+$')	&& -DIGIT
		lnFirst = lnLen - Abs(Val(tcRange))	+ 1
		lnLast = lnLen
	Otherwise
		lnFirst = 1
		lnLast = lnLen
	Endcase
	* Check out of bounds
	If !Between(lnFirst, 1, lnLen) Or !Between(lnLast, 1, lnLen)
		Return .Null.
	Endif

	* Extract elements
	For i = lnFirst To lnLast
		laSlice.Push(tArray[i])
	Endfor

	Return laSlice.GetArray()
Endfunc

Function AINTERSECT(tArray1, tArray2)
	If Type('tArray1', 1) != 'A' Or Type('tArray2', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	Endif

	Local laResult, i, j, k
	laResult = Createobject("TFoxExtendsInternalArray")

	For i = 1 To Alen(tArray1, 1)
		k = Ascan(tArray2, tArray1[i])
		If k > 0
			laResult.Push(tArray1[i])
			k = 0
		Endif
	Endfor

	Return laResult.GetArray()
EndFunc

Function ALEFT(tArray, tnExpression)
	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	EndIf
	
	Local laResult, i, lnExpression, j
	lnExpression = Evaluate("tnExpression")
	If Type('lnExpression') != 'N'
		Error FUNCTION_ARG_VALUE_INVALID
	EndIf
	If lnExpression <= 0
		Return .F.
	EndIf		
	j = Alen(tArray, 1)
	If lnExpression > j
		lnExpression = j
	EndIf
	
	laResult = Createobject("TFoxExtendsInternalArray")
	For i = 1 To lnExpression
		laResult.Push(tArray[i])
	Endfor

	Return laResult.GetArray()
EndFunc


Function ARIGHT(tArray, tnExpression)

	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	EndIf
	
	Local laResult, i, lnExpression, lnArrayLen, lnTo
	lnExpression = Evaluate("tnExpression")
	If Type('lnExpression') != 'N'
		Error FUNCTION_ARG_VALUE_INVALID
	EndIf

	If lnExpression <= 0
		lnExpression = 1
	EndIf
	
	lnArrayLen = Alen(tArray, 1)

	If lnExpression > lnArrayLen
		lnExpression = lnArrayLen
	endif

	laResult = Createobject("TFoxExtendsInternalArray")
	lnTo = lnArrayLen-lnExpression
	If lnTo <= 0
		For i = 1 to Alen(tArray, 1)		
			laResult.Push(tArray[i])
		EndFor
	else
		lnTo = lnArrayLen - lnTo
		i = 1	
		Do while lnTo >= i	
			If i == 1
				laResult.Push(tArray[lnArrayLen])
			Else
				laResult.Push(tArray[lnArrayLen-i])
			EndIf
			i = i + 1
		EndDo
	EndIf

	Return laResult.GetArray()
EndFunc

Function ASUBSTR(tArray, tnFromExp, tnToExp)
	If Type('tArray', 1) != 'A'
		Error FUNCTION_ARG_VALUE_INVALID
	EndIf
	
	Local laResult, i, lnStart, lnEnd, j
	lnStart = Evaluate("tnFromExp")
	If Type('lnStart') != 'N'
		Error FUNCTION_ARG_VALUE_INVALID
	EndIf

	lnEnd = Evaluate("tnToExp")
	If Type('lnEnd') != 'N'
		Error FUNCTION_ARG_VALUE_INVALID
	EndIf
	j = Alen(tArray, 1)
	
	If !Between(lnStart, 1, j)
		Return .f.
	EndIf
	
	If lnEnd <= 0
		Return .f.
	EndIf
	If lnEnd > j
		lnEnd = j
	EndIf

	laResult = Createobject("TFoxExtendsInternalArray")

	i = 0
	Do while (lnEnd > 0) and (lnStart+i <= j)
		laResult.Push(tArray[lnStart+i])
		i = i + 1
		lnEnd = lnEnd - 1
	EndDo	

	Return laResult.GetArray()
EndFunc

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
			Return This.GETVALUE(tValue, Vartype(tValue))
		Endcase
	Endfunc

	Function Destroy
		If This.lCentury
			Set Century Off
		Endif
		lcDateAct = This.cDateAct
		Set Date &lcDateAct
	Endfunc

	Function GETVALUE As String
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

* ============================================================ *
* TDictionary
* ============================================================ *
Define Class TDictionary As TIterable
	Hidden Items

	Function Init
		DoDefault()
		This.Items = Createobject("Collection")
	Endfunc

	Function Add(tcKey As String, tvValue As variant)
		If !Empty(This.Items.GetKey(tcKey))
			This.Items.Remove(tcKey)
		Endif
		This.Items.Add(tvValue, tcKey)
	Endfunc

	Function Get(tcKey As String) As variant
		Local lnIndex
		lnIndex = This.Items.GetKey(tcKey)
		Return Iif(Empty(lnIndex), .Null., This.Items.Item(lnIndex))
	Endfunc

	Function ContainsKey(tcKey As String) As Boolean
		lnItem = This.Items.GetKey(tcKey)
		Return This.Items.GetKey(tcKey) > 0
	Endfunc

	Function Clear
		This.Items = Createobject("Collection")
	Endfunc

	Function GetDataByIndex
		Local lvKey, lvValue
		lvKey = This.Items.Item(This.nIteratorCounter)
		lvValue = This.Items.GetKey(This.nIteratorCounter)
		Return This.CreatePair(lvKey, lvValue)
	Endfunc

	Function GetLen
		Return This.Items.Count
	Endfunc

	Hidden Function CreatePair(tvKey, tvValue)
		Local loPair
		loPair = Createobject('Empty')
		AddProperty(loPair, 'key', tvKey)
		AddProperty(loPair, 'value', tvValue)
		Return loPair
	Endfunc

	Function ToString
		If This.GetLen() > 0
			Local lcStr, i
			lcStr = '{'
			For i = 1 To This.GetLen()
				If Len(lcStr) = 1 Then
					lcStr = lcStr + _vfp.fxAnyToString.ToString(This.Items.GetKey(i)) + ':' + This.ObjToString(This.Items.Item(i))
				Else
					lcStr = lcStr + ',' + _vfp.fxAnyToString.ToString(This.Items.GetKey(i)) + ':' + This.ObjToString(This.Items.Item(i))
				Endif
			Endfor
			lcStr = lcStr + '}'
			Return lcStr
		Else
			Return '{}'
		Endif
	Endfunc

	Function ObjToString(toObj)
		Local lcStr
		lcStr = Space(1)
		Try
			lcStr = toObj.ToString()
		Catch
			lcStr = _vfp.fxAnyToString.ToString(toObj)
		Endtry
		Return lcStr
	Endfunc

Enddefine

* ============================================================ *
* TArray
* ============================================================ *
Define Class tArray As TIterable
	Dimension aCustomArray[1]
	nIndex = 0

	Function Init
		DoDefault()
	Endfunc

	Function Push(tvItem)
		This.nIndex = This.nIndex + 1
		Dimension This.aCustomArray[this.nIndex]
		This.aCustomArray[this.nIndex] = tvItem
	Endfunc

	Function Pop
		This.nIndex = This.nIndex - 1
		If This.nIndex <= 0
			This.nIndex = 0
			Dimension This.aCustomArray[1]
			Return
		Endif

		Dimension This.aCustomArray[this.nIndex]
	Endfunc

	Function Get(tnIndex)
		If Between(tnIndex, 1, This.GetLen())
			Return This.aCustomArray[tnIndex]
		Endif
		Return .Null.
	Endfunc

	Function Set(tnIndex, tvValue)
		If Between(tnIndex, 1, This.GetLen())
			This.aCustomArray[tnIndex] = tvValue
		Endif
	Endfunc

	Function GetDataByIndex
		Return This.aCustomArray[this.nIteratorCounter]
	Endfunc

	Function GetLen
		Return This.nIndex
	Endfunc

	Function ToString
		If This.nIndex > 0
			Acopy(This.aCustomArray, laData)
			Return _vfp.fxAnyToString.ToString(@laData)
		Else
			Return '[]'
		Endif
	Endfunc

Enddefine

* ============================================================ *
* TStringList
* ============================================================ *
Define Class TStringList As TIterable
	Dimension aCustomArray[1]
	nIndex = 0

	Function Init
		DoDefault()
	Endfunc

	Function Add(tcItem)
		If Type('tcItem') != 'C'
			Return
		Endif
		This.nIndex = This.nIndex + 1
		Dimension This.aCustomArray[this.nIndex]
		This.aCustomArray[this.nIndex] = tcItem
	Endfunc

	Function GetDataByIndex
		Return This.aCustomArray[this.nIteratorCounter]
	Endfunc

	Function GetLen
		Return This.nIndex
	Endfunc

	Function ToString
		Return This.Join()
	Endfunc

	Function Join(tcSep)
		If This.nIndex > 0
			Local lcStr, i, lcVal
			lcStr = Space(1)
			For i = 1 To This.GetLen()
				lcVal = This.aCustomArray[i]
				If i = 1 Then
					lcStr = lcVal
				Else
					lcStr = lcStr + Iif(!Empty(tcSep), tcSep + lcVal, lcVal)
				Endif
			Endfor
			Return lcStr
		Else
			Return ''
		Endif
	Endfunc

Enddefine

* ============================================================ *
* TIterable
* ============================================================ *
Define Class TIterable As Custom
	Hidden nIteratorCounter
	Len = 0

	Function Init
		This.nIteratorCounter = 1
	Endfunc

	Function hasNext
		If This.nIteratorCounter > This.GetLen() Then
			This.nIteratorCounter = 0
			Return .F.
		Endif
		Return .T.
	Endfunc

	Function Next
		Local lvValue
		lvValue = This.GetDataByIndex()
		This.nIteratorCounter = This.nIteratorCounter + 1
		Return lvValue
	Endfunc

	Function GetDataByIndex
		* abstract
	Endfunc

	Function GetLen
		* abstract
	Endfunc

	Function Len_Access
		Return This.GetLen()
	Endfunc

	Function ToString

	Endfunc

Enddefine

* ============================================================ *
* TFoxExtendsInternalArray
* ============================================================ *
Define Class TFoxExtendsInternalArray As Custom
	Dimension aCustomArray[1]
	nIndex = 0

	Function Push(tvItem)
		This.nIndex = This.nIndex + 1

		Dimension This.aCustomArray[this.nIndex]
		This.aCustomArray[this.nIndex] = tvItem
	Endfunc

	Function GetArray
		Return @This.aCustomArray
	Endfunc

Enddefine


**************************************************
* Class TFoxExtendsFrmSecret
Define Class TFoxExtendsFrmSecret As Form

	BorderStyle = 2
	Height = 88
	Width = 396
	DoCreate = .T.
	AutoCenter = .T.
	Caption = ""
	MaxButton = .F.
	MinButton = .F.
	WindowType = 1
	cResult = ""
	Name = "FrmSecret"


	Add Object lbl_titulo As Label With ;
		FontName = "MS Sans Serif", ;
		BackStyle = 0, ;
		Caption = "Label1", ;
		Height = 17, ;
		Left = 8, ;
		Top = 12, ;
		Visible = .T., ;
		Width = 380, ;
		TabIndex = 1, ;
		Name = "LBL_TITULO"


	Add Object text1 As TextBox With ;
		FontName = "Wingdings", ;
		ControlSource = "thisform.cResult", ;
		Height = 23, ;
		Left = 8, ;
		TabIndex = 2, ;
		Top = 30, ;
		Width = 380, ;
		PasswordChar = "l", ;
		Name = "Text1"


	Add Object btn_ok As CommandButton With ;
		Top = 58, ;
		Left = 242, ;
		Height = 23, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 3, ;
		Name = "BTN_OK"


	Add Object btn_cancel As CommandButton With ;
		Top = 58, ;
		Left = 316, ;
		Height = 23, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		Default = .F., ;
		TabIndex = 4, ;
		Name = "BTN_CANCEL"


	Procedure Init
		Lparameters tcPrompt, tcCaption

		If Empty(tcPrompt)
			tcPrompt = ''
		Endif

		If Empty(tcCaption)
			tcCaption = _Screen.Caption
		Endif

		This.Caption = tcCaption
		This.lbl_titulo.Caption = tcPrompt
	Endproc

	Procedure btn_ok.Click
		Thisform.Hide()
	Endproc


	Procedure btn_cancel.Click
		Thisform.cResult = ''
		Thisform.Hide()
	Endproc


Enddefine

Function NEWGUID
	* Credits from: https://fox.wikis.com/wc.dll?Wiki~GUIDGenerationCode
	Local lcbuffer, lnResult, lcGuid, lcResult

	Declare Integer CoCreateGuid In ole32.Dll String@ pguid
	Declare Integer StringFromGUID2 In ole32.Dll String  pguid, String  @lpszBuffer, Integer cbBuffer

	lcGuid   = Space(16) && 16 Byte = 128 Bit
	lnResult = CoCreateGuid(@lcGuid)
	lcbuffer = Space(78)
	lnResult = StringFromGUID2(lcGuid, @lcbuffer, Len(lcbuffer)/2)

	Clear Dlls "CoCreateGuid", "StringFromGUID2"

	lcResult = Strconv((Left(lcbuffer,(lnResult-1)*2)),6)
	Return Substr(lcResult, 2, Len(lcResult) - 2) && remove {}
Endfunc