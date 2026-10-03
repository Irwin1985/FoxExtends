# FoxExtends -- Handoff Tecnico Completo

**Fecha:** 2026-05-10
**Estado:** ESTABLE -- 71/71 tests pasando
**Entorno:** Windows, Visual FoxPro 9, foxunit CLI

---

## 1. Objetivo del proyecto

FoxExtends es una **biblioteca single-file para Visual FoxPro 9** que aniade funciones de
programacion funcional/utilitaria al lenguaje: operaciones de arrays (map, filter, slice,
intersect...), strings, regex, diccionarios tipados, enumeraciones, serializacion JSON,
GUIDs y mas.

La biblioteca genera su API **en tiempo de ejecucion** via metaprogramacion (TEXT TO
TEXTMERGE), compilando un script temporal al directorio TEMP del sistema. El consumidor
controla el modo de uso (PRG o OBJ) y opcionalmente un prefijo de funcion para evitar
colisiones de nombres.

Ruta principal: `C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\FoxExtends.prg`

---

## 2. Arquitectura actual

### 2.1 Estructura de archivos

```
FoxExtends/
+-- FoxExtends.prg              <- Unica fuente; contiene TODO el codigo
+-- FoxExtends.FXP              <- Compilado (se regenera automaticamente)
+-- HANDOFF-FOXEXTENDS.md       <- Este documento
+-- tests/
|   +-- FoxExtendsTests.prg     <- 71 tests foxunit
+-- examples/
|   +-- arrays.prg
|   +-- arrays2.prg
|   +-- enum.prg
+-- README.md
+-- LICENSE
```

### 2.2 Contenido de `FoxExtends.prg`

El archivo tiene **cuatro secciones** en orden:

| N | Seccion | Que hace |
|---|---------|----------|
| 1 | `Function newFoxExtends(tcPrefix, tcType, toJsonProvider)` | Entry point principal. Valida parametros, genera el script via TEXT TO TEXTMERGE, lo compila y lo carga. |
| 2 | **Bloque TEXT TO** (lineas 37-1570) | Plantilla del script generado. Contiene `FOXEXTENDS_INIT`, clases helper (`AnyToString`, `tIterable`, `tArray`, `TStringList`, `TDictionary`), `newGuid`, y todas las funciones publicas de la API. |
| 3 | **Seccion de ejecucion** (lineas 1572-1604) | Tras generar/compilar: `SET PROCEDURE TO (.fxp) ADDITIVE` + `FOXEXTENDS_INIT()`. |
| 4 | **Funciones auxiliares** (lineas 1606-1670) | `SetFoxExtendsJsonProvider`, `FoxExtendsCompileFile`, `FoxExtendsRemoveFile`. |

### 2.3 Flujo de inicializacion

```
newFoxExtends(tcPrefix, tcType, toJsonProvider)
  |
  +-- Valida tcPrefix (alfanumerico + _)  -> lcMethodPrefix (vacio si no se pasa)
  +-- Valida tcType en {'prg','obj'}      -> llUseClass (.T. si 'obj')
  |
  +-- TEXT TO lcScript NOSHOW TEXTMERGE PRETEXT 7
  |     Genera el script con:
  |       - Function FOXEXTENDS_INIT      <- init de _vfp.* properties
  |       - Function CHECKJSONAPP         <- verifica JSON provider
  |       - Define Class AnyToString      <- motor de serializacion
  |       - Define Class tIterable / tArray / TStringList / TDictionary
  |       - Function newGuid
  |       - [DEFINE CLASS TFOXEXTENDS AS CUSTOM]  <- solo si llUseClass
  |       - Function <<prefix>>PAIR, ALIST, APUSH, ...  <- API publica
  |       - [ENDDEFINE]                   <- solo si llUseClass
  |
  +-- FoxExtendsCompileFile(lcScript, @lcPrgFile)
  |     Escribe a %TEMP%\<random>.prg -> Compile -> .fxp en mismo directorio
  |
  +-- SET PROCEDURE TO (lcFxpFile) ADDITIVE   <- funciones persistentes en sesion VFP
  +-- FOXEXTENDS_INIT()                       <- crea objetos en _vfp.*
  |
  +-- [Si OBJ:] loReturn = CREATEOBJECT("TFOXEXTENDS")
  +-- FoxExtendsRemoveFile(lcPrgFile)         <- borra .prg; el .fxp queda cargado
  +-- [Si toJsonProvider es objeto:] _vfp.foxExtendsJsonProvider = toJsonProvider
  +-- Return loReturn (.T. en modo PRG / objeto TFOXEXTENDS en modo OBJ)
```

### 2.4 Modos de uso

