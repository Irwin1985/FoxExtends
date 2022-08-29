**********************************************************************
* VFP extended methods
**********************************************************************

#IFNDEF FUNCTION_ARG_VALUE_INVALID
	#DEFINE FUNCTION_ARG_VALUE_INVALID 11
#ENDIF

#IFNDEF JSONFOX_NOT_FOUND
	#DEFINE JSONFOX_NOT_FOUND 'JSONFOX.APP does not exist in your PATH() directories. Please make sure JSONFOX.APP can be found by your application.'
#ENDIF

FUNCTION PAIR(tvKey, tvValue)
	LOCAL loPair
	loPair = CREATEOBJECT('Empty')
	ADDPROPERTY(loPair, 'key', tvKey)
	ADDPROPERTY(loPair, 'value', tvValue)
	RETURN loPair
ENDFUNC

FUNCTION ANYTOSTR(tvValue)
	LOCAL loAnyToStr
	loAnyToStr = CREATEOBJECT("AnyToString")
	RETURN loAnyToStr.AnyToStr(@tvValue)
ENDFUNC

FUNCTION APUSH(tArray, tvItem)
	IF TYPE('tArray', 1) != 'A'
		ERROR FUNCTION_ARG_VALUE_INVALID
	ENDIF
	LOCAL lnIndex
	lnIndex = ALEN(tArray, 1) + 1
	DIMENSION tArray[lnIndex]
	tArray[lnIndex] = tvItem
ENDFUNC

FUNCTION APOP(tArray)
	IF TYPE('tArray', 1) != 'A'
		ERROR FUNCTION_ARG_VALUE_INVALID
	ENDIF
	LOCAL lnIndex, lvOldVal
	lnIndex = ALEN(tArray, 1)
	lnIndex = lnIndex - 1
	IF lnIndex <= 0
		lnIndex = 1
		DIMENSION tArray[lnIndex]
		RETURN
	ENDIF
	lvOldVal = tArray[lnIndex+1]
	DIMENSION tArray[lnIndex]
	
	RETURN lvOldVal
ENDFUNC

FUNCTION JOIN(tArray, tcSep)
	IF TYPE('tArray', 1) != 'A'
		ERROR FUNCTION_ARG_VALUE_INVALID
	ENDIF

	LOCAL lcStr, i, lcVal
	lcStr = ''
	FOR i = 1 TO ALEN(tArray)
		lcVal = tArray[i]
		IF i = 1 THEN
			lcStr = lcVal
		ELSE
			lcStr = lcStr + IIF(!EMPTY(tcSep), tcSep + lcVal, lcVal)
		ENDIF
	ENDFOR
	RETURN lcStr
ENDFUNC


FUNCTION SPLIT(tcString, tcDelimiter)
	LOCAL loString
	loString = CREATEOBJECT("TString", tcString)
	RETURN loString.split(tcDelimiter)
ENDFUNC


FUNCTION MATCHES(tcString, tcPattern)
	LOCAL loRegEx, lcValue, lbResult
	loRegEx = CREATEOBJECT("VBScript.RegExp")
	loRegEx.IgnoreCase = .T.
	loRegEx.GLOBAL = .T.
	lcValue = tcString

	IF !EMPTY(lcValue)
		loRegEx.PATTERN = tcPattern
		lbResult = loRegEx.test(lcValue)
	ENDIF
	RELEASE loRegEx

	RETURN lbResult
ENDFUNC

FUNCTION REVERSE(tcString)
	LOCAL lcValue, i
	lcValue = ''
	FOR i = LEN(ALLTRIM(tcString)) TO 1 STEP -1
		lcValue = lcValue + SUBSTR(tcString, i, 1)
	ENDFOR

	RETURN lcValue
ENDFUNC

FUNCTION JSONTOSTR(tvJsonObj)
	IF !CHECKJSONAPP()
		RETURN ''
	ENDIF
	
	RETURN _SCREEN.JSON.STRINGIFY(tvJsonObj)	
ENDFUNC

FUNCTION STRTOJSON(tcJSONString)
	IF !CHECKJSONAPP()
		RETURN .Null.
	ENDIF
	
	RETURN _SCREEN.JSON.PARSE(tcJSONString)
ENDFUNC

* ========================================================================================== *
* HELPER FUNCTIONS
* ========================================================================================== *
FUNCTION CHECKJSONAPP
	* ¿DOES JSONFOX.APP EXIST?
	IF !FILE("JSONFOX.APP")
		ERROR JSONFOX_NOT_FOUND
		RETURN .F.
	ENDIF

	IF TYPE('_SCREEN.JSON') == 'O'
		_SCREEN.JSON = .NULL.
		=REMOVEPROPERTY(_SCREEN, 'JSON')
	ENDIF

	DO "JSONFOX.APP"
	RETURN .T.
