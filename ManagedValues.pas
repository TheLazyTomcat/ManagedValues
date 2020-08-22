unit ManagedValues;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  AuxTypes,
  ManagedValues_Base,
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
  ManagedValues_ObjectValue;

{===============================================================================
    TManagedValue
===============================================================================}

type
  TManagedValue = TMVManagedValueBase;

  TManagedValueClass = class of TManagedValue;

Function CreateValue(ValueClass: TManagedValueClass; const Name: String = ''): TManagedValue; 
procedure FreeValue(var Value: TManagedValue); overload;

{===============================================================================
    TBooleanValue
===============================================================================}
type
  TBooleanValue = class(TMVBooleanValue);
  
  TBoolValue = TBooleanValue;

procedure InitValue(out Value: TBooleanValue; const Name: String = ''; InitializeTo: Boolean = False); overload;
procedure FinalValue(var Value: TBooleanValue); overload;

{===============================================================================
    TInt8Value
===============================================================================}
type
  TInt8Value = class(TMVInt8Value);

  TShortIntValue = TInt8Value;

procedure InitValue(out Value: TInt8Value; const Name: String = ''; InitializeTo: Int8 = 0); overload;
procedure FinalValue(var Value: TInt8Value); overload;

{===============================================================================
    TUInt8Value
===============================================================================}
type
  TUInt8Value = class(TMVUInt8Value);

  TByteValue = TUInt8Value;

procedure InitValue(out Value: TUInt8Value; const Name: String = ''; InitializeTo: UInt8 = 0); overload;
procedure FinalValue(var Value: TUInt8Value); overload;

{===============================================================================
    TInt16Value
===============================================================================}
type
  TInt16Value = class(TMVInt16Value);

  TSmallIntValue = TInt16Value;
{$If SizeOf(Integer) = 2}
  TIntegerValue  = TInt16Value;
{$IFEND}

procedure InitValue(out Value: TInt16Value; const Name: String = ''; InitializeTo: Int16 = 0); overload;
procedure FinalValue(var Value: TInt16Value); overload;

{===============================================================================
    TUInt16Value
===============================================================================}
type
  TUInt16Value = class(TMVUInt16Value);

  TWordValue = TUInt16Value;

procedure InitValue(out Value: TUInt16Value; const Name: String = ''; InitializeTo: UInt16 = 0); overload;
procedure FinalValue(var Value: TUInt16Value); overload;

{===============================================================================
    TInt32Value
===============================================================================}
type
  TInt32Value = class(TMVInt32Value);

{$If SizeOf(Integer) = 4}
  TIntegerValue = TInt32Value;
{$IFEND}
{$If SizeOf(LongInt) = 4}
  TLongIntValue = TInt32Value;
{$IFEND}

procedure InitValue(out Value: TInt32Value; const Name: String = ''; InitializeTo: Int32 = 0); overload;
procedure FinalValue(var Value: TInt32Value); overload;

{===============================================================================
    TUInt32Value
===============================================================================}
type
  TUInt32Value = class(TMVUInt32Value);

{$If SizeOf(Cardinal) = 4}
  TCardinalValue = TUInt32Value;
{$IFEND}
{$If SizeOf(LongWord) = 4}
  TLongWordValue = TUInt32Value;
{$IFEND}
  TDWordValue    = TUInt32Value;

procedure InitValue(out Value: TUInt32Value; const Name: String = ''; InitializeTo: UInt32 = 0); overload;
procedure FinalValue(var Value: TUInt32Value); overload;

{===============================================================================
    TInt64Value
===============================================================================}
type
  TInt64Value = class(TMVInt64Value);

{$If SizeOf(Integer) = 8}
  TIntegerValue = TInt64Value;
{$IFEND}
{$If SizeOf(LongInt) = 8}
  TLongIntValue = TInt64Value;
{$IFEND}

procedure InitValue(out Value: TInt64Value; const Name: String = ''; InitializeTo: Int64 = 0); overload;
procedure FinalValue(var Value: TInt64Value); overload;

{===============================================================================
    TUInt64Value
===============================================================================}
type
  TUInt64Value = class(TMVUInt64Value);

  TQWordValue    = TUInt64Value;
  TQuadWordValue = TUInt64Value;
{$If SizeOf(Cardinal) = 8}
  TCardinalValue = TUInt64Value;
{$IFEND}
{$If SizeOf(LongWord) = 8}
  TLongWordValue = TUInt64Value;
{$IFEND}