**Modo PRG** (default): genera funciones globales en el espacio de nombres VFP.

```foxpro
DO "FoxExtends\FoxExtends.prg"
=newFoxExtends()                && sin prefijo -- funciones: ALIST, APUSH, etc.
laFruits = ALIST("Apple", "Banana", "Orange")
APUSH(@laFruits, "Kiwi")
? AJOIN(@laFruits, ", ")
```

Con prefijo para evitar colisiones:

```foxpro
=newFoxExtends("fx")            && funciones: fxALIST, fxAPUSH, etc.
laFruits = fxALIST("Apple", "Banana")
```

**Modo OBJ**: devuelve un objeto `TFOXEXTENDS` con los mismos metodos.

```foxpro
loFx = newFoxExtends("", "obj")
laFruits = loFx.ALIST("Apple", "Banana")
```

### 2.5 Inyeccion de JSON provider

Por defecto JSONTOSTR/STRTOJSON usan `JSONFOX.APP` (buscado via `FILE("JSONFOX.APP")`).
Para evitar empaquetar ese archivo se inyecta un provider externo:

```foxpro
* Opcion A: funcion standalone
LOCAL loJson
loJson = CREATEOBJECT("JsonFox")   && o cualquier objeto compatible
=SetFoxExtendsJsonProvider(loJson)

* Opcion B: tercer parametro de newFoxExtends
=newFoxExtends("", "prg", loJson)

* Para limpiar y volver a JSONFOX.APP:
=SetFoxExtendsJsonProvider(.NULL.)
```

**Contrato del provider** -- debe exponer exactamente:
- `Stringify(toObj) -> String`   serializa objeto VFP a JSON string
- `Parse(tcJson) -> Object`      deserializa JSON string a objeto VFP Empty

El provider se almacena en `_vfp.foxExtendsJsonProvider`. `CHECKJSONAPP()` lo comprueba
primero; si vale .NULL. o no existe, intenta cargar `JSONFOX.APP`.

---

## 3. API publica -- funciones disponibles

Todas con prefijo vacio (default) o el prefijo pasado a `newFoxExtends`.

### Arrays

| Funcion | Firma | Descripcion |
|---------|-------|-------------|
| `ALIST` | `ALIST(v1, v2, ..., v26)` | Crea array VFP desde parametros (max 26) |
| `APUSH` | `APUSH(@arr, val)` | Aniade elemento al final, in-place |
| `APOP` | `APOP(@arr)` | Elimina y retorna el ultimo elemento |
| `AJOIN` | `AJOIN(@arr, sep)` | Une elementos en string con separador |
| `ASPLIT` | `ASPLIT(str, sep)` | Divide string en array |
| `AREVERSE` | `AREVERSE(@arr)` | Retorna nueva copia invertida |
| `AUNIQUE` | `AUNIQUE(@arr)` | Retorna copia sin duplicados |
| `ARIGHT` | `ARIGHT(@arr, n)` | Ultimos n elementos |
| `ALEFT` | `ALEFT(@arr, n)` | Primeros n elementos |
| `AINTERSECT` | `AINTERSECT(@arr1, @arr2)` | Elementos comunes a ambos arrays |
| `AEXCEPT` | `AEXCEPT(@arr1, @arr2)` | arr1 menos los elementos de arr2 |
| `AUNION` | `AUNION(@arr1, @arr2)` | Union sin duplicados |
| `ACONCAT` | `ACONCAT(@arr1, @arr2)` | Concatenacion preservando duplicados |
| `ACLONE` | `ACLONE(@arr)` | Copia completamente independiente |
| `ASLICE` | `ASLICE(@arr, tcRange)` | Slice con notacion string: `"1:3"`, `":3"`, `"2:"` |
| `ASUBSTR` | `ASUBSTR(@arr, start, len)` | Sub-array por posicion y longitud |
| `AZIP` | `AZIP(@arr1, @arr2)` | Array de pares `{left, right}` (se detiene al mas corto) |
| `AMAP` | `AMAP(@arr, pred)` | Transforma cada elemento via predicate string |
| `AFILTER` | `AFILTER(@arr, pred)` | Filtra elementos via predicate string |
| `AEVERY` | `AEVERY(@arr, pred)` | .T. si todos los elementos cumplen el predicate |
| `FOREACH` | `FOREACH(@arr, pred)` | Itera ejecutando predicate (sin retorno util) |

**Patron de predicados:** el elemento actual se vincula a `LOCAL lxFEPredVal`. En el
string predicate se usa `$0` como placeholder -- se sustituye por `lxFEPredVal` antes de
`EVALUATE()`. Esto funciona con todos los tipos VFP (N, C, L, D, T).

