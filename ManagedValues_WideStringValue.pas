unit ManagedValues_WideStringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TWideStringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = WideString;

{$DEFINE MV_ConstParams}
{$UNDEF MV_AssignIsThreadSafe}
{$DEFINE MV_StringLikeType}
{$DEFINE MV_ComplexStreaming}

{===============================================================================
    TWideStringValue - class declaration
===============================================================================}
type
  TMVWideStringValue = class(TStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVWideStringValue;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                TWideStringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = WideString('');

{===============================================================================
    TWideStringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtWideString;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := WideStringCompare(WideString(A),WideString(B),Arg);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ThreadSafeAssign(const Value: TMVValueBaseType): TMVValueBaseType;
begin
Result := Value;
UniqueString(Result);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.SavedSize: TMemSize;
begin
Result := 4 + (Length(fCurrentValue) * SizeOf(WideChar));
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteWideString(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadWideString(Stream),False)
else
  SetCurrentValue(Stream_ReadWideString(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := WideToStr(ThreadSafeAssign(fCurrentValue));
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(ThreadSafeAssign(StrToWide(Str)));
inherited;
end;

end.
