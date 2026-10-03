*============================================================*
* FoxExtendsTests.prg
* Test suite for FoxExtends library
* Run with: foxunit run --prg FoxExtends\tests\FoxExtendsTests.prg --format console
*============================================================*

DEFINE CLASS FoxExtendsTests AS Custom

    PROCEDURE SetUp() HELP []
        LOCAL lcLibFile
        IF TYPE('gcFoxExtendsLoaded') == 'U' OR !gcFoxExtendsLoaded
            IF TYPE('gcFoxExtendsLoaded') == 'U'
                PUBLIC gcFoxExtendsLoaded
                gcFoxExtendsLoaded = .F.
            ENDIF
            lcLibFile = "C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\FoxExtends.prg"
            SET PROCEDURE TO (lcLibFile) ADDITIVE
            =newFoxExtends()
            gcFoxExtendsLoaded = .T.
        ENDIF
    ENDPROC

    PROCEDURE TearDown() HELP []
        * Reset JSON provider after each test that may set it
        IF TYPE('_vfp.foxExtendsJsonProvider') == 'O'
            _vfp.foxExtendsJsonProvider = .NULL.
        ENDIF
    ENDPROC

    *------------------------------------------------------------*
    * PAIR
    *------------------------------------------------------------*
    PROCEDURE Test_Pair_CreatesKeyValueObject() HELP [Fact]
        LOCAL loPair
        loPair = PAIR("name", "John")
        __assert.Equal("name", loPair.key, "key should be 'name'")
        __assert.Equal("John", loPair.value, "value should be 'John'")
    ENDPROC

    PROCEDURE Test_Pair_AcceptsNumericValue() HELP [Fact]
        LOCAL loPair
        loPair = PAIR("age", 36)
        __assert.Equal("age", loPair.key)
        __assert.Equal(36, loPair.value)
    ENDPROC

    *------------------------------------------------------------*
    * ALIST
    *------------------------------------------------------------*
    PROCEDURE Test_Alist_CreatesArrayFromThreeParams() HELP [Fact]
        LOCAL laResult
        laResult = ALIST("a", "b", "c")
        __assert.Equal(3, ALEN(laResult), "array should have 3 elements")
        __assert.Equal("a", laResult[1])
        __assert.Equal("b", laResult[2])
        __assert.Equal("c", laResult[3])
    ENDPROC

    PROCEDURE Test_Alist_AcceptsHeterogeneousTypes() HELP [Fact]
        LOCAL laResult
        laResult = ALIST("hello", 42, .T.)
        __assert.Equal(3, ALEN(laResult))
        __assert.Equal("hello", laResult[1])
        __assert.Equal(42, laResult[2])
        __assert.True(laResult[3], "third element should be .T.")
    ENDPROC

    *------------------------------------------------------------*
    * APUSH / APOP
    *------------------------------------------------------------*
    PROCEDURE Test_Apush_AddsElementToEnd() HELP [Fact]
        LOCAL laArr
        DIMENSION laArr[2]
        laArr[1] = "x"
        laArr[2] = "y"
        =APUSH(@laArr, "z")
        __assert.Equal(3, ALEN(laArr))
        __assert.Equal("z", laArr[3])
    ENDPROC

    PROCEDURE Test_Apop_RemovesAndReturnsLastElement() HELP [Fact]
        LOCAL laArr, lvRemoved
        DIMENSION laArr[3]
        laArr[1] = "a"
        laArr[2] = "b"
        laArr[3] = "c"
        lvRemoved = APOP(@laArr)
        __assert.Equal(2, ALEN(laArr))
        __assert.Equal("c", lvRemoved, "APOP should return removed element")
    ENDPROC

    PROCEDURE Test_Apop_OnSingleElementLeavesArrayWithOne() HELP [Fact]
        LOCAL laArr
        DIMENSION laArr[1]
        laArr[1] = "only"
        =APOP(@laArr)
        __assert.Equal(1, ALEN(laArr), "single-element array stays at size 1 after pop")
    ENDPROC

    *------------------------------------------------------------*
    * AJOIN
    *------------------------------------------------------------*
    PROCEDURE Test_Ajoin_JoinsWithSeparator() HELP [Fact]
        LOCAL laArr, lcResult
        laArr = ALIST("a", "b", "c")
        lcResult = AJOIN(@laArr, "-")
        __assert.Equal("a-b-c", lcResult)
    ENDPROC

    PROCEDURE Test_Ajoin_EmptySeparator() HELP [Fact]
        LOCAL laArr, lcResult
        laArr = ALIST("x", "y", "z")
        lcResult = AJOIN(@laArr, "")
        __assert.Equal("xyz", lcResult)
    ENDPROC

    *------------------------------------------------------------*
    * ASPLIT
    *------------------------------------------------------------*
    PROCEDURE Test_Asplit_SplitsOnDelimiter() HELP [Fact]
        LOCAL laResult
        laResult = ASPLIT("a,b,c", ",")
        __assert.Equal(3, ALEN(laResult))
        __assert.Equal("a", ALLTRIM(laResult[1]))
    ENDPROC

    *------------------------------------------------------------*
    * AREVERSE
    *------------------------------------------------------------*
    PROCEDURE Test_Areverse_ReversesThreeElements() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("a", "b", "c")
        laResult = AREVERSE(@laArr)
        __assert.Equal("c", laResult[1], "first element of reversed should be 'c'")
        __assert.Equal("b", laResult[2])
        __assert.Equal("a", laResult[3])
    ENDPROC

    PROCEDURE Test_Areverse_DoesNotModifyOriginal() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("x", "y")
        laResult = AREVERSE(@laArr)
        __assert.Equal("x", laArr[1], "original should not be modified")
    ENDPROC

    *------------------------------------------------------------*
    * AUNIQUE
    *------------------------------------------------------------*
    PROCEDURE Test_Aunique_RemovesDuplicates() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("a", "b", "a", "c", "b")
        laResult = AUNIQUE(@laArr)
        __assert.Equal(3, ALEN(laResult))
    ENDPROC

    PROCEDURE Test_Aunique_NoDuplicatesReturnsSameSize() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("x", "y", "z")
        laResult = AUNIQUE(@laArr)
        __assert.Equal(3, ALEN(laResult))
    ENDPROC

    *------------------------------------------------------------*
    * ARIGHT — was buggy, now fixed
    *------------------------------------------------------------*
    PROCEDURE Test_Aright_ReturnsLastTwoElements() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("apple", "banana", "mango", "raspberry")
        laResult = ARIGHT(@laArr, 2)
        __assert.Equal(2, ALEN(laResult), "should return 2 elements")
        __assert.Equal("mango", laResult[1], "first of last-2 should be 'mango'")
        __assert.Equal("raspberry", laResult[2], "second of last-2 should be 'raspberry'")
    ENDPROC

    PROCEDURE Test_Aright_ReturnsLastOneElement() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("a", "b", "c")
        laResult = ARIGHT(@laArr, 1)
        __assert.Equal(1, ALEN(laResult))
        __assert.Equal("c", laResult[1])
    ENDPROC

    PROCEDURE Test_Aright_WhenNExceedsLenReturnsAll() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("a", "b", "c")
        laResult = ARIGHT(@laArr, 10)
        __assert.Equal(3, ALEN(laResult), "clamped to array length")
    ENDPROC

    PROCEDURE Test_Aright_SevenElementArray() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("apple","banana","blackberry","grape","lemon","mango","raspberry")
        laResult = ARIGHT(@laArr, 2)
        __assert.Equal(2, ALEN(laResult))
        __assert.Equal("mango", laResult[1])
        __assert.Equal("raspberry", laResult[2])
    ENDPROC

    *------------------------------------------------------------*
    * ALEFT
    *------------------------------------------------------------*
    PROCEDURE Test_Aleft_ReturnsFirstTwoElements() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("apple", "banana", "mango", "raspberry")
        laResult = ALEFT(@laArr, 2)
        __assert.Equal(2, ALEN(laResult))
        __assert.Equal("apple", laResult[1])
        __assert.Equal("banana", laResult[2])
    ENDPROC

    *------------------------------------------------------------*
    * AINTERSECT
    *------------------------------------------------------------*
    PROCEDURE Test_Aintersect_ReturnsCommonElements() HELP [Fact]
        LOCAL laA, laB, laResult
        laA = ALIST("a", "b", "c", "d")
        laB = ALIST("b", "d", "e")
        laResult = AINTERSECT(@laA, @laB)
        __assert.Equal(2, ALEN(laResult))
        __assert.Equal("b", laResult[1])
        __assert.Equal("d", laResult[2])
    ENDPROC

    PROCEDURE Test_Aintersect_NoCommonElementsReturnsEmptyArray() HELP [Fact]
        LOCAL laA, laB, laResult
        laA = ALIST("a", "b")
        laB = ALIST("c", "d")
        laResult = AINTERSECT(@laA, @laB)
        __assert.Equal(1, ALEN(laResult), "VFP minimum array size is 1")
    ENDPROC

    *------------------------------------------------------------*
    * AEXCEPT
    *------------------------------------------------------------*
    PROCEDURE Test_Aexcept_ReturnsElementsNotInSecond() HELP [Fact]
        LOCAL laA, laB, laResult
        laA = ALIST("a", "b", "c")
        laB = ALIST("b")
        laResult = AEXCEPT(@laA, @laB)
        __assert.Equal(2, ALEN(laResult))
        __assert.Equal("a", laResult[1])
        __assert.Equal("c", laResult[2])
    ENDPROC

    *------------------------------------------------------------*
    * AUNION
    *------------------------------------------------------------*
    PROCEDURE Test_Aunion_CombinesWithoutDuplicates() HELP [Fact]
        LOCAL laA, laB, laResult
        laA = ALIST("a", "b")
        laB = ALIST("b", "c")
        laResult = AUNION(@laA, @laB)
        __assert.Equal(3, ALEN(laResult), "union of [a,b] + [b,c] = 3 unique elements")
    ENDPROC

    *------------------------------------------------------------*
    * ACONCAT
    *------------------------------------------------------------*
    PROCEDURE Test_Aconcat_CombinesKeepingDuplicates() HELP [Fact]
        LOCAL laA, laB, laResult
        laA = ALIST("a", "b")
        laB = ALIST("b", "c")
        laResult = ACONCAT(@laA, @laB)
        __assert.Equal(4, ALEN(laResult), "concat keeps duplicates")
    ENDPROC

    *------------------------------------------------------------*
    * ACLONE
    *------------------------------------------------------------*
    PROCEDURE Test_Aclone_CreatesIndependentCopy() HELP [Fact]
        LOCAL laArr, laClone
        laArr = ALIST("a", "b", "c")
        laClone = ACLONE(@laArr)
        __assert.Equal(3, ALEN(laClone))
        __assert.Equal("a", laClone[1])
        =APUSH(@laArr, "d")
        __assert.Equal(3, ALEN(laClone), "clone should not grow when original does")
    ENDPROC

    *------------------------------------------------------------*
    * ASLICE
    *------------------------------------------------------------*
    PROCEDURE Test_Aslice_RangeNotation() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("a", "b", "c", "d", "e")
        laResult = ASLICE(@laArr, "2..4")
        __assert.Equal(3, ALEN(laResult), "2..4 should return 3 elements")
        __assert.Equal("b", laResult[1])
        __assert.Equal("d", laResult[3])
    ENDPROC

    PROCEDURE Test_Aslice_FirstN() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("a", "b", "c", "d", "e")
        laResult = ASLICE(@laArr, "3")
        __assert.Equal(3, ALEN(laResult))
        __assert.Equal("a", laResult[1])
        __assert.Equal("c", laResult[3])
    ENDPROC

    PROCEDURE Test_Aslice_LastN() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("a", "b", "c", "d", "e")
        laResult = ASLICE(@laArr, "-2")
        __assert.Equal(2, ALEN(laResult))
        __assert.Equal("d", laResult[1])
        __assert.Equal("e", laResult[2])
    ENDPROC

    *------------------------------------------------------------*
    * ASUBSTR
    *------------------------------------------------------------*
    PROCEDURE Test_Asubstr_GetsSubrange() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("a", "b", "c", "d", "e")
        laResult = ASUBSTR(@laArr, 2, 3)
        __assert.Equal(3, ALEN(laResult))
        __assert.Equal("b", laResult[1])
        __assert.Equal("d", laResult[3])
    ENDPROC

    *------------------------------------------------------------*
    * AZIP
    *------------------------------------------------------------*
    PROCEDURE Test_Azip_CombinesIntoPairs() HELP [Fact]
        LOCAL laA, laB, laResult
        laA = ALIST("x", "y")
        laB = ALIST(1, 2)
        laResult = AZIP(@laA, @laB)
        __assert.Equal(2, ALEN(laResult))
        __assert.Equal("x", laResult[1].left)
        __assert.Equal(1, laResult[1].right)
        __assert.Equal("y", laResult[2].left)
        __assert.Equal(2, laResult[2].right)
    ENDPROC

    PROCEDURE Test_Azip_StopsAtShorterArray() HELP [Fact]
        LOCAL laA, laB, laResult
        laA = ALIST("x", "y", "z")
        laB = ALIST(1, 2)
        laResult = AZIP(@laA, @laB)
        __assert.Equal(2, ALEN(laResult), "result length = min(len(A), len(B))")
    ENDPROC

    *------------------------------------------------------------*
    * AMAP — numeric predicates work; with fix strings also work
    *------------------------------------------------------------*
    PROCEDURE Test_Amap_AddsConstantToNumbers() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST(1, 2, 3)
        laResult = AMAP(@laArr, "$0 + 10")
        __assert.Equal(11, laResult[1])
        __assert.Equal(12, laResult[2])
        __assert.Equal(13, laResult[3])
    ENDPROC

    *------------------------------------------------------------*
    * AFILTER — numeric and string (fix: lxFEPredVal binding)
    *------------------------------------------------------------*
    PROCEDURE Test_Afilter_FiltersNumbersByRange() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST(5, 10, 15, 20, 25)
        laResult = AFILTER(@laArr, "$0 >= 15")
        __assert.Equal(3, ALEN(laResult))
        __assert.Equal(15, laResult[1])
    ENDPROC

    PROCEDURE Test_Afilter_FiltersStringsByPrefix() HELP [Fact]
        LOCAL laArr, laResult
        laArr = ALIST("apple", "banana", "apricot", "cherry")
        laResult = AFILTER(@laArr, 'LEFT(lxFEPredVal, 1) == "a"')
        __assert.Equal(2, ALEN(laResult), "should keep apple and apricot")
        __assert.Equal("apple", laResult[1])
        __assert.Equal("apricot", laResult[2])
    ENDPROC

    *------------------------------------------------------------*
    * AEVERY
    *------------------------------------------------------------*
    PROCEDURE Test_Aevery_ReturnsTrueWhenAllMatch() HELP [Fact]
        LOCAL laArr
        laArr = ALIST(2, 4, 6, 8)
        __assert.True(AEVERY(@laArr, "MOD($0, 2) == 0"), "all should be even")
    ENDPROC

    PROCEDURE Test_Aevery_ReturnsFalseWhenOneDoesNotMatch() HELP [Fact]
        LOCAL laArr
        laArr = ALIST(2, 3, 6, 8)
        __assert.False(AEVERY(@laArr, "MOD($0, 2) == 0"), "3 is not even")
    ENDPROC

    *------------------------------------------------------------*
    * MATCH (regex)
    *------------------------------------------------------------*
    PROCEDURE Test_Match_ReturnsTrueForValidEmail() HELP [Fact]
        __assert.True(MATCH("user@example.com", "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"))
    ENDPROC

    PROCEDURE Test_Match_ReturnsFalseForInvalidEmail() HELP [Fact]
        __assert.False(MATCH("not-an-email", "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"))
    ENDPROC

    PROCEDURE Test_Match_ReturnsTrueForDigitPattern() HELP [Fact]
        __assert.True(MATCH("12345", "^\d+$"))
    ENDPROC

    *------------------------------------------------------------*
    * AMATCH
    *------------------------------------------------------------*
    PROCEDURE Test_Amatch_ReturnsFirstNumber() HELP [Fact]
        LOCAL laResult
        laResult = AMATCH("there are 42 items and 7 groups", "\d+", 1)
        __assert.Equal("42", laResult[1])
    ENDPROC

    PROCEDURE Test_Amatch_ReturnsSecondOccurrence() HELP [Fact]
        LOCAL laResult
        laResult = AMATCH("there are 42 items and 7 groups", "\d+", 2)
        __assert.Equal("7", laResult[1])
    ENDPROC

    *------------------------------------------------------------*
    * REVERSE (string)
    *------------------------------------------------------------*
    PROCEDURE Test_Reverse_ReversesString() HELP [Fact]
        __assert.Equal("olleH", REVERSE("Hello"))
    ENDPROC

    PROCEDURE Test_Reverse_SingleChar() HELP [Fact]
        __assert.Equal("X", REVERSE("X"))
    ENDPROC

    *------------------------------------------------------------*
    * CLAMP
    *------------------------------------------------------------*
    PROCEDURE Test_Clamp_ExtractsSubstring() HELP [Fact]
        LOCAL lcResult
        lcResult = CLAMP("This is a string", 6, 10)
        __assert.Equal("is a", lcResult)
    ENDPROC

    *------------------------------------------------------------*
    * PRINTF
    *------------------------------------------------------------*
    PROCEDURE Test_Printf_InterpolatesMultipleValues() HELP [Fact]
        LOCAL lcResult
        lcResult = PRINTF("Hello ${0}! I am ${1}.", "world", "John")
        __assert.Equal("Hello world! I am John.", lcResult)
    ENDPROC

    PROCEDURE Test_Printf_InterpolatesNumber() HELP [Fact]
        LOCAL lcResult
        lcResult = PRINTF("Count: ${0}", 42)
        __assert.Equal("Count: 42", lcResult)
    ENDPROC

    *------------------------------------------------------------*
    * HASHTABLE / HASKEY / ADDKEY / REMOVEKEY / GETVALUE
    *------------------------------------------------------------*
    PROCEDURE Test_Hashtable_CreatesDict() HELP [Fact]
        LOCAL loDict
        loDict = HASHTABLE("name", "John", "age", 36)
        __assert.Equal("John", loDict.name)
        __assert.Equal(36, loDict.age)
    ENDPROC

    PROCEDURE Test_Haskey_ReturnsTrueForExistingKey() HELP [Fact]
        LOCAL loDict
        loDict = HASHTABLE("x", 1)
        __assert.True(HASKEY(loDict, "x"))
    ENDPROC

    PROCEDURE Test_Haskey_ReturnsFalseForMissingKey() HELP [Fact]
        LOCAL loDict
        loDict = HASHTABLE("x", 1)
        __assert.False(HASKEY(loDict, "y"))
    ENDPROC

    PROCEDURE Test_Addkey_AddsNewKey() HELP [Fact]
        LOCAL loDict
        loDict = HASHTABLE("a", 1)
        =ADDKEY(loDict, "b", 2)
        __assert.True(HASKEY(loDict, "b"))
        __assert.Equal(2, GETVALUE(loDict, "b"))
    ENDPROC

    PROCEDURE Test_Addkey_UpdatesExistingKey() HELP [Fact]
        LOCAL loDict
        loDict = HASHTABLE("a", 1)
        =ADDKEY(loDict, "a", 99)
        __assert.Equal(99, GETVALUE(loDict, "a"))
    ENDPROC

    PROCEDURE Test_Removekey_RemovesExistingKey() HELP [Fact]
        LOCAL loDict
        loDict = HASHTABLE("a", 1, "b", 2)
        =REMOVEKEY(loDict, "a")
        __assert.False(HASKEY(loDict, "a"))
        __assert.True(HASKEY(loDict, "b"), "b should still exist")
    ENDPROC

    PROCEDURE Test_Getvalue_ReturnsNullForMissingKey() HELP [Fact]
        LOCAL loDict, lvResult
        loDict = HASHTABLE("a", 1)
        lvResult = GETVALUE(loDict, "missing")
        __assert.False(TYPE('lvResult') == 'O', "should not be an object")
    ENDPROC

    *------------------------------------------------------------*
    * AKEYS
    *------------------------------------------------------------*
    PROCEDURE Test_Akeys_ReturnsAllPropertyNames() HELP [Fact]
        LOCAL loDict, laKeys
        loDict = HASHTABLE("name", "John", "age", 36)
        laKeys = AKEYS(loDict)
        __assert.Equal(2, ALEN(laKeys))
    ENDPROC

    *------------------------------------------------------------*
    * ENUM
    *------------------------------------------------------------*
    PROCEDURE Test_Enum_CreatesEnumeration() HELP [Fact]
        LOCAL loColors
        loColors = ENUM("red", "green", "blue")
        __assert.Equal(1, loColors.red)
        __assert.Equal(2, loColors.green)
        __assert.Equal(3, loColors.blue)
    ENDPROC

    *------------------------------------------------------------*
    * ANYTOSTR
    *------------------------------------------------------------*
    PROCEDURE Test_Anytostr_ConvertsNumericArray() HELP [Fact]
        LOCAL laArr, lcResult
        laArr = ALIST(1, 2, 3)
        lcResult = ANYTOSTR(@laArr)
        __assert.Equal("[1,2,3]", lcResult)
    ENDPROC

    PROCEDURE Test_Anytostr_ConvertsLogical() HELP [Fact]
        __assert.Equal("true",  ANYTOSTR(.T.))
        __assert.Equal("false", ANYTOSTR(.F.))
    ENDPROC

    PROCEDURE Test_Anytostr_ConvertsNull() HELP [Fact]
        __assert.Equal("null", ANYTOSTR(.NULL.))
    ENDPROC

    PROCEDURE Test_Anytostr_ConvertsEmptyObject() HELP [Fact]
        LOCAL loObj, lcResult
        loObj = CREATEOBJECT("Empty")
        lcResult = ANYTOSTR(loObj)
        __assert.Equal("{}", lcResult)
    ENDPROC

    *------------------------------------------------------------*
    * ARGS / APARAMS
    *------------------------------------------------------------*
    PROCEDURE Test_Args_WrapsParameters() HELP [Fact]
        LOCAL loArgs
        loArgs = ARGS("a", "b", "c")
        __assert.Equal(3, ALEN(loArgs.ARGS), "ARGS should wrap 3 values")
        __assert.Equal("a", loArgs.ARGS[1])
    ENDPROC

    PROCEDURE Test_Aparams_UnwrapsIntoArray() HELP [Fact]
        LOCAL loArgs, laResult
        loArgs = ARGS(10, 20, 30)
        laResult = APARAMS(loArgs)
        __assert.Equal(3, ALEN(laResult))
        __assert.Equal(20, laResult[2])
    ENDPROC

    *------------------------------------------------------------*
    * STRINGLIST
    *------------------------------------------------------------*
    PROCEDURE Test_Stringlist_AddsAndJoins() HELP [Fact]
        LOCAL loList
        loList = STRINGLIST()
        loList.Add("Visual FoxPro")
        loList.Add("XSharp")
        __assert.Equal(2, loList.GetLen())
        __assert.Equal("Visual FoxPro, XSharp", loList.Join(", "))
    ENDPROC

    PROCEDURE Test_Stringlist_FromArgs() HELP [Fact]
        LOCAL loList
        loList = STRINGLIST(ARGS("a", "b", "c"))
        __assert.Equal(3, loList.GetLen())
    ENDPROC

    *------------------------------------------------------------*
    * JSON injection — SetFoxExtendsJsonProvider
    *------------------------------------------------------------*
    PROCEDURE Test_Json_InjectedProviderUsedForStringify() HELP [Fact]
        LOCAL loProvider, loObj, lcResult
        loProvider = CREATEOBJECT("FxJsonStub")
        =SetFoxExtendsJsonProvider(loProvider)
        loObj = CREATEOBJECT("Empty")
        =AddProperty(loObj, "score", 100)
        lcResult = JSONTOSTR(loObj)
        __assert.Equal('{"score":100}', lcResult, "JSONTOSTR should route through injected provider")
    ENDPROC

    PROCEDURE Test_Json_InjectedProviderUsedForParse() HELP [Fact]
        LOCAL loProvider, loResult
        loProvider = CREATEOBJECT("FxJsonStub")
        =SetFoxExtendsJsonProvider(loProvider)
        loResult = STRTOJSON('{"points":77}')
        __assert.Equal(77, loResult.points, "STRTOJSON should route through injected provider")
    ENDPROC

    PROCEDURE Test_Json_ClearProviderWithNull() HELP [Fact]
        LOCAL loProvider
        loProvider = CREATEOBJECT("FxJsonStub")
        =SetFoxExtendsJsonProvider(loProvider)
        =SetFoxExtendsJsonProvider(.NULL.)
        __assert.False(TYPE('_vfp.foxExtendsJsonProvider') == 'O', "provider should be cleared")
    ENDPROC

    PROCEDURE Test_Json_ProviderInjectedViaNewFoxExtends() HELP [Fact]
        LOCAL loProvider, loObj, lcResult
        loProvider = CREATEOBJECT("FxJsonStub")
        * Re-initialize passing provider directly to constructor
        =newFoxExtends(.F., 'prg', loProvider)
        loObj = CREATEOBJECT("Empty")
        =AddProperty(loObj, "val", 5)
        lcResult = JSONTOSTR(loObj)
        __assert.Equal('{"val":5}', lcResult)
    ENDPROC

    *------------------------------------------------------------*
    * TDictionary key/value fix
    *------------------------------------------------------------*
    PROCEDURE Test_Tdictionary_IteratorReturnsCorrectKeyAndValue() HELP [Fact]
        LOCAL loDict, loPair
        loDict = CREATEOBJECT("TDictionary")
        loDict.Add("mykey", "myvalue")
        __assert.True(loDict.hasNext(), "should have first element")
        loPair = loDict.Next()
        __assert.Equal("mykey",   loPair.key,   "key should be 'mykey'")
        __assert.Equal("myvalue", loPair.value, "value should be 'myvalue'")
    ENDPROC

    PROCEDURE Test_Tdictionary_ContainsKey() HELP [Fact]
        LOCAL loDict
        loDict = CREATEOBJECT("TDictionary")
        loDict.Add("foo", 42)
        __assert.True(loDict.ContainsKey("foo"))
        __assert.False(loDict.ContainsKey("bar"))
    ENDPROC

    PROCEDURE Test_Tdictionary_GetReturnsValue() HELP [Fact]
        LOCAL loDict
        loDict = CREATEOBJECT("TDictionary")
        loDict.Add("pi", 3.14)
        __assert.Equal(3.14, loDict.Get("pi"))
    ENDPROC

    PROCEDURE Test_Tdictionary_GetReturnNullForMissingKey() HELP [Fact]
        LOCAL loDict, lvResult
        loDict = CREATEOBJECT("TDictionary")
        lvResult = loDict.Get("nope")
        __assert.False(TYPE('lvResult') == 'C', "missing key should return .NULL., not string")
    ENDPROC