```foxpro
* Filtrar numeros > 5
laResult = AFILTER(@laArr, "$0 > 5")

* Filtrar strings con prefijo "gr" (usar lxFEPredVal directamente para strings)
laResult = AFILTER(@laArr, "LEFT(lxFEPredVal, 2) == 'gr'")

* Sumar 10 a cada numero
laResult = AMAP(@laArr, "$0 + 10")

* Multiplicar strings (uselo si $0 fuera a introducir comillas indeseadas)
laResult = AMAP(@laArr, "UPPER(lxFEPredVal)")
```

### Strings / Regex

| Funcion | Descripcion |
|---------|-------------|
| `MATCH(str, pat)` | .T. si el string matchea el patron regex |
| `AMATCH(str, pat)` | Array de substrings que coinciden con el regex |
| `REVERSE(str)` | Invierte el string caracter a caracter |
| `CLAMP(str, start, end)` | Extrae subcadena (indices con soporte de negativos) |
| `PRINTF(fmt, v0..v11)` | Interpolacion: `"Hola ${0}, tienes ${1} puntos"` |

### Diccionarios / Objetos dinamicos

| Funcion | Descripcion |
|---------|-------------|
| `HASHTABLE(k1,v1,k2,v2,...)` | Crea objeto Empty con propiedades dinamicas |
| `HASKEY(dict, key)` | .T. si la propiedad existe en el objeto |
| `ADDKEY(dict, key, val)` | Agrega propiedad nueva o actualiza existente |
| `REMOVEKEY(dict, key)` | Elimina propiedad (usa `RemoveProperty`) |
| `GETVALUE(dict, key)` | Retorna valor o .NULL. si la clave no existe |
| `AKEYS(dict)` | Array con los nombres de todas las propiedades |
| `PAIR(key, val)` | Objeto Empty con propiedades `.key` y `.value` |

### Colecciones tipadas (clases instanciables)

| Clase | Descripcion |
|-------|-------------|
| `TDictionary` | Diccionario ordenado iterable. `Add(key,val)`, `Get(key)`, `ContainsKey(key)`, `hasNext()`, `Next()` -> PAIR, `Reset()`. Internamente usa `Collection` de VFP con `.Add(value, key)`. |
| `TStringList` | Lista tipada de strings. `Add(str)`, `Join(sep)`, `hasNext()`, `Next()`. |
| `tArray` | Array iterable de tipos mixtos. `Push(v)`, `Pop()`, `Get(i)`, `Set(i,v)`. |

Para instanciar estas clases basta con `CREATEOBJECT("TDictionary")` etc. -- la clase
queda disponible en la sesion VFP tras `newFoxExtends()`.

### Miscelanea

| Funcion | Descripcion |
|---------|-------------|
| `ENUM(v1,v2,...)` | Crea objeto con propiedades = valores (enumeracion simple) |
| `ARGS(v1,...,v26)` | Empaqueta parametros en objeto con propiedad `.args[]` |
| `APARAMS(@args)` | Desempaqueta `.args[]` a array VFP nativo |
| `STRINGLIST(loArgs)` | Crea TStringList desde objeto ARGS |
| `ANYTOSTR(v)` | Serializa cualquier valor VFP a string representativo |
| `JSONTOSTR(obj)` | Objeto VFP -> JSON string (usa provider o JSONFOX.APP) |
| `STRTOJSON(str)` | JSON string -> objeto VFP Empty (usa provider o JSONFOX.APP) |
| `newGuid()` | GUID en formato `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}` |

### Clases auxiliares internas (no instanciar ni llamar directamente)

- `AnyToString` -- motor de serializacion; instancia cacheada en `_vfp.fxAnyToString`
- `tIterable` -- base class abstracta de TDictionary, tArray, TStringList
- `FOXEXTENDS_INIT` -- funcion de preamble; solo debe llamarse desde `newFoxExtends()`
- `CHECKJSONAPP` -- helper interno; se llama desde JSONTOSTR/STRTOJSON

---

## 4. Estado actual exacto

### Resultado de los tests

```
Comando:
    foxunit run --prg "FoxExtends\tests\FoxExtendsTests.prg" --format console

Variable de entorno requerida:
    FOXUNIT_VFP_PROGID=VisualFoxpro.Application.9

Working directory:
    C:\Desarrollo\IrwinRodriguez.dev

Resultado verificado 2026-05-10:
    71 passed, 0 failed  (~2.2 segundos totales)
    Primer test: ~700ms (compilacion inicial del script generado)
    Tests restantes: ~10ms cada uno
```

### Cobertura por grupo

