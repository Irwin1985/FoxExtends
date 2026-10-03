*=============================================================================
* FOXEXTENDS.PRG - Functions Visual FoxPro 9 never had
*=============================================================================
* Author: Irwin Rodriguez
* License: MIT (see LICENSE)
* Version: 3.0.0
*
* Load:
*   SET PROCEDURE TO FoxExtends.prg ADDITIVE
*
* and call the functions: nothing to initialise, nothing left on _VFP or
* on disk.
*
*   PRINTF      "${0} has ${1} items", with \t \r \n escapes
*   NEWGUID     a new GUID
*   ENUM        ENUM("Red", "Green") -> an object with .Red = 1, .Green = 2
*   REVERSE     a text backwards
*   MATCH       .T. if a text matches a regular expression
*   AMATCH      every match of a regular expression, into an array
*   ADIROBJ     ADIR() as a Collection of objects with named properties
*   AFIELDSOBJ  AFIELDS() as a Collection of objects with named properties
*   SECRETBOX   a modal dialog that asks for a password
*
* MATCH and AMATCH use VBScript.RegExp, which Microsoft is retiring from
* Windows: they raise an error that says so on a machine without it.
*
* Changelog:
*   3.0.0 (2026-10) - Only what no other library of the stack does: arrays
*                     are FoxCollection, map/filter/sets are LinqVFP, JSON is
*                     JSONFox. No newFoxExtends(), no prefixes, no compiling
*                     into %TEMP%, nothing on _VFP, no MESSAGEBOX. MIT license.
*   2.x   (2022-2026) - GPL-3, see legacy\FoxExtends-2.x.prg
*=============================================================================

#DEFINE FX_VERSION "3.0.0"
#DEFINE FX_INVALID_ARGUMENT 11

FUNCTION FoxExtendsVersion
	RETURN FX_VERSION
ENDFUNC

*-----------------------------------------------------------------------------
* PRINTF(cFormat, v0, v1, ... v19)
* ${n} is the n-th value (from 0), as TRANSFORM() writes it; a ${n} without a
* value stays as written. Escapes in cFormat: \t \r \n \" \' \\; any other
* \x stays as written. The values are inserted as they are, not escaped.
*-----------------------------------------------------------------------------
FUNCTION PRINTF
	LPARAMETERS tcFormat, tvVal0, tvVal1, tvVal2, tvVal3, tvVal4, tvVal5, tvVal6, tvVal7, tvVal8, tvVal9, ;
		tvVal10, tvVal11, tvVal12, tvVal13, tvVal14, tvVal15, tvVal16, tvVal17, tvVal18, tvVal19
	LOCAL lcOut, lnI, lnLen, lcChar, lcNext, lnClose, lcIndex, lnValues

	IF VARTYPE(tcFormat) != "C"
		ERROR FX_INVALID_ARGUMENT
	ENDIF
	lnValues = PCOUNT() - 1
	lcOut = ""
	lnLen = LEN(tcFormat)
	lnI = 1
	DO WHILE lnI <= lnLen
		lcChar = SUBSTR(tcFormat, lnI, 1)
		DO CASE
		CASE lcChar == "\" AND lnI < lnLen
			lcNext = SUBSTR(tcFormat, lnI + 1, 1)
			DO CASE
			CASE lcNext == "t"
				lcOut = lcOut + CHR(9)
			CASE lcNext == "r"
				lcOut = lcOut + CHR(13)
			CASE lcNext == "n"
				lcOut = lcOut + CHR(10)
			CASE lcNext == '"' OR lcNext == "'" OR lcNext == "\"
				lcOut = lcOut + lcNext
			OTHERWISE
				lcOut = lcOut + lcChar + lcNext
			ENDCASE
			lnI = lnI + 2
		CASE lcChar == "$" AND SUBSTR(tcFormat, lnI + 1, 1) == "{"
			lnClose = AT("}", SUBSTR(tcFormat, lnI + 2))
			lcIndex = IIF(lnClose > 1, SUBSTR(tcFormat, lnI + 2, lnClose - 1), "")
			IF !EMPTY(lcIndex) AND fx_IsDigits(lcIndex) AND VAL(lcIndex) < lnValues AND VAL(lcIndex) <= 19
				lcOut = lcOut + TRANSFORM(EVALUATE("tvVal" + TRANSFORM(INT(VAL(lcIndex)))))
				lnI = lnI + 2 + lnClose
			ELSE
				lcOut = lcOut + lcChar
				lnI = lnI + 1
			ENDIF
		OTHERWISE
			lcOut = lcOut + lcChar
			lnI = lnI + 1
		ENDCASE
	ENDDO
	RETURN lcOut