procedure InitValue(out Value: TUInt64Value; const Name: String = ''; InitializeTo: UInt64 = 0); overload;
procedure FinalValue(var Value: TUInt64Value); overload;

{===============================================================================
    TFloat32Value
===============================================================================}
type
  TFloat32Value = class(TMVFloat32Value);

  TSingleValue = TFloat32Value;

procedure InitValue(out Value: TFloat32Value; const Name: String = ''; InitializeTo: Float32 = 0.0); overload;
procedure FinalValue(var Value: TFloat32Value); overload;

{===============================================================================
    TFloat64Value
===============================================================================}
type
  TFloat64Value = class(TMVFloat64Value);

  TDoubleValue = TFloat64Value;
  TFloatValue  = TFloat64Value;
  TRealValue   = TFloat64Value;

procedure InitValue(out Value: TFloat64Value; const Name: String = ''; InitializeTo: Float64 = 0.0); overload;
procedure FinalValue(var Value: TFloat64Value); overload;

{===============================================================================
    TDateTimeValue
===============================================================================}
type
  TDateTimeValue = class(TMVDateTimeValue);

  TDateValue = TDateTimeValue;
  TTimeValue = TDateTimeValue;

procedure InitValue(out Value: TDateTimeValue; const Name: String = ''; InitializeTo: TDateTime = 0.0); overload;
procedure FinalValue(var Value: TDateTimeValue); overload;

{===============================================================================
    TCurrencyValue
===============================================================================}
type
  TCurrencyValue = class(TMVCurrencyValue);

procedure InitValue(out Value: TCurrencyValue; const Name: String = ''; InitializeTo: Currency = 0.0); overload;
procedure FinalValue(var Value: TCurrencyValue); overload;

{===============================================================================
    TAnsiCharValue
===============================================================================}
type
  TAnsiCharValue = class(TMVAnsiCharValue);

