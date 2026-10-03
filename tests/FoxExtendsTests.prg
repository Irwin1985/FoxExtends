*-- FoxExtendsTests.prg - FoxExtends 3.0
*-- Run from the repository folder: foxproof run --prg tests\FoxExtendsTests.prg
*-- The tests marked "Defect" failed against 2.x (the 2026-10-03 review).

#DEFINE FX_PRG "FoxExtends.prg"

* ============================================================ *
* Loading: SET PROCEDURE and nothing else
* ============================================================ *
DEFINE CLASS TestLoading AS Custom

	PROCEDURE SetUp
		CleanVfp()
		SET PROCEDURE TO (FX_PRG) ADDITIVE
	ENDPROC

	*-- Defect: the functions only existed after newFoxExtends(), which compiled
	*-- the library into %TEMP% (560 ms) and hung three objects on _VFP
	PROCEDURE Test_FunctionsWorkWithSetProcedureOnly() HELP [Fact, Trait("Category", "Loading")]
		__assert.Equal("cba", REVERSE("abc"))
		__assert.Equal(36, LEN(NEWGUID()))
		__assert.True(MATCH("abc123", "\d+"))
		__assert.Equal("U", TYPE("_vfp.foxExtendsRegEx"), "nothing is hung on _VFP")
		__assert.Equal("U", TYPE("_vfp.fxAnyToString"))
		__assert.Equal("U", TYPE("_vfp.foxExtendsJsonProvider"))
	ENDPROC

ENDDEFINE

* ============================================================ *
* PRINTF
* ============================================================ *
DEFINE CLASS TestPrintf AS Custom

	PROCEDURE SetUp
		SET PROCEDURE TO (FX_PRG) ADDITIVE
	ENDPROC

	PROCEDURE Test_Placeholders() HELP [Fact, Trait("Category", "Printf")]
		__assert.Equal("cart has 3 items", PRINTF("${0} has ${1} items", "cart", 3))
		__assert.Equal("b a b", PRINTF("${1} ${0} ${1}", "a", "b"), "in any order, and repeated")
		__assert.Equal("10 tens", PRINTF("${10} tens", 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))
	ENDPROC

	PROCEDURE Test_Escapes() HELP [Fact, Trait("Category", "Printf")]
		__assert.Equal("a" + CHR(9) + "b" + CHR(13) + CHR(10) + "c", PRINTF("a\tb\r\nc"))
		__assert.Equal('say "hi"', PRINTF('say \"hi\"'))
		__assert.Equal("C:\temp", PRINTF("C:\\temp"), "\\ is one backslash")
		__assert.Equal("\x stays", PRINTF("\x stays"), "an unknown escape stays as written")
	ENDPROC

	*-- Defect: escapes were applied after the values went in, so a value with "\n" changed
	PROCEDURE Test_ValuesAreNotEscaped() HELP [Fact, Trait("Category", "Printf")]
		__assert.Equal("path: C:\new", PRINTF("path: ${0}", "C:\new"))
	ENDPROC

	PROCEDURE Test_MissingValueStays() HELP [Fact, Trait("Category", "Printf")]
		__assert.Equal("a ${1}", PRINTF("${0} ${1}", "a"), "a placeholder with no value stays as written")
	ENDPROC

ENDDEFINE

* ============================================================ *
* NEWGUID, ENUM, REVERSE
* ============================================================ *
DEFINE CLASS TestSmallOnes AS Custom

	PROCEDURE SetUp
		SET PROCEDURE TO (FX_PRG) ADDITIVE
	ENDPROC

	PROCEDURE Test_NewGuid() HELP [Fact, Trait("Category", "Guid")]
		LOCAL lcGuid
		lcGuid = NEWGUID()
		__assert.Equal(36, LEN(lcGuid))
		__assert.Equal(4, OCCURS("-", lcGuid))
		__assert.False(lcGuid == NEWGUID(), "two GUIDs differ")
	ENDPROC

	PROCEDURE Test_Enum() HELP [Fact, Trait("Category", "Enum")]
		LOCAL loColor
		loColor = ENUM("Red", "Green", "Blue")
		__assert.Equal(1, loColor.Red)
		__assert.Equal(3, loColor.Blue)
	ENDPROC

	PROCEDURE Test_EnumBadNameRaises() HELP [Fact, Trait("Category", "Enum")]
		LOCAL loEx, llRaised
		llRaised = .F.
		TRY
			ENUM("Red", "2nd")
		CATCH TO loEx
			llRaised = .T.
			__assert.True("2nd" $ loEx.Message, loEx.Message)
		ENDTRY
		__assert.True(llRaised, "an invalid name raises a catchable error, no dialog")
	ENDPROC

	*-- Defect: REVERSE("  ab") returned "  "
	PROCEDURE Test_Reverse() HELP [Fact, Trait("Category", "Reverse")]
		__assert.Equal("ba  ", REVERSE("  ab"))
		__assert.Equal("", REVERSE(""))
	ENDPROC