ENDFUNC

*-- A new GUID: "4C4EC5EE-5B92-4E70-B9D8-D1A8A2FA2ABE" (36 characters, no braces)
FUNCTION NEWGUID
	LOCAL lcGuid, lcBuffer, lnChars
	DECLARE INTEGER CoCreateGuid IN ole32.dll STRING @pGuid
	DECLARE INTEGER StringFromGUID2 IN ole32.dll STRING pGuid, STRING @lpszBuffer, INTEGER cchMax
	lcGuid = SPACE(16)
	=CoCreateGuid(@lcGuid)
	lcBuffer = SPACE(78)
	lnChars = StringFromGUID2(lcGuid, @lcBuffer, 39)
	RETURN SUBSTR(STRCONV(LEFT(lcBuffer, (lnChars - 1) * 2), 6), 2, 36)
ENDFUNC

*-----------------------------------------------------------------------------
* ENUM(cName1, cName2, ... cName26): an object with one property per name,
* numbered from 1. A name that is not a valid identifier, or repeated, raises.
*-----------------------------------------------------------------------------
FUNCTION ENUM
	LPARAMETERS tcName1, tcName2, tcName3, tcName4, tcName5, tcName6, tcName7, tcName8, tcName9, ;
		tcName10, tcName11, tcName12, tcName13, tcName14, tcName15, tcName16, tcName17, tcName18, ;
		tcName19, tcName20, tcName21, tcName22, tcName23, tcName24, tcName25, tcName26
	LOCAL loEnum, lnI, lcName
	loEnum = CREATEOBJECT("Empty")
	FOR lnI = 1 TO PCOUNT()
		lcName = EVALUATE("tcName" + TRANSFORM(lnI))
		IF VARTYPE(lcName) != "C" OR !fx_IsName(lcName)
			ERROR "ENUM: '" + TRANSFORM(lcName) + "' is not a valid name"
		ENDIF
		IF PEMSTATUS(loEnum, lcName, 5)
			ERROR "ENUM: '" + lcName + "' is repeated"
		ENDIF
		=ADDPROPERTY(loEnum, lcName, lnI)
	NEXT
	RETURN loEnum
ENDFUNC

*-- The text backwards, spaces included
FUNCTION REVERSE
	LPARAMETERS tcText
	LOCAL lcOut, lnI
	IF VARTYPE(tcText) != "C"
		ERROR FX_INVALID_ARGUMENT
	ENDIF
	lcOut = ""
	FOR lnI = LEN(tcText) TO 1 STEP -1
		lcOut = lcOut + SUBSTR(tcText, lnI, 1)
	NEXT
	RETURN lcOut
ENDFUNC

*-----------------------------------------------------------------------------
* MATCH(cText, cPattern [, lCaseSensitive]): .T. if the regular expression
* matches somewhere in the text. Case is ignored unless lCaseSensitive.
*-----------------------------------------------------------------------------
FUNCTION MATCH
	LPARAMETERS tcText, tcPattern, tlCaseSensitive
	LOCAL loRegExp
	loRegExp = fx_RegExp(tcPattern, tlCaseSensitive)
	RETURN loRegExp.Test(tcText)
ENDFUNC