| Grupo | Tests | Estado |
|-------|-------|--------|
| PAIR | 2 | OK |
| ALIST | 2 | OK |
| APUSH / APOP | 3 | OK |
| AJOIN | 2 | OK |
| ASPLIT | 1 | OK |
| AREVERSE | 2 | OK |
| AUNIQUE | 2 | OK |
| ARIGHT | 4 | OK |
| ALEFT | 1 | OK |
| AINTERSECT | 2 | OK |
| AEXCEPT | 1 | OK |
| AUNION | 1 | OK |
| ACONCAT | 1 | OK |
| ACLONE | 1 | OK |
| ASLICE | 3 | OK |
| ASUBSTR | 1 | OK |
| AZIP | 2 | OK |
| AMAP | 1 | OK |
| AFILTER | 2 | OK |
| AEVERY | 2 | OK |
| MATCH | 3 | OK |
| AMATCH | 2 | OK |
| REVERSE / CLAMP / PRINTF | 4 | OK |
| HASHTABLE / HASKEY / ADDKEY / REMOVEKEY / GETVALUE / AKEYS | 7 | OK |
| ENUM | 1 | OK |
| ANYTOSTR | 4 | OK |
| ARGS / APARAMS / STRINGLIST | 4 | OK |
| JSON injection (SetFoxExtendsJsonProvider + newFoxExtends param) | 4 | OK |
| TDictionary (iterator + ContainsKey + Get + Get null) | 4 | OK |
| **TOTAL** | **71** | **OK** |

### Funciones sin cobertura de tests

- `newGuid` -- no determinista (testear formato, no valor)
- `FOREACH` -- sin tests; ejecuta predicate, no retorna
- Modo OBJ -- funciona por diseno, sin tests propios
- Llamadas con prefijo -- sin tests (ej: `newFoxExtends("fx")`)

---

## 5. Decisiones tecnicas clave

### 5.1 `SET PROCEDURE TO ADDITIVE` en vez de `DO`

**Problema:** En el contexto COM de foxunit cada test es un call frame independiente.
Las funciones cargadas con `DO file.prg` dentro de `SetUp()` desaparecen del search chain
cuando `SetUp()` retorna. El siguiente test ve `PAIR()` y VFP busca `pair.prg`.

**Diagnostico obtenido experimentalmente:**
- `SYS(16)` dentro de un metodo de clase devuelve la ruta del `.fxp` temporal de foxunit,
  no el `.prg` fuente
- `CURDIR()` devuelve `\Windows\System32\` (default de la sesion VFP COM)
- Las funciones de `DO file.prg` viven en el call chain del frame que emitio el DO;
  al retornar ese frame, desaparecen del search order

**Solucion:** `SET PROCEDURE TO (lcFxpFile) ADDITIVE` hace que las funciones persistan
globalmente en la sesion VFP independientemente de call frames.

**Por que no `DO` + `SET PROCEDURE TO` juntos:** Causan redefinicion de clases internas
(AnyToString, tArray, etc.). VFP reporta error -> `messagebox()` -> hang permanente en
contexto headless (el proceso foxunit timea a 30s y mata VFP).

**Impacto en produccion:** Ninguno. `SET PROCEDURE TO ADDITIVE` es compatible con cualquier
script VFP normal. El comportamiento observable es identico al `DO` anterior.

### 5.2 `FOXEXTENDS_INIT` como funcion dentro del TEXT TO block

El preamble de inicializacion (`_vfp.foxExtendsRegEx`, `_vfp.fxAnyToString`,
`_vfp.foxExtendsJsonProvider`) era codigo top-level del script generado. Con
`SET PROCEDURE TO`, el codigo top-level NO se ejecuta -- solo se registran los procedures.
Se extrajo a `Function FOXEXTENDS_INIT` dentro del TEXT TO block y se llama
explicitamente en la seccion de ejecucion, despues del `SET PROCEDURE TO`.

Orden obligatorio:
1. `SET PROCEDURE TO (lcFxpFile) ADDITIVE`  <- define AnyToString y demas clases
2. `=FOXEXTENDS_INIT()`                     <- crea instancia de AnyToString (ya disponible)

Invertir el orden causaria "Class ANYTOSTRING not found".

### 5.3 Predicados -- binding a `lxFEPredVal`

**Problema original:** `Transform($0)` en el predicate string causaba que valores string
se convirtieran en `"Apple"` con comillas literales en el valor, rompiendo comparaciones
de igualdad y funciones de string.

**Solucion actual:** el elemento se asigna a `LOCAL lxFEPredVal`, y la sustitucion
reemplaza el texto `$0` por el literal `lxFEPredVal`:

```foxpro
Local lxFEPredVal
For i = 1 To Alen(tArray, 1)
    lxFEPredVal = tArray[i]
    lcExp = Strtran(tcPredicate, "$0", "lxFEPredVal")
    * ... Evaluate(lcExp) ...
