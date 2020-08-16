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
  ManagedValues_CurrencyValue;

{===============================================================================
    TManagedValue
===============================================================================}

type
  TManagedValue = TManagedValueBase;

{===============================================================================
    TBooleanValue
===============================================================================}
type
  TBooleanValue = class(TMVBooleanValue);
  
  TBoolValue = TBooleanValue;

procedure InitValue(out Value: TBooleanValue; const Name: String = ''; InitializeTo: Boolean = False); overload;
procedure FinalValue(var Value: TBooleanValue); overload;

{$IFDEF FPC}
{$message 'operator overload'}
{$ENDIF}

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

{$message 'add some aliasses (integer, longword, ...)'}

{===============================================================================
--------------------------------------------------------------------------------
                                 TValuesManager
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TValuesManager - class declaration
===============================================================================}
type
  TValuesManager = class(TValuesManagerBase)
  public
    Function NewValue(ValueType: TManagedValueType; const Name: String = ''): TManagedValueBase; virtual;
    Function NewBoolValue(const Name: String = ''; InitTo: Boolean = False): TBooleanValue; virtual;
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
  end;

{===============================================================================
    Global manager access functions - declaration
===============================================================================}

type
  TValueArray = array of TManagedValueBase;

Function FindManagedValue(const Name: String; out Value: TManagedValueBase): Boolean;
Function FindManagedValues(const Name: String; out Values: TValueArray): Integer;

Function ManagedValuesCount: Integer;
procedure ManagedValuesClear;   // Use with extreme caution!

implementation

uses
  SysUtils;

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

Function TValuesManager.NewValue(ValueType: TManagedValueType; const Name: String = ''): TManagedValueBase;
begin
case ValueType of
  mvtBool:          Result := TBooleanValue.Create(Name);
  mvtInt8:          Result := TInt8Value.Create(Name);
  mvtUInt8:         Result := TUInt8Value.Create(Name);
  mvtInt16:         Result := TInt16Value.Create(Name);
  mvtUInt16:        Result := TUInt16Value.Create(Name);
  mvtInt32:         Result := TInt32Value.Create(Name);
  mvtUInt32:        Result := TUInt32Value.Create(Name);
  mvtInt64:         Result := TInt64Value.Create(Name);
  mvtUInt64:        Result := TUInt64Value.Create(Name);
  mvtFloat32:       Result := TFloat32Value.Create(Name);
  mvtFloat64:       Result := TFloat64Value.Create(Name);
  mvtDateTime:      Result := TDateTimeValue.Create(Name);
  mvtCurrency:      Result := TCurrencyValue.Create(Name);
//  mvtAnsiChar:
//  mvtWideChar:
//  mvtUTF8Char:
//  mvtUnicodeChar:
//  mvtShortString:
//  mvtAnsiString:
//  mvtWideString:
//  mvtUTF8String:
//  mvtUnicodeString:
//  mvtPointer:
//  mvtObject:
else
  raise EMVInvalidValue.CreateFmt('TValuesManager.NewValue: Unknown value type (%d).',[Ord(ValueType)]);
end;
Add(Result);
end;

//------------------------------------------------------------------------------

Function TValuesManager.NewBoolValue(const Name: String = ''; InitTo: Boolean = False): TBooleanValue;
begin
Result := TBooleanValue(NewValue(mvtBool,Name));
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

{===============================================================================
    Global manager access functions - implementation
===============================================================================}

Function FindManagedValue(const Name: String; out Value: TManagedValueBase): Boolean;
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
  NewValue:       TManagedValueBase;
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
  GlobalManager:  TValuesManagerBase;
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
  GlobalManager:  TValuesManagerBase;
begin
GlobalManager := GetGlobalValuesManager;
If Assigned(GlobalManager) then
  GlobalManager.Clear;
end;


end.