ENDDEFINE

*============================================================*
* FxJsonStub — minimal JSON stub for injection tests
* Handles simple flat objects with string and numeric values
*============================================================*
DEFINE CLASS FxJsonStub AS Custom

    FUNCTION Stringify(toObj)
        LOCAL lcResult, i, lnCount, lcProp, lcType, lvVal
        LOCAL ARRAY laMembers(1)
        lcResult = "{"
        lnCount = AMEMBERS(laMembers, toObj, 0, "U")
        FOR i = 1 TO lnCount
            lcProp  = LOWER(ALLTRIM(laMembers[i]))
            lcType  = TYPE("toObj." + laMembers[i])
            lvVal   = EVALUATE("toObj." + laMembers[i])
            IF i > 1
                lcResult = lcResult + ","
            ENDIF
            lcResult = lcResult + '"' + lcProp + '":'
            DO CASE
            CASE lcType == "C"
                lcResult = lcResult + '"' + lvVal + '"'
            CASE lcType == "N"
                lcResult = lcResult + ALLTRIM(STR(lvVal, 18, 0))
            CASE lcType == "L"
                lcResult = lcResult + IIF(lvVal, "true", "false")
            OTHERWISE
                lcResult = lcResult + "null"
            ENDCASE
        ENDFOR
        RETURN lcResult + "}"
    ENDFUNC

    FUNCTION Parse(tcJson)
        LOCAL loObj, lcInner, lnPairs, i, lcPair, lnColon, lcKey, lcVal
        LOCAL ARRAY laPairs(1)
        loObj = CREATEOBJECT("Empty")
        * strip outer braces
        lcInner = SUBSTR(tcJson, 2, LEN(tcJson) - 2)
        lnPairs = ALINES(laPairs, STRTRAN(lcInner, ",", CHR(10)))
        FOR i = 1 TO lnPairs
            lcPair  = ALLTRIM(laPairs[i])
            lnColon = AT(":", lcPair)
            IF lnColon == 0
                LOOP
            ENDIF
            lcKey = STRTRAN(SUBSTR(lcPair, 1, lnColon - 1), '"', '')
            lcKey = ALLTRIM(lcKey)
            lcVal = ALLTRIM(SUBSTR(lcPair, lnColon + 1))
            IF LEFT(lcVal, 1) == '"'
                =AddProperty(loObj, lcKey, SUBSTR(lcVal, 2, LEN(lcVal) - 2))
            ELSE
                =AddProperty(loObj, lcKey, VAL(lcVal))
            ENDIF
        ENDFOR
        RETURN loObj
    ENDFUNC

ENDDEFINE