Endfor
```

`EVALUATE("lxFEPredVal > 5")` resuelve la variable local -- funciona para N, C, L, D, T.
`EVALUATE('"Apple" > 5')` (el comportamiento anterior) fallaba o daba resultados erroneos.

### 5.4 AnyToString sin side effects globales

La version original hacia `SET CENTURY ON` y `SET DATE YMD` en el constructor y los
restauraba con propiedades guardadas. Problema: side effects visibles si algo fallaba.
Version actual usa exclusivamente:
- `DTOS(value)` --> `YYYYMMDD` independiente de `SET DATE`/`SET CENTURY`/`SET CENTURY TO`
- `HOUR()`, `MINUTE()`, `SEC()` para componentes de datetime

### 5.5 Codificacion de archivos

| Archivo | Codificacion | Saltos | Indentacion |
|---------|-------------|--------|-------------|
| `FoxExtends.prg` | Windows-1252 (ANSI), ASCII puro 0-127 | LF (sin CR) | Tabs |
| `FoxExtendsTests.prg` | Windows-1252 (ANSI), ASCII puro 0-127 | LF (sin CR) | 4 espacios |

> ⚠️ **Esto está obsoleto.** La regla de la casa NO es «ASCII puro»: es
> **CP1252, y los acentos se escriben**. Lo de prohibirlos describía la limitación
> de la herramienta que escribe, no la de VFP. Fuente de verdad, con la medición:
> `IrwinRodriguez.dev/REGLAS-VFP.md`, sección 1.

Los `.prg` usan ASCII puro (no acentos, no enies) porque VFP los lee en ANSI pero las
herramientas de IA los escriben en UTF-8. Los bytes 0-127 son identicos en ambas
codificaciones -- elimina el problema permanentemente.

Los tests usan **4 espacios** (no tabs) porque foxunit descubre los tests por indentacion:
si `PROCEDURE Test_...` tiene un tab delante, el test no se descubre silenciosamente.

### 5.6 `FoxExtendsCompileFile` -- riesgo de messagebox en headless

`FoxExtendsCompileFile` llama `messagebox()` ante errores de compilacion del script
generado. En contexto COM headless (foxunit), el messagebox bloquea permanentemente.

**Sintoma:** el primer test timea a 30s y el proceso VFP es matado.
**Diagnostico:** buscar el `.err` mas reciente en `%TEMP%` -- contiene la linea exacta.
**Estado:** no corregido. Es el riesgo principal al modificar el TEXT TO block.

### 5.7 Ruta hardcodeada en los tests

```foxpro
lcLibFile = "C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\FoxExtends.prg"
```

Es intencional: no hay forma fiable de derivar la ruta en el contexto COM de foxunit.
Es el mismo patron que usan los tests del portal en `IrwinPortalApi/Tests/`.
Si el proyecto se mueve, cambiar la linea 16 de `FoxExtendsTests.prg`.

---

## 6. Como arrancar / validar / parar

### Prerequisitos

```powershell
# Variable de entorno requerida por foxunit CLI
$env:FOXUNIT_VFP_PROGID = "VisualFoxpro.Application.9"

# Working directory siempre debe ser el root del repo
Set-Location "C:\Desarrollo\IrwinRodriguez.dev"
```

### Correr los tests

```powershell
foxunit run --prg "FoxExtends\tests\FoxExtendsTests.prg" --format console
```

Output esperado: `71 passed` en ~2.2 segundos. Exit code 0.

### Usar la biblioteca en un script normal (produccion)

```foxpro
* Paso 1: cargar FoxExtends.prg en el search chain
SET DEFAULT TO justpath(SYS(16))     && directorio del programa actual
DO "ruta\a\FoxExtends.prg"

* Paso 2: generar y registrar las funciones API
=newFoxExtends()

* Paso 3: usar la API
laData = ALIST("alpha", "beta", "gamma")
laFiltered = AFILTER(@laData, "LEN(lxFEPredVal) > 4")
? AJOIN(@laFiltered, ", ")           && "alpha, gamma"
```

### Con JSON inyectado (sin JSONFOX.APP)

```foxpro
* Instanciar el provider compatible
SET PROCEDURE TO "JSONFox\JsonFox.prg" ADDITIVE
LOCAL loJson
loJson = CREATEOBJECT("JsonFox")     && debe exponer .Stringify() y .Parse()

* Opcion A: via tercer parametro
=newFoxExtends("", "prg", loJson)

