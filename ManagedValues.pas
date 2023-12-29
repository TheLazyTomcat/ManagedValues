{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Managed Values is a small framework that provides a set of classes which
    are meant to be used in place of normal variables or fields in situations,
    where there is a need for tracking of changes in relation to initial value.

    Special class is implemented for each type (they all have common ancestor),
    which means the actual value must be stored or read using the provided
    properties (implementing operator overloads is problematic).
    It also means each variable or field must be initialized (the value object
    must be instantiated) before use and freed when not used anymore. It is
    enough to pass uninstantiated variable to InitValue function provided here
    and free it using function FinalValue.

    If you want to track changes in multiple values automatically, pool them in
    a local (user-created) values manager (class TValuesManager). You can then
    use its method to track the entire list for changes.
    The manager can also be used to directly instantiate new values using
    its methods.

    WARNING - any managed value can be pooled only in one local manager, if you
              try to add it to another, an EMVAlreadyManaged exception will be
              raised.

    NOTE - local managers do not own the pooled values, if you remove one from
           there, it will NOT be automatically freed.

    When symbol MV_GlobalManager is defined, an implicit (hidden) global manager
    is created and all created values are pooled in there. Also, all values
    being freed are automatically removed from it.
    At the end of program run, when this global manager is freed, all values
    still pooled in it are also freed. This means you do not actually have to
    free your variables when you are using them for the entire lifespan of your
    application.

    When you want to utilize any managed value type, it is usually enough to
    add reference to this unit (ManagedValues.pas) to uses clause.
    Sometimes it might be necessary to add ManagedValues_Base, but it should
    not be necessary to add any of the specific implementation unit, as all the
    classes are forwarded in here.

    Currently, managed values for following basic types are implemented:

      Boolean, Int8 (SmallInt), UInt8 (Byte), Int16 (ShortInt), UInt16 (Word),
      Int32 (LongInt, Integer), UInt32 (LongWord, Cardinal), Int64, UInt64,
      Float32 (Single), Float64 (Double), TDateTime, Currency, AnsiChar,
      UTF8Char, WideChar, UnicodeChar, Char, ShortString, AnsiString,
      UTF8String, WideString, UnicodeString, String, Pointer, Object, TGUID

    Values for the following complex types are also implemented (at this moment
    only dynamic arrays:

      (dynamic) array of Boolean, array of Int8, array of UInt8, array of Int16,
      array of UInt16, array of Int32, array of UInt32, array of Int64,
      array of UInt64, array of Float32, array of Float64, array of TDateTime,
      array of Currency, array of AnsiChar, array of UTF8Char,
      array of WideChar, array of UnicodeChar, array of Char,
      array of ShortString, array of AnsiString, array of UTF8String,
      array of WideString, array of UnicodeString, array of String,
      array of Poínter, array of TObject, array of TGUID

  Version 1.0.1 alpha (2020-08-30) - requires extensive testing

  Last changed 2023-12-29

  ©2020-2023 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/ManagedValues

  Dependencies:
    AuxClasses      - github.com/TheLazyTomcat/Lib.AuxClasses
    AuxTypes        - github.com/TheLazyTomcat/Lib.AuxTypes    
    BinaryStreaming - github.com/TheLazyTomcat/Lib.BinaryStreaming
    ListSorters     - github.com/TheLazyTomcat/Lib.ListSorters
    StrRect         - github.com/TheLazyTomcat/Lib.StrRect
    UInt64Utils     - github.com/TheLazyTomcat/Lib.UInt64Utils     

===============================================================================}
unit ManagedValues;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  AuxTypes,
  ManagedValues_Base,
  // primitives
  ManagedValues_BooleanValue,
  ManagedValues_Int8Value,
  ManagedValues_UInt8Value,
  ManagedValues_Int16Value,
  ManagedValues_UInt16Value,
  ManagedValues_Int32Value,
  ManagedValues_UInt32Value,
  ManagedValues_Int64Value,
  ManagedValues_UInt64Value,
  ManagedValues_Float32Value,
  ManagedValues_Float64Value,
  ManagedValues_DateTimeValue,
  ManagedValues_CurrencyValue,
  ManagedValues_AnsiCharValue,
  ManagedValues_UTF8CharValue,
  ManagedValues_WideCharValue,
  ManagedValues_UnicodeCharValue,
  ManagedValues_CharValue,
  ManagedValues_ShortStringValue,
  ManagedValues_AnsiStringValue,
  ManagedValues_UTF8StringValue,
  ManagedValues_WideStringValue,
  ManagedValues_UnicodeStringValue,
  ManagedValues_StringValue,
  ManagedValues_PointerValue,
  ManagedValues_ObjectValue,
  ManagedValues_GUIDValue,
  // arrays
  ManagedValues_AoBooleanValue,
  ManagedValues_AoInt8Value,
  ManagedValues_AoUInt8Value,
  ManagedValues_AoInt16Value,
  ManagedValues_AoUInt16Value,
  ManagedValues_AoInt32Value,
  ManagedValues_AoUInt32Value,
  ManagedValues_AoInt64Value,
  ManagedValues_AoUInt64Value,
  ManagedValues_AoFloat32Value,
  ManagedValues_AoFloat64Value,
  ManagedValues_AoDateTimeValue,
  ManagedValues_AoCurrencyValue,
  ManagedValues_AoAnsiCharValue,
  ManagedValues_AoUTF8CharValue,
  ManagedValues_AoWideCharValue,
  ManagedValues_AoUnicodeCharValue,
  ManagedValues_AoCharValue,
  ManagedValues_AoShortStringValue,
  ManagedValues_AoAnsiStringValue,
  ManagedValues_AoUTF8StringValue,
  ManagedValues_AoWideStringValue,
  ManagedValues_AoUnicodeStringValue,
  ManagedValues_AoStringValue,
  ManagedValues_AoPointerValue,
  ManagedValues_AoObjectValue,
  ManagedValues_AoGUIDValue;

{===============================================================================
--------------------------------------------------------------------------------
                         Aliases nad utility functions
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    Aliases nad utility functions - declaration
===============================================================================}
{-------------------------------------------------------------------------------
    Common types
-------------------------------------------------------------------------------}
type
  // this is somewhat pointless as the individual values cannot be accessed from this unit, but meh...
  TManagedValueType = TMVManagedValueType;

  TManagedValue = TMVManagedValueBase;

  // in case someone wants a base class only for array values with a nice name ;)
  TArrayManagedValue = TMVArrayManagedValue;

  TManagedValueClass = class of TManagedValue;

  TValuesManagerBase = TMVValuesManagerBase;

Function ClassFromValueType(ValueType: TManagedValueType): TManagedValueClass;

Function CreateValue(ValueType: TManagedValueType; const Name: String = ''): TManagedValue; overload;
Function CreateValue(ValueClass: TManagedValueClass; const Name: String = ''): TManagedValue; overload;
procedure FreeValue(var Value: TManagedValue); overload;

{-------------------------------------------------------------------------------
    TBooleanValue
-------------------------------------------------------------------------------}
type
  TBooleanValue = class(TMVBooleanValue);
  
  TBoolValue = TBooleanValue;

procedure InitValue(out Value: TBooleanValue; const Name: String = ''; InitializeTo: Boolean = False); overload;
procedure FinalValue(var Value: TBooleanValue); overload;

{-------------------------------------------------------------------------------
    TInt8Value
-------------------------------------------------------------------------------}
type
  TInt8Value = class(TMVInt8Value);

  TShortIntValue = TInt8Value;

procedure InitValue(out Value: TInt8Value; const Name: String = ''; InitializeTo: Int8 = 0); overload;
procedure FinalValue(var Value: TInt8Value); overload;

{-------------------------------------------------------------------------------
    TUInt8Value
-------------------------------------------------------------------------------}
type
  TUInt8Value = class(TMVUInt8Value);

  TByteValue = TUInt8Value;

procedure InitValue(out Value: TUInt8Value; const Name: String = ''; InitializeTo: UInt8 = 0); overload;
procedure FinalValue(var Value: TUInt8Value); overload;

{-------------------------------------------------------------------------------
    TInt16Value
-------------------------------------------------------------------------------}
type
  TInt16Value = class(TMVInt16Value);

  TSmallIntValue = TInt16Value;

{$IF SizeOf(Integer) = 2}
  TIntegerValue = TInt16Value;
{$IFEND}

procedure InitValue(out Value: TInt16Value; const Name: String = ''; InitializeTo: Int16 = 0); overload;
procedure FinalValue(var Value: TInt16Value); overload;

{-------------------------------------------------------------------------------
    TUInt16Value
-------------------------------------------------------------------------------}
type
  TUInt16Value = class(TMVUInt16Value);

  TWordValue = TUInt16Value;

{$IF SizeOf(Cardinal) = 2}
  TCardinalValue = TUInt16Value;
{$IFEND}

procedure InitValue(out Value: TUInt16Value; const Name: String = ''; InitializeTo: UInt16 = 0); overload;
procedure FinalValue(var Value: TUInt16Value); overload;

{-------------------------------------------------------------------------------
    TInt32Value
-------------------------------------------------------------------------------}
type
  TInt32Value = class(TMVInt32Value);

{$IF SizeOf(LongInt) = 4}
  TLongIntValue = TInt32Value;
{$IFEND}

{$IF SizeOf(Integer) = 4}
  TIntegerValue = TInt32Value;
{$IFEND}

{$IF SizeOf(Pointer) = 4}
  TPtrIntValue    = TInt32Value;
  TNativeIntValue = TInt32Value;
{$IFEND}

procedure InitValue(out Value: TInt32Value; const Name: String = ''; InitializeTo: Int32 = 0); overload;
procedure FinalValue(var Value: TInt32Value); overload;

{-------------------------------------------------------------------------------
    TUInt32Value
-------------------------------------------------------------------------------}
type
  TUInt32Value = class(TMVUInt32Value);

  TDWordValue    = TUInt32Value;

{$IF SizeOf(Cardinal) = 4}
  TCardinalValue = TUInt32Value;
{$IFEND}

{$IF SizeOf(LongWord) = 4}
  TLongWordValue = TUInt32Value;
{$IFEND}

{$IF SizeOf(Pointer) = 4}
  TPtrUIntValue    = TUInt32Value;
  TNativeUIntValue = TUInt32Value;
{$IFEND}

procedure InitValue(out Value: TUInt32Value; const Name: String = ''; InitializeTo: UInt32 = 0); overload;
procedure FinalValue(var Value: TUInt32Value); overload;

{-------------------------------------------------------------------------------
    TInt64Value
-------------------------------------------------------------------------------}
type
  TInt64Value = class(TMVInt64Value);

{$IF SizeOf(Integer) = 8}
  TIntegerValue = TInt64Value;
{$IFEND}

{$IF SizeOf(LongInt) = 8}
  TLongIntValue = TInt64Value;
{$IFEND}

{$IF SizeOf(Pointer) = 8}
  TPtrIntValue    = TInt64Value;
  TNativeIntValue = TInt64Value;
{$IFEND}

procedure InitValue(out Value: TInt64Value; const Name: String = ''; InitializeTo: Int64 = 0); overload;
procedure FinalValue(var Value: TInt64Value); overload;

{-------------------------------------------------------------------------------
    TUInt64Value
-------------------------------------------------------------------------------}
type
  TUInt64Value = class(TMVUInt64Value);

  TQWordValue    = TUInt64Value;
  TQuadWordValue = TUInt64Value;

{$IF SizeOf(Cardinal) = 8}
  TCardinalValue = TUInt64Value;
{$IFEND}

{$IF SizeOf(LongWord) = 8}
  TLongWordValue = TUInt64Value;
{$IFEND}

{$IF SizeOf(Pointer) = 8}
  TPtrUIntValue    = TUInt64Value;
  TNativeUIntValue = TUInt64Value;
{$IFEND}

procedure InitValue(out Value: TUInt64Value; const Name: String = ''; InitializeTo: UInt64 = 0); overload;
procedure FinalValue(var Value: TUInt64Value); overload;

{-------------------------------------------------------------------------------
    TFloat32Value
-------------------------------------------------------------------------------}
type
  TFloat32Value = class(TMVFloat32Value);

  TSingleValue = TFloat32Value;

procedure InitValue(out Value: TFloat32Value; const Name: String = ''; InitializeTo: Float32 = 0.0); overload;
procedure FinalValue(var Value: TFloat32Value); overload;

{-------------------------------------------------------------------------------
    TFloat64Value
-------------------------------------------------------------------------------}
type
  TFloat64Value = class(TMVFloat64Value);

  TDoubleValue = TFloat64Value;
  TFloatValue  = TFloat64Value;
  TRealValue   = TFloat64Value;

procedure InitValue(out Value: TFloat64Value; const Name: String = ''; InitializeTo: Float64 = 0.0); overload;
procedure FinalValue(var Value: TFloat64Value); overload;

{-------------------------------------------------------------------------------
    TDateTimeValue
-------------------------------------------------------------------------------}
type
  TDateTimeValue = class(TMVDateTimeValue);

  TDateValue = TDateTimeValue;
  TTimeValue = TDateTimeValue;

procedure InitValue(out Value: TDateTimeValue; const Name: String = ''; InitializeTo: TDateTime = 0.0); overload;
procedure FinalValue(var Value: TDateTimeValue); overload;

{-------------------------------------------------------------------------------
    TCurrencyValue
-------------------------------------------------------------------------------}
type
  TCurrencyValue = class(TMVCurrencyValue);

procedure InitValue(out Value: TCurrencyValue; const Name: String = ''; InitializeTo: Currency = 0.0); overload;
procedure FinalValue(var Value: TCurrencyValue); overload;

{-------------------------------------------------------------------------------
    TAnsiCharValue
-------------------------------------------------------------------------------}
type
  TAnsiCharValue = class(TMVAnsiCharValue);

procedure InitValue(out Value: TAnsiCharValue; const Name: String = ''; InitializeTo: AnsiChar = #0); overload;
procedure FinalValue(var Value: TAnsiCharValue); overload;

{-------------------------------------------------------------------------------
    TUTF8CharValue
-------------------------------------------------------------------------------}
type
  TUTF8CharValue = class(TMVUTF8CharValue);

procedure InitValue(out Value: TUTF8CharValue; const Name: String = ''; InitializeTo: UTF8Char = #0); overload;
procedure FinalValue(var Value: TUTF8CharValue); overload;

{-------------------------------------------------------------------------------
    TWideCharValue
-------------------------------------------------------------------------------}
type
  TWideCharValue = class(TMVWideCharValue);

procedure InitValue(out Value: TWideCharValue; const Name: String = ''; InitializeTo: WideChar = #0); overload;
procedure FinalValue(var Value: TWideCharValue); overload;

{-------------------------------------------------------------------------------
    TUnicodeCharValue
-------------------------------------------------------------------------------}
type
  TUnicodeCharValue = class(TMVUnicodeCharValue);

procedure InitValue(out Value: TUnicodeCharValue; const Name: String = ''; InitializeTo: UnicodeChar = #0); overload;
procedure FinalValue(var Value: TUnicodeCharValue); overload;

{-------------------------------------------------------------------------------
    TCharValue
-------------------------------------------------------------------------------}
type
  TCharValue = class(TMVCharValue);

procedure InitValue(out Value: TCharValue; const Name: String = ''; InitializeTo: Char = #0); overload;
procedure FinalValue(var Value: TCharValue); overload;

{-------------------------------------------------------------------------------
    TShortStringValue
-------------------------------------------------------------------------------}
type
  TShortStringValue = class(TMVShortStringValue);

procedure InitValue(out Value: TShortStringValue; const Name: String = ''; const InitializeTo: ShortString = ''); overload;
procedure FinalValue(var Value: TShortStringValue); overload;

{-------------------------------------------------------------------------------
    TAnsiStringValue
-------------------------------------------------------------------------------}
type
  TAnsiStringValue = class(TMVAnsiStringValue);

procedure InitValue(out Value: TAnsiStringValue; const Name: String = ''; const InitializeTo: AnsiString = ''); overload;
procedure FinalValue(var Value: TAnsiStringValue); overload;

{-------------------------------------------------------------------------------
    TUTF8StringValue
-------------------------------------------------------------------------------}
type
  TUTF8StringValue = class(TMVUTF8StringValue);

procedure InitValue(out Value: TUTF8StringValue; const Name: String = ''; const InitializeTo: UTF8String = ''); overload;
procedure FinalValue(var Value: TUTF8StringValue); overload;

{-------------------------------------------------------------------------------
    TWideStringValue
-------------------------------------------------------------------------------}
type
  TWideStringValue = class(TMVWideStringValue);

procedure InitValue(out Value: TWideStringValue; const Name: String = ''; const InitializeTo: WideString = ''); overload;
procedure FinalValue(var Value: TWideStringValue); overload;

{-------------------------------------------------------------------------------
    TUnicodeStringValue
-------------------------------------------------------------------------------}
type
  TUnicodeStringValue = class(TMVUnicodeStringValue);

procedure InitValue(out Value: TUnicodeStringValue; const Name: String = ''; const InitializeTo: UnicodeString = ''); overload;
procedure FinalValue(var Value: TUnicodeStringValue); overload;

{-------------------------------------------------------------------------------
    TStringValue
-------------------------------------------------------------------------------}
type
  TStringValue = class(TMVStringValue);

procedure InitValue(out Value: TStringValue; const Name: String = ''; const InitializeTo: String = ''); overload;
procedure FinalValue(var Value: TStringValue); overload;

{-------------------------------------------------------------------------------
    TPointerValue
-------------------------------------------------------------------------------}
type
  TPointerValue = class(TMVPointerValue);

procedure InitValue(out Value: TPointerValue; const Name: String = ''; InitializeTo: Pointer = nil); overload;
procedure FinalValue(var Value: TPointerValue); overload;

{-------------------------------------------------------------------------------
    TObjectValue
-------------------------------------------------------------------------------}
type
  TObjectValue = class(TMVObjectValue);

procedure InitValue(out Value: TObjectValue; const Name: String = ''; InitializeTo: TObject = nil); overload;
procedure FinalValue(var Value: TObjectValue); overload;

{-------------------------------------------------------------------------------
    TGUIDValue
-------------------------------------------------------------------------------}
type
  TGUIDValue = class(TMVGUIDValue);

procedure InitValue(out Value: TGUIDValue; const Name: String; InitializeTo: TGUID); overload;
procedure InitValue(out Value: TGUIDValue; const Name: String = ''); overload;
procedure FinalValue(var Value: TGUIDValue); overload;

{-------------------------------------------------------------------------------
    TAoBooleanValue
-------------------------------------------------------------------------------}
type
  TAoBoolean = TMVAoBoolean;

  TAoBooleanValue = class(TMVAoBooleanValue);

  TArrayOfBoolean = TAoBoolean;
  TAoBool         = TAoBoolean;
  TArrayOfBool    = TAoBoolean;

  TArrayOfBooleanValue = TAoBooleanValue;  
  TAoBoolValue         = TAoBooleanValue;
  TArrayOfBoolValue    = TAoBooleanValue;

procedure InitValue(out Value: TAoBooleanValue; const Name: String = ''; const InitializeTo: TAoBoolean = nil); overload;
procedure FinalValue(var Value: TAoBooleanValue); overload;

{-------------------------------------------------------------------------------
    TAoInt8Value
-------------------------------------------------------------------------------}
type
  TAoInt8 = TMVAoInt8;

  TAoInt8Value = class(TMVAoInt8Value);

  TArrayOfInt8     = TAoInt8;  
  TAoShortInt      = TAoInt8;
  TArrayOfShortInt = TAoInt8;

  TArrayOfInt8Value     = TAoInt8Value;  
  TAoShortIntValue      = TAoInt8Value;
  TArrayOfShortIntValue = TAoInt8Value;

procedure InitValue(out Value: TAoInt8Value; const Name: String = ''; const InitializeTo: TAoInt8 = nil); overload;
procedure FinalValue(var Value: TAoInt8Value); overload;

{-------------------------------------------------------------------------------
    TAoUInt8Value
-------------------------------------------------------------------------------}
type
  TAoUInt8 = TMVAoUInt8;

  TAoUInt8Value = class(TMVAoUInt8Value);

  TArrayOfUInt8 = TAoUInt8;
  TAoByte       = TAoUInt8;
  TArrayOfByte  = TAoUInt8;

  TArrayOfUInt8Value = TAoUInt8Value;
  TAoByteValue       = TAoUInt8Value;
  TArrayOfByteValue  = TAoUInt8Value;

procedure InitValue(out Value: TAoUInt8Value; const Name: String = ''; const InitializeTo: TAoUInt8 = nil); overload;
procedure FinalValue(var Value: TAoUInt8Value); overload;

{-------------------------------------------------------------------------------
    TAoInt16Value
-------------------------------------------------------------------------------}
type
  TAoInt16 = TMVAoInt16;

  TAoInt16Value = class(TMVAoInt16Value);

  TArrayOfInt16    = TAoInt16;
  TAoSmallInt      = TAoInt16;
  TArrayOfSmallInt = TAoInt16;

{$IF SizeOf(Integer) = 2}
  TAoInteger      = TAoInt16;
  TArrayOfInteger = TAoInt16;
{$IFEND}

  TArrayOfInt16Value    = TAoInt16Value;
  TAoSmallIntValue      = TAoInt16Value;
  TArrayOfSmallIntValue = TAoInt16Value;

{$IF SizeOf(Integer) = 2}
  TAoIntegerValue      = TAoInt16Value;
  TArrayOfIntegerValue = TAoInt16Value;
{$IFEND}

procedure InitValue(out Value: TAoInt16Value; const Name: String = ''; const InitializeTo: TAoInt16 = nil); overload;
procedure FinalValue(var Value: TAoInt16Value); overload;

{-------------------------------------------------------------------------------
    TAoUInt16Value
-------------------------------------------------------------------------------}
type
  TAoUInt16 = TMVAoUInt16;

  TAoUInt16Value = class(TMVAoUInt16Value);

  TArrayOfUInt16 = TAoUInt16;
  TAoWord        = TAoUInt16;
  TArrayOfWord   = TAoUInt16;

{$IF SizeOf(Integer) = 2}
  TAoCardinal      = TAoUInt16;
  TArrayOfCardinal = TAoUInt16;
{$IFEND}

  TArrayOfUInt16Value = TAoUInt16Value;
  TAoWordValue        = TAoUInt16Value;
  TArrayOfWordValue   = TAoUInt16Value;

{$IF SizeOf(Integer) = 2}
  TAoCardinalValue      = TAoUInt16Value;
  TArrayOfCardinalValue = TAoUInt16Value;
{$IFEND}

procedure InitValue(out Value: TAoUInt16Value; const Name: String = ''; const InitializeTo: TAoUInt16 = nil); overload;
procedure FinalValue(var Value: TAoUInt16Value); overload;

{-------------------------------------------------------------------------------
    TAoInt32Value
-------------------------------------------------------------------------------}
type
  TAoInt32 = TMVAoInt32;

  TAoInt32Value = class(TMVAoInt32Value);

  TArrayOfInt32 = TAoInt32;

{$IF SizeOf(LongInt) = 4}
  TAoLongInt      = TAoInt32;
  TArrayOfLongInt = TAoInt32;
{$IFEND}

{$IF SizeOf(Integer) = 4}
  TAoInteger      = TAoInt32;
  TArrayOfInteger = TAoInt32;
{$IFEND}

{$IF SizeOf(Pointer) = 4}
  TAoPtrInt         = TAoInt32;
  TArrayOfPtrInt    = TAoInt32;
  TAoNativeInt      = TAoInt32;
  TArrayOfNativeInt = TAoInt32;
{$IFEND}

  TArrayOfInt32Value = TAoInt32Value;

{$IF SizeOf(LongInt) = 4}
  TAoLongIntValue      = TAoInt32Value;
  TArrayOfLongIntValue = TAoInt32Value;
{$IFEND}

{$IF SizeOf(Integer) = 4}
  TAoIntegerValue      = TAoInt32Value;
  TArrayOfIntegerValue = TAoInt32Value;
{$IFEND}

{$IF SizeOf(Pointer) = 4}
  TAoPtrIntValue         = TAoInt32Value;
  TArrayOfPtrIntValue    = TAoInt32Value;
  TAoNativeIntValue      = TAoInt32Value;
  TArrayOfNativeIntValue = TAoInt32Value;
{$IFEND}

procedure InitValue(out Value: TAoInt32Value; const Name: String = ''; const InitializeTo: TAoInt32 = nil); overload;
procedure FinalValue(var Value: TAoInt32Value); overload;

{-------------------------------------------------------------------------------
    TAoUInt32Value
-------------------------------------------------------------------------------}
type
  TAoUInt32 = TMVAoUInt32;

  TAoUInt32Value = class(TMVAoUInt32Value);

  TArrayOfUInt32 = TMVAoUInt32;

{$IF SizeOf(LongWord) = 4}
  TAoLongWord      = TAoUInt32;
  TArrayOfLongWord = TAoUInt32;
{$IFEND}

{$IF SizeOf(Cardinal) = 4}
  TAoCardinal      = TAoUInt32;
  TArrayOfCardinal = TAoUInt32;
{$IFEND}

{$IF SizeOf(Pointer) = 4}
  TAoPtrUInt         = TAoUInt32;
  TArrayOfPtrUInt    = TAoUInt32;
  TAoNativeUInt      = TAoUInt32;
  TArrayOfNativeUInt = TAoUInt32;
{$IFEND}

  TArrayOfUInt32Value = TAoUInt32Value;

{$IF SizeOf(LongWord) = 4}
  TAoLongWordValue      = TAoUInt32Value;
  TArrayOfLongWordValue = TAoUInt32Value;
{$IFEND}

{$IF SizeOf(Cardinal) = 4}
  TAoCardinalValue      = TAoUInt32Value;
  TArrayOfCardinalValue = TAoUInt32Value;
{$IFEND}

{$IF SizeOf(Pointer) = 4}
  TAoPtrUIntValue         = TAoUInt32Value;
  TArrayOfPtrUIntValue    = TAoUInt32Value;
  TAoNativeUIntValue      = TAoUInt32Value;
  TArrayOfNativeUIntValue = TAoUInt32Value;
{$IFEND}

procedure InitValue(out Value: TAoUInt32Value; const Name: String = ''; const InitializeTo: TAoUInt32 = nil); overload;
procedure FinalValue(var Value: TAoUInt32Value); overload;

{-------------------------------------------------------------------------------
    TAoInt64Value
-------------------------------------------------------------------------------}
type
  TAoInt64 = TMVAoInt64;

  TAoInt64Value = class(TMVAoInt64Value);

  TArrayOfInt64 = TAoInt64;

{$IF SizeOf(LongInt) = 8}
  TAoLongInt      = TAoInt64;
  TArrayOfLongInt = TAoInt64;
{$IFEND}

{$IF SizeOf(Integer) = 8}
  TAoInteger      = TAoInt64;
  TArrayOfInteger = TAoInt64;
{$IFEND}

{$IF SizeOf(Pointer) = 8}
  TAoPtrInt         = TAoInt64;
  TArrayOfPtrInt    = TAoInt64;
  TAoNativeInt      = TAoInt64;
  TArrayOfNativeInt = TAoInt64;
{$IFEND}

  TArrayOfInt64Value = TAoInt64Value;

{$IF SizeOf(LongInt) = 8}
  TAoLongIntValue      = TAoInt64Value;
  TArrayOfLongIntValue = TAoInt64Value;
{$IFEND}

{$IF SizeOf(Integer) = 8}
  TAoIntegerValue      = TAoInt64Value;
  TArrayOfIntegerValue = TAoInt64Value;
{$IFEND}

{$IF SizeOf(Pointer) = 8}
  TAoPtrIntValue         = TAoInt64Value;
  TArrayOfPtrIntValue    = TAoInt64Value;
  TAoNativeIntValue      = TAoInt64Value;
  TArrayOfNativeIntValue = TAoInt64Value;
{$IFEND}

procedure InitValue(out Value: TAoInt64Value; const Name: String = ''; const InitializeTo: TAoInt64 = nil); overload;
procedure FinalValue(var Value: TAoInt64Value); overload;

{-------------------------------------------------------------------------------
    TAoUInt64Value
-------------------------------------------------------------------------------}
type
  TAoUInt64 = TMVAoUInt64;

  TAoUInt64Value = class(TMVAoUInt64Value);

  TArrayOfUInt64   = TAoUInt64;
  TAoQword         = TAoUInt64;
  TArrayOfQWord    = TAoUInt64;
  TAoQuadWord      = TAoUInt64;
  TArrayOfQuadWord = TAoUInt64;

{$IF SizeOf(LongWord) = 8}
  TAoLongWord      = TAoUInt64;
  TArrayOfLongWord = TAoUInt64;
{$IFEND}

{$IF SizeOf(Cardinal) = 8}
  TAoCardinal      = TAoUInt64;
  TArrayOfCardinal = TAoUInt64;
{$IFEND}

{$IF SizeOf(Pointer) = 8}
  TAoPtrUInt         = TAoUInt64;
  TArrayOfPtrUInt    = TAoUInt64;
  TAoNativeUInt      = TAoUInt64;
  TArrayOfNativeUInt = TAoUInt64;
{$IFEND}

  TArrayOfUInt64Value   = TAoUInt64Value;
  TAoQwordValue         = TAoUInt64Value;
  TArrayOfQWordValue    = TAoUInt64Value;
  TAoQuadWordValue      = TAoUInt64Value;
  TArrayOfQuadWordValue = TAoUInt64Value;

{$IF SizeOf(LongWord) = 8}
  TAoLongWordValue      = TAoUInt64Value;
  TArrayOfLongWordValue = TAoUInt64Value;
{$IFEND}

{$IF SizeOf(Cardinal) = 8}
  TAoCardinalValue      = TAoUInt64Value;
  TArrayOfCardinalValue = TAoUInt64Value;
{$IFEND}

{$IF SizeOf(Pointer) = 8}
  TAoPtrUIntValue         = TAoUInt64Value;
  TArrayOfPtrUIntValue    = TAoUInt64Value;
  TAoNativeUIntValue      = TAoUInt64Value;
  TArrayOfNativeUIntValue = TAoUInt64Value;
{$IFEND}

procedure InitValue(out Value: TAoUInt64Value; const Name: String = ''; const InitializeTo: TAoUInt64 = nil); overload;
procedure FinalValue(var Value: TAoUInt64Value); overload;

{-------------------------------------------------------------------------------
    TAoFloat32Value
-------------------------------------------------------------------------------}
type
  TAoFloat32 = TMVAoFloat32;

  TAoFloat32Value = class(TMVAoFloat32Value);

  TArrayOfFloat32 = TAoFloat32;
  TAoSingle       = TAoFloat32;
  TArrayOfSingle  = TAoFloat32;

  TArrayOfFloat32Value = TAoFloat32Value;
  TAoSingleValue       = TAoFloat32Value;
  TArrayOfSingleValue  = TAoFloat32Value;

procedure InitValue(out Value: TAoFloat32Value; const Name: String = ''; const InitializeTo: TAoFloat32 = nil); overload;
procedure FinalValue(var Value: TAoFloat32Value); overload;

{-------------------------------------------------------------------------------
    TAoFloat64Value
-------------------------------------------------------------------------------}
type
  TAoFloat64 = TMVAoFloat64;

  TAoFloat64Value = class(TMVAoFloat64Value);

  TArrayOfFloat64 = TAoFloat64;
  TAoDouble       = TAoFloat64;
  TArrayOfDouble  = TAoFloat64;
  TAoFloat        = TAoFloat64;
  TArrayOfFloat   = TAoFloat64;
  TAoReal         = TAoFloat64;
  TArrayOfReal    = TAoFloat64;

  TArrayOfFloat64Value = TAoFloat64Value;
  TAoDoubleValue       = TAoFloat64Value;
  TArrayOfDoubleValue  = TAoFloat64Value;
  TAoFloatValue        = TAoFloat64Value;
  TArrayOfFloatValue   = TAoFloat64Value;
  TAoRealValue         = TAoFloat64Value;
  TArrayOfRealValue    = TAoFloat64Value;

procedure InitValue(out Value: TAoFloat64Value; const Name: String = ''; const InitializeTo: TAoFloat64 = nil); overload;
procedure FinalValue(var Value: TAoFloat64Value); overload;

{-------------------------------------------------------------------------------
    TAoDateTimeValue
-------------------------------------------------------------------------------}
type
  TAoDateTime = TMVAoDateTime;

  TAoDateTimeValue = class(TMVAoDateTimeValue);

  TArrayOfDateTime = TAoDateTime;
  TAoDate          = TAoDateTime;
  TArrayOfDate     = TAoDateTime;
  TAoTime          = TAoDateTime;
  TArrayOfTime     = TAoDateTime;

  TArrayOfDateTimeValue = TAoDateTimeValue;
  TAoDateValue          = TAoDateTimeValue;
  TArrayOfDateValue     = TAoDateTimeValue;
  TAoTimeValue          = TAoDateTimeValue;
  TArrayOfTimeValue     = TAoDateTimeValue;

procedure InitValue(out Value: TAoDateTimeValue; const Name: String = ''; const InitializeTo: TAoDateTime = nil); overload;
procedure FinalValue(var Value: TAoDateTimeValue); overload;

{-------------------------------------------------------------------------------
    TAoCurrencyValue
-------------------------------------------------------------------------------}
type
  TAoCurrency = TMVAoCurrency;

  TAoCurrencyValue = class(TMVAoCurrencyValue);

  TArrayOfCurrency = TAoCurrency;

  TArrayOfCurrencyValue = TAoCurrencyValue;

procedure InitValue(out Value: TAoCurrencyValue; const Name: String = ''; const InitializeTo: TAoCurrency = nil); overload;
procedure FinalValue(var Value: TAoCurrencyValue); overload;

{-------------------------------------------------------------------------------
    TAoAnsiCharValue
-------------------------------------------------------------------------------}
type
  TAoAnsiChar = TMVAoAnsiChar;

  TAoAnsiCharValue = class(TMVAoAnsiCharValue);

  TArrayOfAnsiChar = TAoAnsiChar;

  TArrayOfAnsiCharValue = TAoAnsiCharValue;

procedure InitValue(out Value: TAoAnsiCharValue; const Name: String = ''; const InitializeTo: TAoAnsiChar = nil); overload;
procedure FinalValue(var Value: TAoAnsiCharValue); overload;

{-------------------------------------------------------------------------------
    TAoUTF8CharValue
-------------------------------------------------------------------------------}
type
  TAoUTF8Char = TMVAoUTF8Char;

  TAoUTF8CharValue = class(TMVAoUTF8CharValue);

  TArrayOfUTF8Char = TAoUTF8Char;

  TArrayOfUTF8CharValue = TAoUTF8CharValue;

procedure InitValue(out Value: TAoUTF8CharValue; const Name: String = ''; const InitializeTo: TAoUTF8Char = nil); overload;
procedure FinalValue(var Value: TAoUTF8CharValue); overload;

{-------------------------------------------------------------------------------
    TAoWideCharValue
-------------------------------------------------------------------------------}
type
  TAoWideChar = TMVAoWideChar;

  TAoWideCharValue = class(TMVAoWideCharValue);

  TArrayOfWideChar = TAoWideChar;

  TArrayOfWideCharValue = TAoWideCharValue;

procedure InitValue(out Value: TAoWideCharValue; const Name: String = ''; const InitializeTo: TAoWideChar = nil); overload;
procedure FinalValue(var Value: TAoWideCharValue); overload;

{-------------------------------------------------------------------------------
    TAoUnicodeCharValue
-------------------------------------------------------------------------------}
type
  TAoUnicodeChar = TMVAoUnicodeChar;

  TAoUnicodeCharValue = class(TMVAoUnicodeCharValue);

  TArrayOfUnicodeChar = TAoUnicodeChar;

  TArrayOfUnicodeCharValue = TAoUnicodeCharValue;

procedure InitValue(out Value: TAoUnicodeCharValue; const Name: String = ''; const InitializeTo: TAoUnicodeChar = nil); overload;
procedure FinalValue(var Value: TAoUnicodeCharValue); overload;

{-------------------------------------------------------------------------------
    TAoCharValue
-------------------------------------------------------------------------------}
type
  TAoChar = TMVAoChar;

  TAoCharValue = class(TMVAoCharValue);

  TArrayOfChar = TAoChar;

  TArrayOfCharValue = TAoCharValue;

procedure InitValue(out Value: TAoCharValue; const Name: String = ''; const InitializeTo: TAoChar = nil); overload;
procedure FinalValue(var Value: TAoCharValue); overload;

{-------------------------------------------------------------------------------
    TAoShortStringValue
-------------------------------------------------------------------------------}
type
  TAoShortString = TMVAoShortString;

  TAoShortStringValue = class(TMVAoShortStringValue);

  TArrayOfShortString = TAoShortString;

  TArrayOfShortStringValue = TAoShortStringValue;

procedure InitValue(out Value: TAoShortStringValue; const Name: String = ''; const InitializeTo: TAoShortString = nil); overload;
procedure FinalValue(var Value: TAoShortStringValue); overload;

{-------------------------------------------------------------------------------
    TAoAnsiStringValue
-------------------------------------------------------------------------------}
type
  TAoAnsiString = TMVAoAnsiString;

  TAoAnsiStringValue = class(TMVAoAnsiStringValue);

  TArrayOfAnsiString = TAoAnsiString;

  TArrayOfAnsiStringValue = TAoAnsiStringValue;

procedure InitValue(out Value: TAoAnsiStringValue; const Name: String = ''; const InitializeTo: TAoAnsiString = nil); overload;
procedure FinalValue(var Value: TAoAnsiStringValue); overload;

{-------------------------------------------------------------------------------
    TAoUTF8StringValue
-------------------------------------------------------------------------------}
type
  TAoUTF8String = TMVAoUTF8String;

  TAoUTF8StringValue = class(TMVAoUTF8StringValue);

  TArrayOfUTF8String = TAoUTF8String;

  TArrayOfUTF8StringValue = TAoUTF8StringValue;

procedure InitValue(out Value: TAoUTF8StringValue; const Name: String = ''; const InitializeTo: TAoUTF8String = nil); overload;
procedure FinalValue(var Value: TAoUTF8StringValue); overload;

{-------------------------------------------------------------------------------
    TAoWideStringValue
-------------------------------------------------------------------------------}
type
  TAoWideString = TMVAoWideString;

  TAoWideStringValue = class(TMVAoWideStringValue);

  TArrayOfWideString = TAoWideString;

  TArrayOfWideStringValue = TAoWideStringValue;

procedure InitValue(out Value: TAoWideStringValue; const Name: String = ''; const InitializeTo: TAoWideString = nil); overload;
procedure FinalValue(var Value: TAoWideStringValue); overload;

{-------------------------------------------------------------------------------
    TAoUnicodeStringValue
-------------------------------------------------------------------------------}
type
  TAoUnicodeString = TMVAoUnicodeString;

  TAoUnicodeStringValue = class(TMVAoUnicodeStringValue);

  TArrayOfUnicodeString = TAoUnicodeString;

  TArrayOfUnicodeStringValue = TAoUnicodeStringValue;

procedure InitValue(out Value: TAoUnicodeStringValue; const Name: String = ''; const InitializeTo: TAoUnicodeString = nil); overload;
procedure FinalValue(var Value: TAoUnicodeStringValue); overload;

{-------------------------------------------------------------------------------
    TAoStringValue
-------------------------------------------------------------------------------}
type
  TAoString = TMVAoString;

  TAoStringValue = class(TMVAoStringValue);

  TArrayOfString = TAoString;

  TArrayOfStringValue = TAoStringValue;

procedure InitValue(out Value: TAoStringValue; const Name: String = ''; const InitializeTo: TAoString = nil); overload;
procedure FinalValue(var Value: TAoStringValue); overload;

{-------------------------------------------------------------------------------
    TAoPointerValue
-------------------------------------------------------------------------------}
type
  TAoPointer = TMVAoPointer;

  TAoPointerValue = class(TMVAoPointerValue);

  TArrayOfPointer = TAoPointer;

  TArrayOfPointerValue = TAoPointerValue;

procedure InitValue(out Value: TAoPointerValue; const Name: String = ''; const InitializeTo: TAoPointer = nil); overload;
procedure FinalValue(var Value: TAoPointerValue); overload;

{-------------------------------------------------------------------------------
    TAoObjectValue
-------------------------------------------------------------------------------}
type
  TAoObject = TMVAoObject;

  TAoObjectValue = class(TMVAoObjectValue);

  TArrayOfObject = TAoObject;

  TArrayOfObjectValue = TAoObjectValue;

procedure InitValue(out Value: TAoObjectValue; const Name: String = ''; const InitializeTo: TAoObject = nil); overload;
procedure FinalValue(var Value: TAoObjectValue); overload;

{-------------------------------------------------------------------------------
    TAoGUIDValue
-------------------------------------------------------------------------------}
type
  TAoGUID = TMVAoGUID;

  TAoGUIDValue = class(TMVAoGUIDValue);

  TArrayOfGUID = TAoGUID;

  TArrayOfGUIDValue = TAoGUIDValue;  

procedure InitValue(out Value: TAoGUIDValue; const Name: String = ''; const InitializeTo: TAoGUID = nil); overload;
procedure FinalValue(var Value: TAoGUIDValue); overload;


{===============================================================================
--------------------------------------------------------------------------------
                                 TValuesManager
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TValuesManager - class declaration
===============================================================================}
type
  TValuesManager = class(TMVValuesManagerBase)
  public
    Function NewValue(ValueType: TManagedValueType; const Name: String = ''): TManagedValue; overload; virtual;
    Function NewValue(ValueClass: TManagedValueClass; const Name: String = ''): TManagedValue; overload; virtual;
    // primitives
    Function NewBooleanValue(const Name: String = ''; InitTo: Boolean = False): TBooleanValue; virtual;
    Function NewInt8Value(const Name: String = ''; InitTo: Int8 = 0): TInt8Value; virtual;
    Function NewUInt8Value(const Name: String = ''; InitTo: UInt8 = 0): TUInt8Value; virtual;
    Function NewInt16Value(const Name: String = ''; InitTo: Int16 = 0): TInt16Value; virtual;
    Function NewUInt16Value(const Name: String = ''; InitTo: UInt16 = 0): TUInt16Value; virtual;
    Function NewInt32Value(const Name: String = ''; InitTo: Int32 = 0): TInt32Value; virtual;
    Function NewUInt32Value(const Name: String = ''; InitTo: UInt32 = 0): TUInt32Value; virtual;
    Function NewInt64Value(const Name: String = ''; InitTo: Int64 = 0): TInt64Value; virtual;
    Function NewUInt64Value(const Name: String = ''; InitTo: UInt64 = 0): TUInt64Value; virtual;
    Function NewFloat32Value(const Name: String = ''; InitTo: Float32 = 0.0): TFloat32Value; virtual;
    Function NewFloat64Value(const Name: String = ''; InitTo: Float64 = 0.0): TFloat64Value; virtual;
    Function NewDateTimeValue(const Name: String = ''; InitTo: TDateTime = 0.0): TDateTimeValue; virtual;
    Function NewCurrencyValue(const Name: String = ''; InitTo: Currency = 0.0): TCurrencyValue; virtual;
    Function NewAnsiCharValue(const Name: String = ''; InitTo: AnsiChar = #0): TAnsiCharValue; virtual;
    Function NewUTF8CharValue(const Name: String = ''; InitTo: UTF8Char = #0): TUTF8CharValue; virtual;
    Function NewWideCharValue(const Name: String = ''; InitTo: WideChar = #0): TWideCharValue; virtual;
    Function NewUnicodeCharValue(const Name: String = ''; InitTo: UnicodeChar = #0): TUnicodeCharValue; virtual;
    Function NewCharValue(const Name: String = ''; InitTo: Char = #0): TCharValue; virtual;
    Function NewShortStringValue(const Name: String = ''; const InitTo: ShortString = ''): TShortStringValue; virtual;
    Function NewAnsiStringValue(const Name: String = ''; const InitTo: AnsiString = ''): TAnsiStringValue; virtual;
    Function NewUTF8StringValue(const Name: String = ''; const InitTo: UTF8String = ''): TUTF8StringValue; virtual;
    Function NewWideStringValue(const Name: String = ''; const InitTo: WideString = ''): TWideStringValue; virtual;
    Function NewUnicodeStringValue(const Name: String = ''; const InitTo: UnicodeString = ''): TUnicodeStringValue; virtual;
    Function NewStringValue(const Name: String = ''; const InitTo: String = ''): TStringValue; virtual;
    Function NewPointerValue(const Name: String = ''; InitTo: Pointer = nil): TPointerValue; virtual;
    Function NewObjectValue(const Name: String = ''; InitTo: TObject = nil): TObjectValue; virtual;
    Function NewGUIDValue(const Name: String; InitTo: TGUID): TGUIDValue; overload; virtual;
    Function NewGUIDValue(const Name: String = ''): TGUIDValue; overload; virtual;
    // arrays
    Function NewAoBooleanValue(const Name: String = ''; const InitTo: TAoBoolean = nil): TAoBooleanValue; virtual;
    Function NewAoInt8Value(const Name: String = ''; const InitTo: TAoInt8 = nil): TAoInt8Value; virtual;
    Function NewAoUInt8Value(const Name: String = ''; const InitTo: TAoUInt8 = nil): TAoUInt8Value; virtual;
    Function NewAoInt16Value(const Name: String = ''; const InitTo: TAoInt16 = nil): TAoInt16Value; virtual;
    Function NewAoUInt16Value(const Name: String = ''; const InitTo: TAoUInt16 = nil): TAoUInt16Value; virtual;
    Function NewAoInt32Value(const Name: String = ''; const InitTo: TAoInt32 = nil): TAoInt32Value; virtual;
    Function NewAoUInt32Value(const Name: String = ''; const InitTo: TAoUInt32 = nil): TAoUInt32Value; virtual;
    Function NewAoInt64Value(const Name: String = ''; const InitTo: TAoInt64 = nil): TAoInt64Value; virtual;
    Function NewAoUInt64Value(const Name: String = ''; const InitTo: TAoUInt64 = nil): TAoUInt64Value; virtual;
    Function NewAoFloat32Value(const Name: String = ''; const InitTo: TAoFloat32 = nil): TAoFloat32Value; virtual;
    Function NewAoFloat64Value(const Name: String = ''; const InitTo: TAoFloat64 = nil): TAoFloat64Value; virtual;
    Function NewAoDateTimeValue(const Name: String = ''; const InitTo: TAoDateTime = nil): TAoDateTimeValue; virtual;
    Function NewAoCurrencyValue(const Name: String = ''; const InitTo: TAoCurrency = nil): TAoCurrencyValue; virtual;
    Function NewAoAnsiCharValue(const Name: String = ''; const InitTo: TAoAnsiChar = nil): TAoAnsiCharValue; virtual;
    Function NewAoUTF8CharValue(const Name: String = ''; const InitTo: TAoUTF8Char = nil): TAoUTF8CharValue; virtual;
    Function NewAoWideCharValue(const Name: String = ''; const InitTo: TAoWideChar = nil): TAoWideCharValue; virtual;
    Function NewAoUnicodeCharValue(const Name: String = ''; const InitTo: TAoUnicodeChar = nil): TAoUnicodeCharValue; virtual;
    Function NewAoCharValue(const Name: String = ''; const InitTo: TAoChar = nil): TAoCharValue; virtual;
    Function NewAoShortStringValue(const Name: String = ''; const InitTo: TAoShortString = nil): TAoShortStringValue; virtual;
    Function NewAoAnsiStringValue(const Name: String = ''; const InitTo: TAoAnsiString = nil): TAoAnsiStringValue; virtual;
    Function NewAoUTF8StringValue(const Name: String = ''; const InitTo: TAoUTF8String = nil): TAoUTF8StringValue; virtual;
    Function NewAoWideStringValue(const Name: String = ''; const InitTo: TAoWideString = nil): TAoWideStringValue; virtual;
    Function NewAoUnicodeStringValue(const Name: String = ''; const InitTo: TAoUnicodeString = nil): TAoUnicodeStringValue; virtual;
    Function NewAoStringValue(const Name: String = ''; const InitTo: TAoString = nil): TAoStringValue; virtual;
    Function NewAoPointerValue(const Name: String = ''; const InitTo: TAoPointer = nil): TAoPointerValue; virtual;
    Function NewAoObjectValue(const Name: String = ''; const InitTo: TAoObject = nil): TAoObjectValue; virtual;
    Function NewAoGUIDValue(const Name: String = ''; const InitTo: TAoGUID = nil): TAoGUIDValue; virtual;
  end;

{===============================================================================
--------------------------------------------------------------------------------
                                 Global manager
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    Global manager - declaration
===============================================================================}

type
  TValueArray = array of TManagedValue;

Function FindManagedValue(const Name: String; out Value: TManagedValue): Boolean;
Function FindManagedValues(const Name: String; out Values: TValueArray): Integer;

Function ManagedValuesCount: Integer;
procedure ManagedValuesClearAbandoned;  // removes all values that are not locally managed
procedure ManagedValuesClear;           // Use with extreme caution!

implementation

uses
  SysUtils;

{===============================================================================
--------------------------------------------------------------------------------
                         Aliases nad utility functions
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    Aliases nad utility functions - implementation
===============================================================================}
{-------------------------------------------------------------------------------
    Common types
-------------------------------------------------------------------------------}

Function ClassFromValueType(ValueType: TManagedValueType): TManagedValueClass;
begin
case ValueType of
  // primitive values
  mvtBoolean:         Result := TBooleanValue;
  mvtInt8:            Result := TInt8Value;
  mvtUInt8:           Result := TUInt8Value;
  mvtInt16:           Result := TInt16Value;
  mvtUInt16:          Result := TUInt16Value;
  mvtInt32:           Result := TInt32Value;
  mvtUInt32:          Result := TUInt32Value;
  mvtInt64:           Result := TInt64Value;
  mvtUInt64:          Result := TUInt64Value;
  mvtFloat32:         Result := TFloat32Value;
  mvtFloat64:         Result := TFloat64Value;
  mvtDateTime:        Result := TDateTimeValue;
  mvtCurrency:        Result := TCurrencyValue;
  mvtAnsiChar:        Result := TAnsiCharValue;
  mvtUTF8Char:        Result := TUTF8CharValue;
  mvtWideChar:        Result := TWideCharValue;
  mvtUnicodeChar:     Result := TUnicodeCharValue;
  mvtChar:            Result := TCharValue;
  mvtShortString:     Result := TShortStringValue;
  mvtAnsiString:      Result := TAnsiStringValue;
  mvtUTF8String:      Result := TUTF8StringValue;
  mvtWideString:      Result := TWideStringValue;
  mvtUnicodeString:   Result := TUnicodeStringValue;
  mvtString:          Result := TStringValue;
  mvtPointer:         Result := TPointerValue;
  mvtObject:          Result := TObjectValue;
  mvtGUID:            Result := TGUIDValue;
  // array values
  mvtAoBoolean:       Result := TAoBooleanValue;
  mvtAoInt8:          Result := TAoInt8Value;
  mvtAoUInt8:         Result := TAoUInt8Value;
  mvtAoInt16:         Result := TAoInt16Value;
  mvtAoUInt16:        Result := TAoUInt16Value;
  mvtAoInt32:         Result := TAoInt32Value;
  mvtAoUInt32:        Result := TAoUInt32Value;
  mvtAoInt64:         Result := TAoInt64Value;
  mvtAoUInt64:        Result := TAoUInt64Value;
  mvtAoFloat32:       Result := TAoFloat32Value;
  mvtAoFloat64:       Result := TAoFloat64Value;
  mvtAoDateTime:      Result := TAoDateTimeValue;
  mvtAoCurrency:      Result := TAoCurrencyValue;
  mvtAoAnsiChar:      Result := TAoAnsiCharValue;
  mvtAoUTF8Char:      Result := TAoUTF8CharValue;
  mvtAoWideChar:      Result := TAoWideCharValue;
  mvtAoUnicodeChar:   Result := TAoUnicodeCharValue;
  mvtAoChar:          Result := TAoCharValue;
  mvtAoShortString:   Result := TAoShortStringValue;
  mvtAoAnsiString:    Result := TAoAnsiStringValue;
  mvtAoUTF8String:    Result := TAoUTF8StringValue;
  mvtAoWideString:    Result := TAoWideStringValue;
  mvtAoUnicodeString: Result := TAoUnicodeStringValue;
  mvtAoString:        Result := TAoStringValue;
  mvtAoPointer:       Result := TAoPointerValue;
  mvtAoObject:        Result := TAoObjectValue;
  mvtAoGUID:          Result := TAoGUIDValue;

else
  raise EMVInvalidValue.CreateFmt('ClassFromValueType: Unknown value type (%d).',[Ord(ValueType)]);
end;
end;

//------------------------------------------------------------------------------

Function CreateValue(ValueType: TManagedValueType; const Name: String = ''): TManagedValue;
begin
Result := ClassFromValueType(ValueType).Create(Name);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function CreateValue(ValueClass: TManagedValueClass; const Name: String = ''): TManagedValue;
begin
Result := ValueClass.Create(Name);
end;

//------------------------------------------------------------------------------

procedure FreeValue(var Value: TManagedValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TBooleanValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TBooleanValue; const Name: String = ''; InitializeTo: Boolean = False);
begin
Value := TBooleanValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TBooleanValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TInt8Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TInt8Value; const Name: String = ''; InitializeTo: Int8 = 0);
begin
Value := TInt8Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TInt8Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TUInt8Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TUInt8Value; const Name: String = ''; InitializeTo: UInt8 = 0);
begin
Value := TUInt8Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUInt8Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TInt16Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TInt16Value; const Name: String = ''; InitializeTo: Int16 = 0);
begin
Value := TInt16Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TInt16Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TUInt16Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TUInt16Value; const Name: String = ''; InitializeTo: UInt16 = 0);
begin
Value := TUInt16Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUInt16Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TInt32Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TInt32Value; const Name: String = ''; InitializeTo: Int32 = 0);
begin
Value := TInt32Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TInt32Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TUInt32Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TUInt32Value; const Name: String = ''; InitializeTo: UInt32 = 0);
begin
Value := TUInt32Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUInt32Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TInt64Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TInt64Value; const Name: String = ''; InitializeTo: Int64 = 0);
begin
Value := TInt64Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TInt64Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TUInt64Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TUInt64Value; const Name: String = ''; InitializeTo: UInt64 = 0);
begin
Value := TUInt64Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUInt64Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TFloat32Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TFloat32Value; const Name: String = ''; InitializeTo: Float32 = 0.0);
begin
Value := TFloat32Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TFloat32Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TFloat64Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TFloat64Value; const Name: String = ''; InitializeTo: Float64 = 0.0);
begin
Value := TFloat64Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TFloat64Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TDateTimeValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TDateTimeValue; const Name: String = ''; InitializeTo: TDateTime = 0.0);
begin
Value := TDateTimeValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TDateTimeValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TCurrencyValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TCurrencyValue; const Name: String = ''; InitializeTo: Currency = 0.0);
begin
Value := TCurrencyValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TCurrencyValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAnsiCharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAnsiCharValue; const Name: String = ''; InitializeTo: AnsiChar = #0);
begin
Value := TAnsiCharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAnsiCharValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TUTF8CharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TUTF8CharValue; const Name: String = ''; InitializeTo: UTF8Char = #0);
begin
Value := TUTF8CharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUTF8CharValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TWideCharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TWideCharValue; const Name: String = ''; InitializeTo: WideChar = #0);
begin
Value := TWideCharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TWideCharValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TUnicodeCharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TUnicodeCharValue; const Name: String = ''; InitializeTo: UnicodeChar = #0);
begin
Value := TUnicodeCharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUnicodeCharValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TCharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TCharValue; const Name: String = ''; InitializeTo: Char = #0);
begin
Value := TCharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TCharValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TShortStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TShortStringValue; const Name: String = ''; const InitializeTo: ShortString = '');
begin
Value := TShortStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TShortStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAnsiStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAnsiStringValue; const Name: String = ''; const InitializeTo: AnsiString = '');
begin
Value := TAnsiStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAnsiStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TUTF8StringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TUTF8StringValue; const Name: String = ''; const InitializeTo: UTF8String = '');
begin
Value := TUTF8StringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUTF8StringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TWideStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TWideStringValue; const Name: String = ''; const InitializeTo: WideString = '');
begin
Value := TWideStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TWideStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TUnicodeStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TUnicodeStringValue; const Name: String = ''; const InitializeTo: UnicodeString = '');
begin
Value := TUnicodeStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUnicodeStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TStringValue; const Name: String = ''; const InitializeTo: String = '');
begin
Value := TStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TPointerValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TPointerValue; const Name: String = ''; InitializeTo: Pointer = nil);
begin
Value := TPointerValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TPointerValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TObjectValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TObjectValue; const Name: String = ''; InitializeTo: TObject = nil);
begin
Value := TObjectValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TObjectValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TGUIDValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TGUIDValue; const Name: String; InitializeTo: TGUID);
begin
Value := TGUIDValue.CreateAndInit(Name,InitializeTo);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure InitValue(out Value: TGUIDValue; const Name: String = '');
begin
InitValue(Value,Name,StringToGUID('{00000000-0000-0000-0000-000000000000}'));
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TGUIDValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoBooleanValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoBooleanValue; const Name: String = ''; const InitializeTo: TAoBoolean = nil);
begin
Value := TAoBooleanValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoBooleanValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoInt8Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoInt8Value; const Name: String = ''; const InitializeTo: TAoInt8 = nil);
begin
Value := TAoInt8Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoInt8Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoUInt8Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoUInt8Value; const Name: String = ''; const InitializeTo: TAoUInt8 = nil);
begin
Value := TAoUInt8Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoUInt8Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoInt16Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoInt16Value; const Name: String = ''; const InitializeTo: TAoInt16 = nil);
begin
Value := TAoInt16Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoInt16Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoUInt16Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoUInt16Value; const Name: String = ''; const InitializeTo: TAoUInt16 = nil);
begin
Value := TAoUInt16Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoUInt16Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoInt32Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoInt32Value; const Name: String = ''; const InitializeTo: TAoInt32 = nil);
begin
Value := TAoInt32Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoInt32Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoUInt32Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoUInt32Value; const Name: String = ''; const InitializeTo: TAoUInt32 = nil);
begin
Value := TAoUInt32Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoUInt32Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoInt64Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoInt64Value; const Name: String = ''; const InitializeTo: TAoInt64 = nil);
begin
Value := TAoInt64Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoInt64Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoUInt64Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoUInt64Value; const Name: String = ''; const InitializeTo: TAoUInt64 = nil);
begin
Value := TAoUInt64Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoUInt64Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoFloat32Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoFloat32Value; const Name: String = ''; const InitializeTo: TAoFloat32 = nil);
begin
Value := TAoFloat32Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoFloat32Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoFloat64Value
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoFloat64Value; const Name: String = ''; const InitializeTo: TAoFloat64 = nil);
begin
Value := TAoFloat64Value.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoFloat64Value);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoDateTimeValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoDateTimeValue; const Name: String = ''; const InitializeTo: TAoDateTime = nil);
begin
Value := TAoDateTimeValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoDateTimeValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoCurrencyValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoCurrencyValue; const Name: String = ''; const InitializeTo: TAoCurrency = nil);
begin
Value := TAoCurrencyValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoCurrencyValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoAnsiCharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoAnsiCharValue; const Name: String = ''; const InitializeTo: TAoAnsiChar = nil);
begin
Value := TAoAnsiCharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoAnsiCharValue); 
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoUTF8CharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoUTF8CharValue; const Name: String = ''; const InitializeTo: TAoUTF8Char = nil);
begin
Value := TAoUTF8CharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoUTF8CharValue); 
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoWideCharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoWideCharValue; const Name: String = ''; const InitializeTo: TAoWideChar = nil);
begin
Value := TAoWideCharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoWideCharValue); 
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoUnicodeCharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoUnicodeCharValue; const Name: String = ''; const InitializeTo: TAoUnicodeChar = nil);
begin
Value := TAoUnicodeCharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoUnicodeCharValue); 
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoCharValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoCharValue; const Name: String = ''; const InitializeTo: TAoChar = nil);
begin
Value := TAoCharValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoCharValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoShortStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoShortStringValue; const Name: String = ''; const InitializeTo: TAoShortString = nil);
begin
Value := TAoShortStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoShortStringValue); 
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoAnsiStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoAnsiStringValue; const Name: String = ''; const InitializeTo: TAoAnsiString = nil);
begin
Value := TAoAnsiStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoAnsiStringValue); 
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoUTF8StringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoUTF8StringValue; const Name: String = ''; const InitializeTo: TAoUTF8String = nil);
begin
Value := TAoUTF8StringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoUTF8StringValue); 
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoWideStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoWideStringValue; const Name: String = ''; const InitializeTo: TAoWideString = nil);
begin
Value := TAoWideStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoWideStringValue); 
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoUnicodeStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoUnicodeStringValue; const Name: String = ''; const InitializeTo: TAoUnicodeString = nil);
begin
Value := TAoUnicodeStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoUnicodeStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoStringValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoStringValue; const Name: String = ''; const InitializeTo: TAoString = nil);
begin
Value := TAoStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoStringValue); overload;
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoPointerValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoPointerValue; const Name: String = ''; const InitializeTo: TAoPointer = nil);
begin
Value := TAoPointerValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoPointerValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoObjectValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoObjectValue; const Name: String = ''; const InitializeTo: TAoObject = nil);
begin
Value := TAoObjectValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoObjectValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{-------------------------------------------------------------------------------
    TAoGUIDValue
-------------------------------------------------------------------------------}