*-----------------------------------------------------------------------------
* AMATCH(@aMatches, cText, cPattern [, lCaseSensitive]): fills the array with
* every match, in order, and returns how many (0 leaves one empty element).
*-----------------------------------------------------------------------------
FUNCTION AMATCH
	LPARAMETERS taMatches, tcText, tcPattern, tlCaseSensitive
	EXTERNAL ARRAY taMatches
	LOCAL loRegExp, loMatches, lnCount, lnI
	loRegExp = fx_RegExp(tcPattern, tlCaseSensitive)
	loMatches = loRegExp.Execute(tcText)
	lnCount = loMatches.Count
	DIMENSION taMatches[MAX(lnCount, 1)]
	taMatches[1] = ""
	FOR lnI = 1 TO lnCount
		taMatches[lnI] = loMatches.Item(lnI - 1).Value
	NEXT
	RETURN lnCount
ENDFUNC

*-----------------------------------------------------------------------------
* ADIROBJ([cFileSkeleton [, cAttribute [, nFlags]]]): ADIR() as a Collection
* of objects with file_name, file_size, date_last_modified,
* time_last_modified and file_attributes.
*-----------------------------------------------------------------------------
FUNCTION ADIROBJ
	LPARAMETERS tcFileSkeleton, tcAttribute, tnFlags
	LOCAL lnCount, loFiles, lnRow
	LOCAL ARRAY laDir[1]
	DO CASE
	CASE PCOUNT() = 0
		lnCount = ADIR(laDir)
	CASE PCOUNT() = 1
		lnCount = ADIR(laDir, tcFileSkeleton)
	CASE PCOUNT() = 2
		lnCount = ADIR(laDir, tcFileSkeleton, tcAttribute)
	OTHERWISE
		lnCount = ADIR(laDir, tcFileSkeleton, tcAttribute, tnFlags)
	ENDCASE
	loFiles = CREATEOBJECT("Collection")
	FOR lnRow = 1 TO lnCount
		loFiles.Add(fx_RowObject(@laDir, lnRow, "file_name,file_size,date_last_modified,time_last_modified,file_attributes"))
	NEXT
	RETURN loFiles
ENDFUNC

*-----------------------------------------------------------------------------
* AFIELDSOBJ([cAlias | nWorkArea]): AFIELDS() as a Collection of objects,
* one per field, with the 18 columns of AFIELDS() as named properties:
* name, field_type, field_width, decimal_places, null_allowed, ...
* The current work area when omitted.
*-----------------------------------------------------------------------------
FUNCTION AFIELDSOBJ
	LPARAMETERS tvAliasOrWorkArea
	LOCAL lnCount, loFields, lnRow
	LOCAL ARRAY laFields[1]
	IF PCOUNT() = 0
		lnCount = AFIELDS(laFields)
	ELSE
		lnCount = AFIELDS(laFields, tvAliasOrWorkArea)
	ENDIF
	loFields = CREATEOBJECT("Collection")
	FOR lnRow = 1 TO lnCount
		loFields.Add(fx_RowObject(@laFields, lnRow, ;
			"name,field_type,field_width,decimal_places,null_allowed,code_page_translation_not_allowed," + ;
			"field_validation_expression,field_validation_text,field_default_value," + ;
			"table_validation_expression,table_validation_text,long_table_name," + ;
			"insert_trigger_expression,update_trigger_expression,delete_trigger_expression," + ;
			"table_comment,next_value_for_autoincrementing,step_for_autoincrementing"))
	NEXT
	RETURN loFields
ENDFUNC

*-----------------------------------------------------------------------------
* SECRETBOX([cPrompt [, cCaption]]): a modal dialog with a hidden text box;
* returns what was typed (trimmed), or "" on Cancel. It waits for a person:
* do not call it from code that runs unattended.
*-----------------------------------------------------------------------------
FUNCTION SECRETBOX
	LPARAMETERS tcPrompt, tcCaption
	LOCAL loForm, lcResult
	loForm = CREATEOBJECT("FxSecretForm", tcPrompt, tcCaption)
	loForm.Show(1)
	lcResult = ALLTRIM(loForm.cResult)
	loForm.Release()
	RETURN lcResult
ENDFUNC