procedure InitValue(out Value: TAnsiCharValue; const Name: String = ''; InitializeTo: AnsiChar = #0); overload;
procedure FinalValue(var Value: TAnsiCharValue); overload;

{===============================================================================
    TUTF8CharValue
===============================================================================}
type
  TUTF8CharValue = class(TMVUTF8CharValue);

procedure InitValue(out Value: TUTF8CharValue; const Name: String = ''; InitializeTo: UTF8Char = #0); overload;
procedure FinalValue(var Value: TUTF8CharValue); overload;

{===============================================================================
    TWideCharValue
===============================================================================}
type
  TWideCharValue = class(TMVWideCharValue);

procedure InitValue(out Value: TWideCharValue; const Name: String = ''; InitializeTo: WideChar = #0); overload;
procedure FinalValue(var Value: TWideCharValue); overload;

{===============================================================================
    TUnicodeCharValue
===============================================================================}
type
  TUnicodeCharValue = class(TMVUnicodeCharValue);

procedure InitValue(out Value: TUnicodeCharValue; const Name: String = ''; InitializeTo: UnicodeChar = #0); overload;
procedure FinalValue(var Value: TUnicodeCharValue); overload;

{===============================================================================
    TCharValue
===============================================================================}
type
  TCharValue = class(TMVCharValue);

procedure InitValue(out Value: TCharValue; const Name: String = ''; InitializeTo: Char = #0); overload;
procedure FinalValue(var Value: TCharValue); overload;

{===============================================================================
    TShortStringValue
===============================================================================}
type
  TShortStringValue = class(TMVShortStringValue);

procedure InitValue(out Value: TShortStringValue; const Name: String = ''; InitializeTo: ShortString = ''); overload;
procedure FinalValue(var Value: TShortStringValue); overload;

{===============================================================================
    TAnsiStringValue
===============================================================================}
type
  TAnsiStringValue = class(TMVAnsiStringValue);

procedure InitValue(out Value: TAnsiStringValue; const Name: String = ''; InitializeTo: AnsiString = ''); overload;
procedure FinalValue(var Value: TAnsiStringValue); overload;

{===============================================================================
    TUTF8StringValue
===============================================================================}
type
  TUTF8StringValue = class(TMVUTF8StringValue);

procedure InitValue(out Value: TUTF8StringValue; const Name: String = ''; InitializeTo: UTF8String = ''); overload;
procedure FinalValue(var Value: TUTF8StringValue); overload;

{===============================================================================
    TWideStringValue
===============================================================================}
type
  TWideStringValue = class(TMVWideStringValue);

procedure InitValue(out Value: TWideStringValue; const Name: String = ''; InitializeTo: WideString = ''); overload;
procedure FinalValue(var Value: TWideStringValue); overload;

{===============================================================================
    TUnicodeStringValue
===============================================================================}
type
  TUnicodeStringValue = class(TMVUnicodeStringValue);

procedure InitValue(out Value: TUnicodeStringValue; const Name: String = ''; InitializeTo: UnicodeString = ''); overload;
procedure FinalValue(var Value: TUnicodeStringValue); overload;

{===============================================================================
    TStringValue
===============================================================================}
type
  TStringValue = class(TMVStringValue);

procedure InitValue(out Value: TStringValue; const Name: String = ''; InitializeTo: String = ''); overload;
procedure FinalValue(var Value: TStringValue); overload;

{===============================================================================
    TPointerValue
===============================================================================}
type
  TPointerValue = class(TMVPointerValue);

procedure InitValue(out Value: TPointerValue; const Name: String = ''; InitializeTo: Pointer = nil); overload;
procedure FinalValue(var Value: TPointerValue); overload;

{===============================================================================
    TObjectValue
===============================================================================}
type
  TObjectValue = class(TMVObjectValue);

procedure InitValue(out Value: TObjectValue; const Name: String = ''; InitializeTo: TObject = nil); overload;
procedure FinalValue(var Value: TObjectValue); overload;

{===============================================================================
    Auxiliary funtions
===============================================================================}

Function ClassByValueType(ValueType: TMVManagedValueType): TManagedValueClass;

Function CreateByValueType(ValueType: TMVManagedValueType; const Name: String = ''): TManagedValue;

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
    Function NewValue(ValueType: TMVManagedValueType; const Name: String = ''): TMVManagedValueBase; virtual;
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
    Function NewShortStringValue(const Name: String = ''; InitTo: ShortString = ''): TShortStringValue; virtual;
    Function NewAnsiStringValue(const Name: String = ''; InitTo: AnsiString = ''): TAnsiStringValue; virtual;
    Function NewUTF8StringValue(const Name: String = ''; InitTo: UTF8String = ''): TUTF8StringValue; virtual;
    Function NewWideStringValue(const Name: String = ''; InitTo: WideString = ''): TWideStringValue; virtual;
    Function NewUnicodeStringValue(const Name: String = ''; InitTo: UnicodeString = ''): TUnicodeStringValue; virtual;
    Function NewStringValue(const Name: String = ''; InitTo: String = ''): TStringValue; virtual;
    Function NewPointerValue(const Name: String = ''; InitTo: Pointer = nil): TPointerValue; virtual;
    Function NewObjectValue(const Name: String = ''; InitTo: TObject = nil): TObjectValue; virtual;
  end;

{===============================================================================
    Global manager access functions - declaration
===============================================================================}

type
  TValueArray = array of TMVManagedValueBase;

Function FindManagedValue(const Name: String; out Value: TMVManagedValueBase): Boolean;
Function FindManagedValues(const Name: String; out Values: TValueArray): Integer;

Function ManagedValuesCount: Integer;
procedure ManagedValuesClear;   // Use with extreme caution!

implementation

uses
  SysUtils;

{===============================================================================
    TManagedValue
===============================================================================}

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

{===============================================================================
    TBooleanValue
===============================================================================}

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

{===============================================================================
    TInt8Value
===============================================================================}

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

{===============================================================================
    TUInt8Value
===============================================================================}

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

{===============================================================================
    TInt16Value
===============================================================================}

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

{===============================================================================
    TUInt16Value
===============================================================================}

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

{===============================================================================
    TInt32Value
===============================================================================}

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

{===============================================================================
    TUInt32Value
===============================================================================}

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

{===============================================================================
    TInt64Value
===============================================================================}

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

{===============================================================================
    TUInt64Value
===============================================================================}

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

{===============================================================================
    TFloat32Value
===============================================================================}

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

{===============================================================================
    TFloat64Value
===============================================================================}

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

{===============================================================================
    TDateTimeValue
===============================================================================}

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

{===============================================================================
    TCurrencyValue
===============================================================================}

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

{===============================================================================
    TAnsiCharValue
===============================================================================}

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

{===============================================================================
    TUTF8CharValue
===============================================================================}

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

{===============================================================================
    TWideCharValue
===============================================================================}

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

{===============================================================================
    TUnicodeCharValue
===============================================================================}

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

{===============================================================================
    TCharValue
===============================================================================}

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

{===============================================================================
    TShortStringValue
===============================================================================}

procedure InitValue(out Value: TShortStringValue; const Name: String = ''; InitializeTo: ShortString = '');
begin
Value := TShortStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TShortStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{===============================================================================
    TAnsiStringValue
===============================================================================}

procedure InitValue(out Value: TAnsiStringValue; const Name: String = ''; InitializeTo: AnsiString = '');
begin
Value := TAnsiStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TAnsiStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{===============================================================================
    TUTF8StringValue
===============================================================================}

procedure InitValue(out Value: TUTF8StringValue; const Name: String = ''; InitializeTo: UTF8String = '');
begin
Value := TUTF8StringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUTF8StringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{===============================================================================
    TWideStringValue
===============================================================================}

procedure InitValue(out Value: TWideStringValue; const Name: String = ''; InitializeTo: WideString = '');
begin
Value := TWideStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TWideStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{===============================================================================
    TUnicodeStringValue
===============================================================================}

procedure InitValue(out Value: TUnicodeStringValue; const Name: String = ''; InitializeTo: UnicodeString = '');
begin
Value := TUnicodeStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TUnicodeStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{===============================================================================
    TStringValue
===============================================================================}

procedure InitValue(out Value: TStringValue; const Name: String = ''; InitializeTo: String = '');
begin
Value := TStringValue.CreateAndInit(Name,InitializeTo);
end;

//------------------------------------------------------------------------------

procedure FinalValue(var Value: TStringValue);
begin
If Assigned(Value) then
  FreeAndNil(Value);
end;

{===============================================================================
    TPointerValue
===============================================================================}

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

{===============================================================================
    TObjectValue
===============================================================================}

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


{===============================================================================
    Auxiliary funtions
===============================================================================}

Function ClassByValueType(ValueType: TMVManagedValueType): TManagedValueClass;
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
  mvtWideChar:        Result := TWideCharValue;
  mvtUTF8Char:        Result := TUTF8CharValue;
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
  // array values
(*
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
  mvtAoWideChar:      Result := TAoWideCharValue;
  mvtAoUTF8Char:      Result := TAoUTF8CharValue;
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
*)
else
  raise EMVInvalidValue.CreateFmt('ClassByValueType: Unknown value type (%d).',[Ord(ValueType)]);
end;
end;

//------------------------------------------------------------------------------

Function CreateByValueType(ValueType: TMVManagedValueType; const Name: String = ''): TManagedValue;
begin
Result := ClassByValueType(ValueType).Create(Name);
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

Function TValuesManager.NewValue(ValueType: TMVManagedValueType; const Name: String = ''): TMVManagedValueBase;
begin
Result := CreateByValueType(ValueType,Name);
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

Function TValuesManager.NewShortStringValue(const Name: String = ''; InitTo: ShortString = ''): TShortStringValue;
begin
Result := TShortStringValue(NewValue(mvtShortString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewAnsiStringValue(const Name: String = ''; InitTo: AnsiString = ''): TAnsiStringValue;
begin
Result := TAnsiStringValue(NewValue(mvtAnsiString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUTF8StringValue(const Name: String = ''; InitTo: UTF8String = ''): TUTF8StringValue;
begin
Result := TUTF8StringValue(NewValue(mvtUTF8String,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewWideStringValue(const Name: String = ''; InitTo: WideString = ''): TWideStringValue;
begin
Result := TWideStringValue(NewValue(mvtWideString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewUnicodeStringValue(const Name: String = ''; InitTo: UnicodeString = ''): TUnicodeStringValue;
begin
Result := TUnicodeStringValue(NewValue(mvtUnicodeString,Name));
Result.Initialize(InitTo,False);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewStringValue(const Name: String = ''; InitTo: String = ''): TStringValue;
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

{===============================================================================
    Global manager access functions - implementation
===============================================================================}

Function FindManagedValue(const Name: String; out Value: TMVManagedValueBase): Boolean;
var
  GlobalManager:  TMVValuesManagerBase;
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
  GlobalManager:  TMVValuesManagerBase;
  NewValue:       TMVManagedValueBase;
begin
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
  GlobalManager:  TMVValuesManagerBase;
begin
GlobalManager := GetGlobalValuesManager;
If Assigned(GlobalManager) then
  Result := GlobalManager.Count
else
  Result := 0;
end;

//------------------------------------------------------------------------------

procedure ManagedValuesClear;
var
  GlobalManager:  TMVValuesManagerBase;
begin
GlobalManager := GetGlobalValuesManager;
If Assigned(GlobalManager) then
  GlobalManager.Clear;
end;


end.