procedure InitValue(out Value: TAoGUIDValue; const Name: String = ''; const InitializeTo: TAoGUID = nil);
begin
Value := TAoGUIDValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAoGUIDValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;


{===============================================================================
--------------------------------------------------------------------------------
                                 TValuesManager
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TValuesManager - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TValuesManager - public methods
-------------------------------------------------------------------------------}

Function TValuesManager.NewValue(ValueType: TManagedValueType; const Name: String = ''): TManagedValue;
begin
Result := CreateValue(ValueType,Name);
Add(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TValuesManager.NewValue(ValueClass: TManagedValueClass; const Name: String = ''): TManagedValue;
begin
Result := ValueClass.Create(Name);
Add(Result);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewBooleanValue(const Name: String = ''; InitTo: Boolean = False): TBooleanValue;
begin
Result := TBooleanValue(NewValue(mvtBoolean,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewInt8Value(const Name: String = ''; InitTo: Int8 = 0): TInt8Value;
begin
Result := TInt8Value(NewValue(mvtInt8,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUInt8Value(const Name: String = ''; InitTo: UInt8 = 0): TUInt8Value;
begin
Result := TUInt8Value(NewValue(mvtUInt8,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewInt16Value(const Name: String = ''; InitTo: Int16 = 0): TInt16Value;
begin
Result := TInt16Value(NewValue(mvtInt16,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUInt16Value(const Name: String = ''; InitTo: UInt16 = 0): TUInt16Value;
begin
Result := TUInt16Value(NewValue(mvtUInt16,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewInt32Value(const Name: String = ''; InitTo: Int32 = 0): TInt32Value;
begin
Result := TInt32Value(NewValue(mvtInt32,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUInt32Value(const Name: String = ''; InitTo: UInt32 = 0): TUInt32Value;
begin
Result := TUInt32Value(NewValue(mvtUInt32,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewInt64Value(const Name: String = ''; InitTo: Int64 = 0): TInt64Value;
begin
Result := TInt64Value(NewValue(mvtInt64,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUInt64Value(const Name: String = ''; InitTo: UInt64 = 0): TUInt64Value;
begin
Result := TUInt64Value(NewValue(mvtUInt64,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewFloat32Value(const Name: String = ''; InitTo: Float32 = 0.0): TFloat32Value;
begin
Result := TFloat32Value(NewValue(mvtFloat32,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewFloat64Value(const Name: String = ''; InitTo: Float64 = 0.0): TFloat64Value;
begin
Result := TFloat64Value(NewValue(mvtFloat64,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewDateTimeValue(const Name: String = ''; InitTo: TDateTime = 0.0): TDateTimeValue;
begin
Result := TDateTimeValue(NewValue(mvtDateTime,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewCurrencyValue(const Name: String = ''; InitTo: Currency = 0.0): TCurrencyValue;
begin
Result := TCurrencyValue(NewValue(mvtCurrency,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAnsiCharValue(const Name: String = ''; InitTo: AnsiChar = #0): TAnsiCharValue;
begin
Result := TAnsiCharValue(NewValue(mvtAnsiChar,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUTF8CharValue(const Name: String = ''; InitTo: UTF8Char = #0): TUTF8CharValue;
begin
Result := TUTF8CharValue(NewValue(mvtUTF8Char,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewWideCharValue(const Name: String = ''; InitTo: WideChar = #0): TWideCharValue;
begin
Result := TWideCharValue(NewValue(mvtWideChar,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUnicodeCharValue(const Name: String = ''; InitTo: UnicodeChar = #0): TUnicodeCharValue;
begin
Result := TUnicodeCharValue(NewValue(mvtUnicodeChar,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewCharValue(const Name: String = ''; InitTo: Char = #0): TCharValue;
begin
Result := TCharValue(NewValue(mvtChar,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewShortStringValue(const Name: String = ''; const InitTo: ShortString = ''): TShortStringValue;
begin
Result := TShortStringValue(NewValue(mvtShortString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAnsiStringValue(const Name: String = ''; const InitTo: AnsiString = ''): TAnsiStringValue;
begin
Result := TAnsiStringValue(NewValue(mvtAnsiString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUTF8StringValue(const Name: String = ''; const InitTo: UTF8String = ''): TUTF8StringValue;
begin
Result := TUTF8StringValue(NewValue(mvtUTF8String,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewWideStringValue(const Name: String = ''; const InitTo: WideString = ''): TWideStringValue;
begin
Result := TWideStringValue(NewValue(mvtWideString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUnicodeStringValue(const Name: String = ''; const InitTo: UnicodeString = ''): TUnicodeStringValue;
begin
Result := TUnicodeStringValue(NewValue(mvtUnicodeString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewStringValue(const Name: String = ''; const InitTo: String = ''): TStringValue;
begin
Result := TStringValue(NewValue(mvtString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewPointerValue(const Name: String = ''; InitTo: Pointer = nil): TPointerValue;
begin
Result := TPointerValue(NewValue(mvtPointer,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewObjectValue(const Name: String = ''; InitTo: TObject = nil): TObjectValue;
begin
Result := TObjectValue(NewValue(mvtObject,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewGUIDValue(const Name: String; InitTo: TGUID): TGUIDValue;
begin
Result := TGUIDValue(NewValue(mvtGUID,Name));
Result.Initialize(InitTo,False);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TValuesManager.NewGUIDValue(const Name: String = ''): TGUIDValue;
begin
Result := NewGUIDValue(Name,StringToGUID('{00000000-0000-0000-0000-000000000000}'));
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoBooleanValue(const Name: String = ''; const InitTo: TAoBoolean = nil): TAoBooleanValue;
begin
Result := TAoBooleanValue(NewValue(mvtAoBoolean,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoInt8Value(const Name: String = ''; const InitTo: TAoInt8 = nil): TAoInt8Value;
begin
Result := TAoInt8Value(NewValue(mvtAoInt8,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoUInt8Value(const Name: String = ''; const InitTo: TAoUInt8 = nil): TAoUInt8Value;
begin
Result := TAoUInt8Value(NewValue(mvtAoUInt8,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoInt16Value(const Name: String = ''; const InitTo: TAoInt16 = nil): TAoInt16Value;
begin
Result := TAoInt16Value(NewValue(mvtAoInt16,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoUInt16Value(const Name: String = ''; const InitTo: TAoUInt16 = nil): TAoUInt16Value;
begin
Result := TAoUInt16Value(NewValue(mvtAoUInt16,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoInt32Value(const Name: String = ''; const InitTo: TAoInt32 = nil): TAoInt32Value;
begin
Result := TAoInt32Value(NewValue(mvtAoInt32,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoUInt32Value(const Name: String = ''; const InitTo: TAoUInt32 = nil): TAoUInt32Value;
begin
Result := TAoUInt32Value(NewValue(mvtAoUInt32,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoInt64Value(const Name: String = ''; const InitTo: TAoInt64 = nil): TAoInt64Value;
begin
Result := TAoInt64Value(NewValue(mvtAoInt64,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoUInt64Value(const Name: String = ''; const InitTo: TAoUInt64 = nil): TAoUInt64Value;
begin
Result := TAoUInt64Value(NewValue(mvtAoUInt64,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoFloat32Value(const Name: String = ''; const InitTo: TAoFloat32 = nil): TAoFloat32Value;
begin
Result := TAoFloat32Value(NewValue(mvtAoFloat32,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoFloat64Value(const Name: String = ''; const InitTo: TAoFloat64 = nil): TAoFloat64Value;
begin
Result := TAoFloat64Value(NewValue(mvtAoFloat64,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoDateTimeValue(const Name: String = ''; const InitTo: TAoDateTime = nil): TAoDateTimeValue;
begin
Result := TAoDateTimeValue(NewValue(mvtAoDateTime,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoCurrencyValue(const Name: String = ''; const InitTo: TAoCurrency = nil): TAoCurrencyValue;
begin
Result := TAoCurrencyValue(NewValue(mvtAoCurrency,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoAnsiCharValue(const Name: String = ''; const InitTo: TAoAnsiChar = nil): TAoAnsiCharValue;
begin
Result := TAoAnsiCharValue(NewValue(mvtAoAnsiChar,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoUTF8CharValue(const Name: String = ''; const InitTo: TAoUTF8Char = nil): TAoUTF8CharValue;
begin
Result := TAoUTF8CharValue(NewValue(mvtAoUTF8Char,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoWideCharValue(const Name: String = ''; const InitTo: TAoWideChar = nil): TAoWideCharValue;
begin
Result := TAoWideCharValue(NewValue(mvtAoWideChar,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoUnicodeCharValue(const Name: String = ''; const InitTo: TAoUnicodeChar = nil): TAoUnicodeCharValue;
begin
Result := TAoUnicodeCharValue(NewValue(mvtAoUnicodeChar,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoCharValue(const Name: String = ''; const InitTo: TAoChar = nil): TAoCharValue;
begin
Result := TAoCharValue(NewValue(mvtAoChar,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoShortStringValue(const Name: String = ''; const InitTo: TAoShortString = nil): TAoShortStringValue;
begin
Result := TAoShortStringValue(NewValue(mvtAoShortString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------


Function TValuesManager.NewAoAnsiStringValue(const Name: String = ''; const InitTo: TAoAnsiString = nil): TAoAnsiStringValue;
begin
Result := TAoAnsiStringValue(NewValue(mvtAoAnsiString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------


Function TValuesManager.NewAoUTF8StringValue(const Name: String = ''; const InitTo: TAoUTF8String = nil): TAoUTF8StringValue;
begin
Result := TAoUTF8StringValue(NewValue(mvtAoUTF8String,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------


Function TValuesManager.NewAoWideStringValue(const Name: String = ''; const InitTo: TAoWideString = nil): TAoWideStringValue;
begin
Result := TAoWideStringValue(NewValue(mvtAoWideString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------


Function TValuesManager.NewAoUnicodeStringValue(const Name: String = ''; const InitTo: TAoUnicodeString = nil): TAoUnicodeStringValue;
begin
Result := TAoUnicodeStringValue(NewValue(mvtAoUnicodeString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoStringValue(const Name: String = ''; const InitTo: TAoString = nil): TAoStringValue;
begin
Result := TAoStringValue(NewValue(mvtAoString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoPointerValue(const Name: String = ''; const InitTo: TAoPointer = nil): TAoPointerValue;
begin
Result := TAoPointerValue(NewValue(mvtAoPointer,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoObjectValue(const Name: String = ''; const InitTo: TAoObject = nil): TAoObjectValue;
begin
Result := TAoObjectValue(NewValue(mvtAoObject,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAoGUIDValue(const Name: String = ''; const InitTo: TAoGUID = nil): TAoGUIDValue;
begin
Result := TAoGUIDValue(NewValue(mvtAoGUID,Name));
Result.Initialize(InitTo,False);
end;

{===============================================================================
--------------------------------------------------------------------------------
                                 Global manager
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    Global manager - implementation
===============================================================================}

Function FindManagedValue(const Name: String; out Value: TManagedValue): Boolean;
var
  GlobalManager:  TValuesManagerBase;
begin
Value := nil;
GlobalManager := GetGlobalValuesManager;
If Assigned(GlobalManager) then
  Result := GlobalManager.Find(Name,Value)
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function FindManagedValues(const Name: String; out Values: TValueArray): Integer;
var
  GlobalManager:  TValuesManagerBase;
  NewValue:       TManagedValue;
begin
Values := nil;
SetLength(Values,0);
GlobalManager := GetGlobalValuesManager;
If Assigned(GlobalManager) then
  begin
    If GlobalManager.FindFirst(Name,NewValue) then
      repeat
        SetLength(Values,Length(Values) + 1);
        Values[High(Values)] := NewValue;
      until not GlobalManager.FindNext(Name,NewValue);
    Result := Length(Values);
  end
else Result := 0;
end;

//------------------------------------------------------------------------------

Function ManagedValuesCount: Integer;
var
  GlobalManager:  TValuesManagerBase;
begin
GlobalManager := GetGlobalValuesManager;
If Assigned(GlobalManager) then
  Result := GlobalManager.Count
else
  Result := 0;
end;

//------------------------------------------------------------------------------

procedure ManagedValuesClearAbandoned;
var
  GlobalManager:  TValuesManagerBase;
  i:              Integer;
begin
GlobalManager := GetGlobalValuesManager;
If Assigned(GlobalManager) then
  For i := GlobalManager.HighIndex downto GlobalManager.LowIndex do
    If not GLobalManager[i].LocallyManaged then
      GlobalManager.Delete(i);
end;

//------------------------------------------------------------------------------

procedure ManagedValuesClear;
var
  GlobalManager:  TValuesManagerBase;
begin
GlobalManager := GetGlobalValuesManager;
If Assigned(GlobalManager) then
  GlobalManager.Clear;
end;


end.
