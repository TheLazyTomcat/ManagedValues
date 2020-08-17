unit ManagedValues_StringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                  TStringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = String;

{$DEFINE MV_ConstParams}
{$UNDEF MV_AssignIsThreadSafe}
{$DEFINE MV_StringLikeType}
{$DEFINE MV_ComplexStreaming}

{===============================================================================
    TStringValue - class declaration
===============================================================================}
type
  TMVStringValue = class(TStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVStringValue;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                  TStringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = String('');

{===============================================================================
    TStringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtString;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := StringCompare(String(A),String(B),Arg);
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
// always saved as an UTF-8 encoded string
Result := 4 + (Length(StrToUTF8(fCurrentValue)));
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteString(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadString(Stream),False)
else
  SetCurrentValue(Stream_ReadString(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := ThreadSafeAssign(fCurrentValue);
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(ThreadSafeAssign(Str));
inherited;
end;

end.