ENDDEFINE

* ============================================================ *
* MATCH and AMATCH (VBScript.RegExp)
* ============================================================ *
DEFINE CLASS TestRegex AS Custom

	PROCEDURE SetUp
		SET PROCEDURE TO (FX_PRG) ADDITIVE
	ENDPROC

	PROCEDURE Test_Match() HELP [Fact, Trait("Category", "Regex")]
		__assert.True(MATCH("Order 1234", "\d{4}"))
		__assert.False(MATCH("Order", "\d"))
		__assert.True(MATCH("ABC", "abc"), "case is ignored by default")
		__assert.False(MATCH("ABC", "abc", .T.), "unless lCaseSensitive")
	ENDPROC

	*-- Defect: AMATCH returned an array with one match, the last one by default
	PROCEDURE Test_AMatchFillsAllMatches() HELP [Fact, Trait("Category", "Regex")]
		LOCAL laMatches[1], lnCount
		lnCount = AMATCH(@laMatches, "a1 b22 c333", "\d+")
		__assert.Equal(3, lnCount)
		__assert.Equal(3, ALEN(laMatches))
		__assert.Equal("1", laMatches[1])
		__assert.Equal("333", laMatches[3])
		lnCount = AMATCH(@laMatches, "none", "\d+")
		__assert.Equal(0, lnCount)
	ENDPROC

ENDDEFINE

* ============================================================ *
* ADIROBJ and AFIELDSOBJ
* ============================================================ *
DEFINE CLASS TestObjects AS Custom

	PROCEDURE SetUp
		SET PROCEDURE TO (FX_PRG) ADDITIVE
	ENDPROC

	PROCEDURE Test_ADirObj() HELP [Fact, Trait("Category", "Objects")]
		LOCAL loFiles, loFile
		loFiles = ADIROBJ(FX_PRG)
		__assert.Equal("Collection", loFiles.BaseClass)
		__assert.Equal(1, loFiles.Count)
		loFile = loFiles.Item(1)
		__assert.Equal(UPPER(FX_PRG), UPPER(loFile.file_name))
		__assert.True(loFile.file_size > 0)
		__assert.Equal("D", VARTYPE(loFile.date_last_modified))
		loFiles = ADIROBJ("no-such-file-*.xyz")
		__assert.Equal(0, loFiles.Count)
	ENDPROC

	PROCEDURE Test_AFieldsObj() HELP [Fact, Trait("Category", "Objects")]
		LOCAL loFields, loField
		CREATE CURSOR crsFxTest (cName C(20), nAge I NULL)
		loFields = AFIELDSOBJ("crsFxTest")
		__assert.Equal(2, loFields.Count)
		loField = loFields.Item(1)
		__assert.Equal("CNAME", loField.name)
		__assert.Equal("C", loField.field_type)
		__assert.Equal(20, loField.field_width)
		loField = loFields.Item(2)
		__assert.True(loField.null_allowed)
		SELECT crsFxTest
		loFields = AFIELDSOBJ()
		__assert.Equal(2, loFields.Count, "the current work area when omitted")
		USE IN SELECT("crsFxTest")
	ENDPROC

ENDDEFINE

* ============================================================ *
* SECRETBOX: the dialog is modal, so only its form is tested here
* ============================================================ *
DEFINE CLASS TestSecretBox AS Custom

	PROCEDURE SetUp
		SET PROCEDURE TO (FX_PRG) ADDITIVE
	ENDPROC

	PROCEDURE Test_SecretForm() HELP [Fact, Trait("Category", "SecretBox")]
		LOCAL loForm
		loForm = CREATEOBJECT("FxSecretForm", "Password:", "Sign in")
		__assert.Equal("Sign in", loForm.Caption)
		__assert.Equal("Password:", loForm.lblPrompt.Caption)
		__assert.False(EMPTY(loForm.txtSecret.PasswordChar), "the text is hidden")
		__assert.Equal(1, loForm.WindowType, "modal")
		loForm.Release()
	ENDPROC

ENDDEFINE

FUNCTION CleanVfp
	LOCAL lcProp, loProps
	loProps = Props()
	FOR EACH lcProp IN loProps
		IF TYPE("_vfp." + lcProp) != "U"
			REMOVEPROPERTY(_vfp, lcProp)
		ENDIF
	ENDFOR
ENDFUNC

FUNCTION Props
	LOCAL loProps
	loProps = CREATEOBJECT("Collection")
	loProps.Add("foxExtendsRegEx")
	loProps.Add("fxAnyToString")
	loProps.Add("foxExtendsJsonProvider")
	RETURN loProps
ENDFUNC