* Opcion B: via funcion standalone
=newFoxExtends()
=SetFoxExtendsJsonProvider(loJson)

* Usar JSON
LOCAL loObj
loObj = CREATEOBJECT("Empty")
=AddProperty(loObj, "score", 42)
? JSONTOSTR(loObj)                   && {"score":42}
```

### Diagnosticar un timeout de 30s en los tests

```powershell
# Buscar el .err mas reciente -- contiene la linea exacta del error de compilacion
Get-ChildItem "$env:TEMP" -Filter "*.err" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 3 |
    ForEach-Object { Write-Host "=== $($_.Name) ==="; Get-Content $_.FullName }
```

La linea N del `.err` corresponde aproximadamente a la linea N del TEXT TO block
en `FoxExtends.prg` (tras el procesamiento de PRETEXT 7 que elimina 1 tab de prefijo).

### Editar `FoxExtends.prg` desde PowerShell (encoding correcto)

```powershell
# SIEMPRE usar ReadAllText/WriteAllText con CP1252 y LF puro
$path = "C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\FoxExtends.prg"
$enc  = [Text.Encoding]::GetEncoding(1252)
$c    = [IO.File]::ReadAllText($path, $enc)

# Reemplazar -- usar `n para LF, `t para tab; NO usar `r`n
$old = "texto a reemplazar`n"   && LF puro
$new = "texto nuevo`n"
$c   = $c.Replace($old, $new)

[IO.File]::WriteAllText($path, $c, $enc)

# Verificar que el patron se encontro antes de escribir:
$c.Contains($old)   && debe ser True
```

### Parar / liberar

No hay cleanup necesario. Las funciones quedan en el procedure chain hasta fin de sesion.
Para liberar explicitamente:

```foxpro
RELEASE PROCEDURE "C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\FoxExtends.prg"
```

---

## 7. Tests -- detalle de la infraestructura

### Estructura de `FoxExtendsTests.prg`

```foxpro
*============================================================*
* FoxExtendsTests.prg
* Correr con: foxunit run --prg FoxExtends\tests\FoxExtendsTests.prg --format console
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
        IF TYPE('_vfp.foxExtendsJsonProvider') == 'O'
            _vfp.foxExtendsJsonProvider = .NULL.
        ENDIF
    ENDPROC

    PROCEDURE Test_Grupo_Escenario_Resultado() HELP [Fact]
        * __assert.Equal(expected, actual, "mensaje opcional")
        * __assert.True(condition, "mensaje")
        * __assert.False(condition, "mensaje")
    ENDPROC

    * ... 71 tests ...

ENDDEFINE

* FxJsonStub -- fuera del ENDDEFINE, disponible globalmente en la sesion VFP
DEFINE CLASS FxJsonStub AS Custom
    FUNCTION Stringify(toObj)
        * AMEMBERS() + string building -> {"key":val}
    ENDFUNC
    FUNCTION Parse(tcJson)
        * split por coma + AT(":") -> objeto Empty con propiedades
    ENDFUNC
ENDDEFINE
```

### Reglas de formato -- todas obligatorias

| Regla | Detalle |
|-------|---------|
| Indentacion de `PROCEDURE` | **4 espacios exactos** -- tab causa que el test NO se descubra silenciosamente |
| Firma de test | `PROCEDURE Test_Nombre() HELP [Fact]` -- el `HELP [Fact]` es obligatorio |
| Clase base | `DEFINE CLASS X AS Custom` -- no declarar `Name = ""` en Custom subclasses |
| Encoding | Windows-1252, LF puro (sin CR), ASCII puro 0-127 sin acentos |
| `SET PROCEDURE TO` en SetUp | Obligatorio para persistir funciones entre call frames de foxunit |

### Guard de carga unica

```foxpro
PUBLIC gcFoxExtendsLoaded
```

La variable publica persiste entre calls a `SetUp()` en la misma sesion foxunit.
Evita recompilar el script generado (700ms) en cada uno de los 71 SetUp calls.
En el primer SetUp se carga todo; los siguientes 70 son no-ops.

### TearDown: reset del JSON provider

```foxpro
IF TYPE('_vfp.foxExtendsJsonProvider') == 'O'
    _vfp.foxExtendsJsonProvider = .NULL.
