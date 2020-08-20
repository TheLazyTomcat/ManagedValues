unit ManagedValues_AnsiStringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAnsiStringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = AnsiString;

{$DEFINE MV_ConstParams}
{$UNDEF MV_AssignIsThreadSafe}
{$DEFINE MV_StringLikeType}
{$DEFINE MV_ComplexStreaming}

{===============================================================================
    TMVAnsiStringValue - class declaration
===============================================================================}
type
  TMVAnsiStringValue = class(TMVStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAnsiStringValue;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAnsiStringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = AnsiString('');

{===============================================================================
    TMVAnsiStringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAnsiString;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := AnsiStringCompare(AnsiString(A),AnsiString(B),Arg);
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
Result := 4 + Length(fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteAnsiString(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadAnsiString(Stream),False)
else
  SetCurrentValue(Stream_ReadAnsiString(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := AnsiToStr(ThreadSafeAssign(fCurrentValue));
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(ThreadSafeAssign(StrToAnsi(Str)));
inherited;
end;

end.
