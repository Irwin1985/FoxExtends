# FoxExtends

Functions Visual FoxPro 9 never had: text formatting with placeholders, GUIDs, enums,
regular expressions, `ADIR()` and `AFIELDS()` with named properties, and a password box.
One `.prg`, nothing to initialise.

## Install

```
foxpack add foxextends
```

```foxpro
SET PROCEDURE TO FoxExtends.prg ADDITIVE
```

That is all: call the functions. Nothing is compiled, nothing is left on `_VFP` or on disk.

## Example

```foxpro
SET PROCEDURE TO FoxExtends.prg ADDITIVE

? PRINTF("${0} has ${1} items\tTotal: ${2}", "Cart", 3, 59.90)
? NEWGUID()                              && 4C4EC5EE-5B92-4E70-B9D8-D1A8A2FA2ABE

LOCAL loColor, laCodes[1], loFiles, loFile
loColor = ENUM("Red", "Green", "Blue")
? loColor.Green                          && 2

? MATCH("Invoice 2026-0042", "\d{4}-\d{4}")    && .T.
? AMATCH(@laCodes, "A1 B22 C333", "\d+")       && 3: laCodes holds "1", "22", "333"

loFiles = ADIROBJ("*.prg")
FOR EACH loFile IN loFiles
	? loFile.file_name, loFile.file_size
ENDFOR
```

## API

### PRINTF(cFormat [, v0, v1, ... v19])

Returns `cFormat` with each `${n}` replaced by the n-th value, counting from 0, as `TRANSFORM()`
writes it. The same placeholder may appear several times and in any order. A placeholder
with no value stays as written.

Escapes in `cFormat`: `\t` (tab), `\r`, `\n`, `\"`, `\'` and `\\` (one backslash). Any other
`\x` stays as written. The values go in as they are: a value with `\n` in it is not escaped.

```foxpro
? PRINTF("${1}, ${0}", "Ana", "Hello")       && Hello, Ana
? PRINTF("C:\\temp\\${0}", "out.txt")        && C:\temp\out.txt
```

### NEWGUID()

A new GUID as 36 characters, without braces: `"4C4EC5EE-5B92-4E70-B9D8-D1A8A2FA2ABE"`.

### ENUM(cName1 [, cName2, ... cName26])

An object with one property per name, numbered from 1. A name that is not a valid identifier,
or that is repeated, raises an error.

```foxpro
loStatus = ENUM("Draft", "Sent", "Paid")
IF lnStatus = loStatus.Paid
```

### REVERSE(cText)

The text backwards, spaces included: `REVERSE("ab ")` is `" ba"`.

### MATCH(cText, cPattern [, lCaseSensitive])

`.T.` if the regular expression matches somewhere in the text. Case is ignored unless
`lCaseSensitive` is `.T.`.

### AMATCH(@aMatches, cText, cPattern [, lCaseSensitive])

Fills the array with every match, in order, and returns how many. With no match it returns 0
and leaves one empty element, like `ALINES()`.

```foxpro
LOCAL laEmails[1], lnI
FOR lnI = 1 TO AMATCH(@laEmails, lcText, "[\w.]+@[\w.]+\.\w+")
	? laEmails[lnI]
NEXT
```

**`MATCH` and `AMATCH` need `VBScript.RegExp`**, which comes with Windows today but which
Microsoft has announced it is retiring. On a machine without it they raise an error that says
so. The pattern syntax is VBScript's (the same as JavaScript's); an invalid pattern raises an
OLE error.

### ADIROBJ([cFileSkeleton [, cAttribute [, nFlags]]])

`ADIR()` as a `Collection` of objects, one per file, with `file_name`, `file_size`,
`date_last_modified`, `time_last_modified` and `file_attributes`. The parameters are those
of `ADIR()`; with none, every file of the current folder.

### AFIELDSOBJ([cAlias | nWorkArea])