ENDIF
```

Solo resetea si es un objeto (tipo 'O'). Si ya es .NULL. (tipo 'X'), no hace nada.
Garantiza aislamiento entre los 4 tests de inyeccion JSON.

---

## 8. Limitaciones conocidas y riesgos

### Limitaciones funcionales

| Limitacion | Detalle |
|-----------|---------|
| **FOREACH sin retorno** | Solo efectos secundarios. Para transformar: usar AMAP. |
| **ALIST max 26 elementos** | VFP limita parametros a 27; se usa 1 para el nombre. |
| **HASHTABLE max 50 pares** | La funcion acepta hasta 100 parametros (50 key-value pairs). |
| **ASLICE solo notacion basica** | Soporta `"start:end"`, `":end"`, `"start:"`. Sin notacion con paso. |
| **JSON provider sin validacion de contrato** | No se verifica que el objeto tenga `.Stringify()` y `.Parse()` -- falla en runtime si el contrato no se cumple. |
| **Predicados: solo expresiones EVALUATE-ables** | El predicate string se pasa a `EVALUATE()`. Sin bloques multi-linea. |
| **Arrays 2D: solo en AnyToString** | `ALIST`, `APUSH`, etc. trabajan exclusivamente con arrays 1D. AnyToString si serializa 2D. |

### Riesgos tecnicos

| Riesgo | Impacto | Estado |
|--------|---------|--------|
| **messagebox en headless** | Error de compilacion del TEXT TO block -> messagebox -> hang permanente -> timeout 30s | Sin mitigar |
| **Ruta hardcodeada en tests** | Mover el proyecto rompe los tests (linea 16 de FoxExtendsTests.prg) | Intencional |
| **SET PROCEDURE TO acumulativo** | Multiples llamadas a `newFoxExtends()` cargan multiples .fxp. La guard en tests lo evita. | Benigno en tests; riesgo en produccion sin guard |
| **Redefinicion de clases** | Si `newFoxExtends()` se llama dos veces en la misma sesion, el segundo SET PROCEDURE TO puede causar conflictos con AnyToString ya definida | Mitigado con guard; riesgo sin ella |
| **Acumulacion de .fxp en TEMP** | Los .fxp temporales no se eliminan del disco. Se acumulan en sesiones largas. | Cosmetico |

---

## 9. Backlog futuro

Estas funcionalidades **no existen** en el codigo actual. No asumir su presencia.

### Alta prioridad

- [ ] **`AREDUCE` / `AFOLD`** -- reduce array a escalar con predicate acumulador
- [ ] **`ASORT`** -- ordenacion con comparador opcional
- [ ] **`AFIND`** -- primer elemento que cumple predicate (diferente de AFILTER)
- [ ] **`AFINDINDEX`** -- indice del primer elemento que cumple predicate
- [ ] **Silenciar messagebox en FoxExtendsCompileFile** -- modo silencioso para contextos
  headless; almacenar error en variable consultable en vez de messagebox

### Media prioridad

- [ ] **Validacion del contrato JSON provider** -- error descriptivo si falta .Stringify()
  o .Parse() al llamar SetFoxExtendsJsonProvider
- [ ] **`AGROUP`** -- agrupa elementos por predicate -> diccionario de arrays
- [ ] **`AZIP` variadic** -- aceptar mas de 2 arrays
- [ ] **Ruta dinamica en tests** -- variable de entorno `FOXEXTENDS_ROOT` leida con GETENV()
- [ ] **Tests para modo OBJ** -- actualmente sin cobertura
- [ ] **Test para `newGuid`** -- validar formato UUID (no el valor, que es no-deterministico)
- [ ] **Tests para `FOREACH`** -- actualmente sin cobertura
- [ ] **Tests con prefijo** -- `newFoxExtends("fx")` para validar prefijos en toda la API

### Baja prioridad

- [ ] **`TDictionary.Remove(key)`** -- actualmente no existe; solo ContainsKey, Get, Add
- [ ] **Guard defensiva en `TArray.ToString`** -- verificar que `_vfp.fxAnyToString` esta
  inicializado antes de usarlo
- [ ] **Cleanup de .fxp en TEMP** -- mecanismo para limpiar temporales al fin de sesion

---

## 10. Guardrails -- lo que NO esta implementado

> Restricciones criticas. Una IA que retome este proyecto NO debe asumir estas cosas.

1. **No existe `AFOREACH`** -- la funcion se llama `FOREACH`. No hay alias.

2. **`FOREACH` no retorna valor util** -- retorna .T. o nada. Para transformar: AMAP.

3. **No existe sistema de modulos, imports ni namespaces** -- FoxExtends es un unico .prg.
   No hay `#include`, `DO ... IN`, ni nada equivalente a modulos.

4. **No existe encadenamiento fluent** -- no hay APIPE, ACHAIN ni nada similar.

5. **El modo OBJ no tiene tests** -- funciona por diseno pero cualquier cambio a el
   requiere anadir tests antes de considerarlo validado.

6. **`TDictionary` no tiene `Remove`** -- solo `ContainsKey`, `Get`, `Add`, iterador
   (`hasNext`, `Next`, `Reset`).