DEFINE CLASS FxSecretForm AS Form
	BorderStyle = 2
	Height = 88
	Width = 396
	AutoCenter = .T.
	Caption = ""
	MaxButton = .F.
	MinButton = .F.
	WindowType = 1
	cResult = ""

	ADD OBJECT lblPrompt AS Label WITH ;
		BackStyle = 0, Caption = "", Height = 17, Left = 8, Top = 12, Width = 380

	ADD OBJECT txtSecret AS TextBox WITH ;
		FontName = "Wingdings", PasswordChar = "l", ControlSource = "Thisform.cResult", ;
		Height = 23, Left = 8, Top = 30, Width = 380

	ADD OBJECT cmdOk AS CommandButton WITH ;
		Caption = "OK", Default = .T., Height = 23, Left = 242, Top = 58, Width = 72

	ADD OBJECT cmdCancel AS CommandButton WITH ;
		Caption = "Cancel", Cancel = .T., Height = 23, Left = 316, Top = 58, Width = 72

	PROCEDURE Init(tcPrompt, tcCaption)
		THIS.lblPrompt.Caption = IIF(VARTYPE(tcPrompt) == "C", tcPrompt, "")
		THIS.Caption = IIF(VARTYPE(tcCaption) == "C" AND !EMPTY(tcCaption), tcCaption, _SCREEN.Caption)
	ENDPROC

	PROCEDURE cmdOk.Click
		THISFORM.Hide()
	ENDPROC

	PROCEDURE cmdCancel.Click
		THISFORM.cResult = ""
		THISFORM.Hide()
	ENDPROC
ENDDEFINE

*=============================================================================
* Helpers (fx_*): not part of the API
*=============================================================================

FUNCTION fx_IsDigits
	LPARAMETERS tcText
	RETURN !EMPTY(tcText) AND LEN(CHRTRAN(tcText, "0123456789", "")) = 0
ENDFUNC

FUNCTION fx_IsName
	LPARAMETERS tcName
	LOCAL lnI, lcChar
	IF EMPTY(tcName) OR !(ISALPHA(LEFT(tcName, 1)) OR LEFT(tcName, 1) == "_")
		RETURN .F.
	ENDIF
	FOR lnI = 2 TO LEN(tcName)
		lcChar = SUBSTR(tcName, lnI, 1)
		IF !(ISALPHA(lcChar) OR ISDIGIT(lcChar) OR lcChar == "_")
			RETURN .F.
		ENDIF
	NEXT
	RETURN .T.
ENDFUNC

*-- A VBScript.RegExp ready for tcPattern; a clear error where there is none
FUNCTION fx_RegExp
	LPARAMETERS tcPattern, tlCaseSensitive
	LOCAL loRegExp, lcFailure, loEx
	IF VARTYPE(tcPattern) != "C"
		ERROR FX_INVALID_ARGUMENT
	ENDIF
	lcFailure = ""
	TRY
		loRegExp = CREATEOBJECT("VBScript.RegExp")
	CATCH TO loEx
		lcFailure = loEx.Message
	ENDTRY
	IF !EMPTY(lcFailure)
		ERROR "MATCH and AMATCH need VBScript.RegExp, which is not available on this machine (Windows is retiring VBScript): " + lcFailure
	ENDIF
	loRegExp.Pattern = tcPattern
	loRegExp.IgnoreCase = !tlCaseSensitive
	loRegExp.Global = .T.
	RETURN loRegExp
ENDFUNC

*-- Row tnRow of a two-dimensional array as an object, one property per name
FUNCTION fx_RowObject
	LPARAMETERS taRows, tnRow, tcNames
	EXTERNAL ARRAY taRows
	LOCAL loRow, lnCol, lnNames
	LOCAL ARRAY laNames[1]
	lnNames = ALINES(laNames, tcNames, 1, ",")
	loRow = CREATEOBJECT("Empty")
	FOR lnCol = 1 TO MIN(lnNames, ALEN(taRows, 2))
		=ADDPROPERTY(loRow, laNames[lnCol], taRows[tnRow, lnCol])
	NEXT
	RETURN loRow
ENDFUNC