`AFIELDS()` as a `Collection` of objects, one per field, with the 18 columns of `AFIELDS()`
as properties: `name`, `field_type`, `field_width`, `decimal_places`, `null_allowed`,
`code_page_translation_not_allowed`, `field_validation_expression`, `field_validation_text`,
`field_default_value`, `table_validation_expression`, `table_validation_text`,
`long_table_name`, `insert_trigger_expression`, `update_trigger_expression`,
`delete_trigger_expression`, `table_comment`, `next_value_for_autoincrementing`,
`step_for_autoincrementing`. The current work area when omitted.

Both return a `Collection`, so [LinqVFP](https://github.com/Irwin1985/LinqVFP) queries them:

```foxpro
loQ = Linq(ADIROBJ("*.prg"))
loQ.Where("x => x.file_size > 50000")
```

### SECRETBOX([cPrompt [, cCaption]])

A modal dialog with a hidden text box. Returns what was typed (trimmed), or `""` if the person
pressed Cancel. The caption is `_SCREEN.Caption` when omitted.

```foxpro
lcPassword = SECRETBOX("Password for the server:", "Sign in")
```

It waits for a person: do not call it from code that runs unattended (a service, a web
request, a scheduled task).

### FoxExtendsVersion()

`"3.0.0"`.

## Pitfalls

- **Errors raise.** A wrong argument (a number where a text goes, an invalid `ENUM` name, a
  bad pattern) raises a VFP error you can catch with `TRY`; nothing shows a message box,
  except `SECRETBOX`, which is a dialog on purpose.
- **`ADIROBJ` and `AFIELDSOBJ` return a Collection, not an array**: loop with
  `FOR EACH loX IN loCollection`, or `FOR i = 1 TO loCollection.Count`.
- **`AMATCH` needs the array by reference**: `AMATCH(@laMatches, ...)`, with the `@`.

## Upgrading from 2.x

3.0 keeps only what no other library of the stack does, and is MIT instead of GPL-3.

- **No `newFoxExtends()`**: `SET PROCEDURE TO FoxExtends.prg` is enough. 2.x compiled the
  library into `%TEMP%` on every start (about 0.5 s), left the `.fxp` there, hung three
  objects on `_VFP` and showed message boxes on errors. The prefix and the `obj` mode are gone
  with it.
- **What moved, and where:**

| 2.x | Use instead |
|---|---|
| `ALIST`, `APUSH`, `APOP`, `ASPLIT`, `AJOIN`, `ASLICE`, `ALEFT`, `ARIGHT`, `ASUBSTR`, `ACONCAT`, `AREVERSE`, `AUNIQUE`, `STRINGLIST`, `ARGS`, `APARAMS` | [FoxCollection](https://github.com/Irwin1985/FoxCollection): `TArray` |
| `HASHTABLE`, `HASKEY`, `ADDKEY`, `REMOVEKEY`, `GETVALUE`, `PAIR` | FoxCollection: `TDictionary` |
| `AMAP`, `AFILTER`, `AEVERY`, `FOREACH`, `AUNION`, `AINTERSECT`, `AEXCEPT` | [LinqVFP](https://github.com/Irwin1985/LinqVFP) |
| `JSONTOSTR`, `STRTOJSON`, `SetFoxExtendsJsonProvider` | [JSONFox](https://github.com/Irwin1985/JSONFox) |
| `ACLONE`, `AKEYS`, `CLAMP` | VFP itself: `ACOPY()`, `AMEMBERS()`, `SUBSTR()` |
| `ANYTOSTR`, `AZIP` | Gone |

- **Changed:** `AMATCH` fills an array by reference with every match and returns the count
  (2.x returned one match, the last by default). `ADIROBJ` and `AFIELDSOBJ` return a
  `Collection`. `REVERSE` keeps the spaces (2.x dropped the text after leading spaces).
  `PRINTF` no longer escapes the values, and takes up to 20.

## Tests

From the repository folder:

```
foxproof run --prg tests\FoxExtendsTests.prg
```

## License

MIT. See [LICENSE](LICENSE).