7. **El bloque TEXT TO es una plantilla de texto, no codigo VFP ejecutable** -- las lineas
   dentro del TEXT TO son literales con placeholders `<<...>>`. Modificarlas requiere
   entender TEXTMERGE + PRETEXT 7. Si se introduce un error de sintaxis, el sintoma es
   timeout de 30s en el primer test (VFP cuelga en messagebox).

8. **`FoxExtendsCompileFile` usa MESSAGEBOX ante errores** -- cualquier modificacion al
   TEXT TO block que introduzca un error de sintaxis VFP causara un hang permanente en
   foxunit. Diagnosticar siempre con el .err en %TEMP%.

9. **Linea 16 de FoxExtendsTests.prg tiene ruta hardcodeada** -- cambiarla si el proyecto
   se mueve: `lcLibFile = "C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\FoxExtends.prg"`

10. **`AMATCH` retorna array de substrings, no de posiciones** -- los elementos son los
    textos encontrados, no los indices donde aparecen.

11. **`newFoxExtends()` no es idempotente sin guard** -- llamarla dos veces en la misma
    sesion VFP puede causar conflictos de clase. En produccion, el consumidor debe
    implementar su propia guard (como `gcFoxExtendsLoaded` en los tests).

12. **`ASLICE` con indices negativos no esta especificado ni testeado** -- no asumir
    soporte de Python-style negative indexing en ASLICE.

---

## 11. Referencia rapida de comandos

```powershell
# === TESTS ===
$env:FOXUNIT_VFP_PROGID = "VisualFoxpro.Application.9"
Set-Location "C:\Desarrollo\IrwinRodriguez.dev"
foxunit run --prg "FoxExtends\tests\FoxExtendsTests.prg" --format console

# === DIAGNOSTICAR TIMEOUT (error de compilacion del script generado) ===
Get-ChildItem "$env:TEMP" -Filter "*.err" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 3 |
    ForEach-Object { Write-Host "=== $($_.Name) ==="; Get-Content $_.FullName }

# === EDITAR FoxExtends.prg (tabs + LF + CP1252) ===
$path = "C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\FoxExtends.prg"
$enc  = [Text.Encoding]::GetEncoding(1252)
$c    = [IO.File]::ReadAllText($path, $enc)
# Verificar patron: $c.Contains($old)   <- SIEMPRE verificar antes de Replace
$c    = $c.Replace($old, $new)
[IO.File]::WriteAllText($path, $c, $enc)

# === EDITAR FoxExtendsTests.prg (4 espacios + LF + CP1252) ===
$path = "C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\tests\FoxExtendsTests.prg"
$enc  = [Text.Encoding]::GetEncoding(1252)
$c    = [IO.File]::ReadAllText($path, $enc)
$c    = $c.Replace($old, $new)
[IO.File]::WriteAllText($path, $c, $enc)

# === INSPECCION DE BYTES (depurar tabs vs espacios) ===
$path = "C:\Desarrollo\IrwinRodriguez.dev\FoxExtends\FoxExtends.prg"
$enc  = [Text.Encoding]::GetEncoding(1252)
$c    = [IO.File]::ReadAllText($path, $enc)
$lines = $c -split "`n"
$lines[62..80] | ForEach-Object -Begin {$i=63} -Process {
    Write-Host "$i: $($_ -replace '`t','[T]')"; $i++
}
```

---

## 12. Contexto de repositorio

FoxExtends vive en `C:\Desarrollo\IrwinRodriguez.dev\` junto a otros proyectos
completamente independientes:

| Directorio | Tecnologia | Descripcion | Estado |
|-----------|-----------|-------------|--------|
| `IrwinPortalApi/` | VFP9 + FoxServer | API REST e-commerce de licencias RSA | COMPLETO |
| `IrwinRodriguezDev/` | X# (.NET 4.8) | Firma RSA-SHA256 + helpers COM | COMPLETO |
| `IrwinPortalWeb/` | Astro + TypeScript | Frontend i18n ES/EN/DE | COMPLETO |
| `HttpRequest/` | X# (.NET 4.8) | Libreria COM HTTP `WinFx.HttpRequest` | COMPLETO |
| `JSONFox/` | VFP9 PRG | JSONFox version PRG self-contained | Sin tocar |
| `FoxExtends/` | VFP9 PRG | Esta biblioteca | ESTABLE, 71/71 tests |

**FoxExtends no tiene dependencias sobre ningun otro directorio del repo.**
La unica integracion potencial (no implementada) es inyectar `JSONFox\JsonFox.prg` como
provider JSON via `SetFoxExtendsJsonProvider`.