ENDFUNC

* AnyToString
DEFINE CLASS AnyToString AS CUSTOM
	#DEFINE USER_DEFINED_PEMS	'U'
	#DEFINE ALL_MEMBERS			"PHGNUCIBR"
	lCentury = .F.
	cDateAct = ''
	nOrden   = 0
	cFlags 	 = ''

	FUNCTION INIT
		THIS.lCentury = SET("Century") == "OFF"
		THIS.cDateAct = SET("Date")
		SET CENTURY ON
		SET DATE ANSI
		MVCOUNT = 60000
	ENDFUNC

	FUNCTION ToString(toRefObj, tcFlags)
		lPassByRef = .T.
		TRY
			EXTERNAL ARRAY toRefObj
		CATCH
			lPassByRef = .F.
		ENDTRY
		THIS.cFlags = EVL(tcFlags, ALL_MEMBERS)
		IF lPassByRef
			RETURN THIS.AnyToStr(@toRefObj)
		ELSE
			RETURN THIS.AnyToStr(toRefObj)
		ENDIF
	ENDFUNC

	FUNCTION AnyToStr AS MEMO
		LPARAMETERS tValue AS variant
		TRY
			EXTERNAL ARRAY tValue
		CATCH
		ENDTRY
		DO CASE
		CASE TYPE("tValue", 1) = 'A'
			LOCAL k, j, lcArray
			IF ALEN(tValue, 2) == 0
				*# Unidimensional array
				lcArray = '['
				FOR k = 1 TO ALEN(tValue)
					lcArray = lcArray + IIF(LEN(lcArray) > 1, ',', '')
					TRY
						=ACOPY(tValue[k], aLista)
						lcArray = lcArray + THIS.AnyToStr(@aLista)
					CATCH
						lcArray = lcArray + THIS.AnyToStr(tValue[k])
					ENDTRY
				ENDFOR
				lcArray = lcArray + ']'
			ELSE
				*# Multidimensional array support
				lcArray = '['
				FOR k = 1 TO ALEN(tValue, 1)
					lcArray = lcArray + IIF(LEN(lcArray) > 1, ',', '')

					* # begin of rows
					lcArray = lcArray + '['
					FOR j = 1 TO ALEN(tValue, 2)
						IF j > 1
							lcArray = lcArray + ','
						ENDIF
						TRY
							=ACOPY(tValue[k, j], aLista)
							lcArray = lcArray + THIS.AnyToStr(@aLista)
						CATCH
							lcArray = lcArray + THIS.AnyToStr(tValue[k, j])
						ENDTRY
					ENDFOR
					lcArray = lcArray + ']'
					* # end of rows
				ENDFOR
				lcArray = lcArray + ']'
			ENDIF
			RETURN lcArray

		CASE VARTYPE(tValue) = 'O'
			LOCAL j, lcStr, lnTot
			LOCAL ARRAY gaMembers(1)

			lcStr = '{'
			lnTot = AMEMBERS(gaMembers, tValue, 0, THIS.cFlags)
			FOR j=1 TO lnTot
				lcProp = LOWER(ALLTRIM(gaMembers[j]))
				lcStr = lcStr + IIF(LEN(lcStr) > 1, ',', '') + '"' + lcProp + '":'
				TRY
					=ACOPY(tValue. &gaMembers[j], aCopia)
					lcStr = lcStr + THIS.AnyToStr(@aCopia)
				CATCH
					TRY
						lcStr = lcStr + THIS.AnyToStr(tValue. &gaMembers[j])
					CATCH
						lcStr = lcStr + "{}"
					ENDTRY
				ENDTRY
			ENDFOR

			*//> Collection based class object support
			llIsCollection = .F.
			TRY
				llIsCollection = (tValue.BASECLASS == "Collection" AND tValue.CLASS == "Collection" AND tValue.NAME == "Collection")
			CATCH
			ENDTRY
			IF llIsCollection
				lcComma   = IIF(RIGHT(lcStr, 1) != '{', ',', '')
				lcStr = lcStr + lcComma + '"Collection":['
				FOR i=1 TO tValue.COUNT
					lcStr = lcStr + IIF(i>1,',','') + THIS.AnyToStr(tValue.ITEM(i))
				ENDFOR
				lcStr = lcStr + ']'
			ENDIF
			*//> Collection based class object support

			lcStr = lcStr + '}'
			RETURN lcStr
		OTHERWISE
			RETURN THIS.GetValue(tValue, VARTYPE(tValue))
		ENDCASE
	ENDFUNC

	FUNCTION DESTROY
		IF THIS.lCentury
			SET CENTURY OFF
		ENDIF
		lcDateAct = THIS.cDateAct
		SET DATE &lcDateAct
	ENDFUNC

	FUNCTION GetValue AS STRING
		LPARAMETERS tcValue AS STRING, tctype AS CHARACTER
		DO CASE
		CASE tctype $ "CDTBGMQVWX"
			DO CASE
			CASE tctype = "D"
				tcValue = '"' + STRTRAN(DTOC(tcValue), ".", "-") + '"'
			CASE tctype = "T"
				tcValue = '"' + STRTRAN(TTOC(tcValue), ".", "-") + '"'
			OTHERWISE
				IF tctype = "X"
					tcValue = "null"
				ELSE
					tcValue = THIS.getstring(tcValue)
				ENDIF
			ENDCASE
			tcValue = ALLTRIM(tcValue)
		CASE tctype $ "YFIN"
			tcValue = STRTRAN(TRANSFORM(tcValue), ',', '.')
		CASE tctype = "L"
			tcValue = IIF(tcValue, "true", "false")
		ENDCASE
		RETURN tcValue
	ENDFUNC

	FUNCTION getstring AS STRING
		LPARAMETERS tcString AS STRING, tlParseUtf8 AS Boolean
		tcString = ALLT(tcString)
		tcString = STRTRAN(tcString, '\', '\\' )
		tcString = STRTRAN(tcString, CHR(9),  '\t' )
		tcString = STRTRAN(tcString, CHR(10), '\n' )
		tcString = STRTRAN(tcString, CHR(13), '\r' )
		tcString = STRTRAN(tcString, '"', '\"' )

		IF tlParseUtf8
			tcString = STRTRAN(tcString,"&","\u0026")
			tcString = STRTRAN(tcString,"+","\u002b")
			tcString = STRTRAN(tcString,"-","\u002d")
			tcString = STRTRAN(tcString,"#","\u0023")
			tcString = STRTRAN(tcString,"%","\u0025")
			tcString = STRTRAN(tcString,"²","\u00b2")
			tcString = STRTRAN(tcString,'à','\u00e0')
			tcString = STRTRAN(tcString,'á','\u00e1')
			tcString = STRTRAN(tcString,'è','\u00e8')
			tcString = STRTRAN(tcString,'é','\u00e9')
			tcString = STRTRAN(tcString,'ì','\u00ec')
			tcString = STRTRAN(tcString,'í','\u00ed')
			tcString = STRTRAN(tcString,'ò','\u00f2')
			tcString = STRTRAN(tcString,'ó','\u00f3')
			tcString = STRTRAN(tcString,'ù','\u00f9')
			tcString = STRTRAN(tcString,'ú','\u00fa')
			tcString = STRTRAN(tcString,'ü','\u00fc')
			tcString = STRTRAN(tcString,'À','\u00c0')
			tcString = STRTRAN(tcString,'Á','\u00c1')
			tcString = STRTRAN(tcString,'È','\u00c8')
			tcString = STRTRAN(tcString,'É','\u00c9')
			tcString = STRTRAN(tcString,'Ì','\u00cc')
			tcString = STRTRAN(tcString,'Í','\u00cd')
			tcString = STRTRAN(tcString,'Ò','\u00d2')
			tcString = STRTRAN(tcString,'Ó','\u00d3')
			tcString = STRTRAN(tcString,'Ù','\u00d9')
			tcString = STRTRAN(tcString,'Ú','\u00da')
			tcString = STRTRAN(tcString,'Ü','\u00dc')
			tcString = STRTRAN(tcString,'ñ','\u00f1')
			tcString = STRTRAN(tcString,'Ñ','\u00d1')
			tcString = STRTRAN(tcString,'©','\u00a9')
			tcString = STRTRAN(tcString,'®','\u00ae')
			tcString = STRTRAN(tcString,'ç','\u00e7')
		ENDIF

		RETURN '"' +tcString + '"'
	ENDFUNC
ENDDEFINE


Define Class TString as custom
	Value = ''
	Dimension aWords[1]
	Function init(tcStartValue)
		If Pcount() = 1
			If Type('tcStartValue') == 'C'
				this.Value = tcStartValue
			Else
				Error 'Invalid data type for string.'
			EndIf
		Else
			this.Value = Space(1)
		EndIf
	EndFunc
	
	Function Split(tcDelimiter)
		Local tcWord, i
		For i = 1 to GetWordCount(this.value, tcDelimiter)
			Dimension this.aWords[i]
			this.aWords[i] = GetWordNum(this.value, i, tcDelimiter)
		EndFor
		Return @this.aWords
	EndFunc
	
	Function Lines
		Local tcWord, i, lcValue
		lcValue = Strtran(this.value, Chr(10))
		For i = 1 to GetWordCount(lcValue, Chr(13))
			Dimension this.aWords[i]
			this.aWords[i] = GetWordNum(lcValue, i, Chr(13))
		EndFor
		Return @this.aWords
	EndFunc	
	
EndDefine
