unit ManagedValues_Int64Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                  TInt64Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Int64;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$UNDEF MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TInt64Value - class declaration
===============================================================================}
type
  TMVInt64Value = class(TIntegerManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVInt64Value;

implementation

uses
  SysUtils,
  BinaryStreaming;

{===============================================================================
--------------------------------------------------------------------------------
                                  TInt64Value                                  
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = 0;

{===============================================================================
    TInt64Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtInt64;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If Int64(A) > Int64(B) then
  Result := +1
else If Int64(A) < Int64(B) then
  Result := -1
else
  Result := 0;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteInt64(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadInt64(Stream),False)
else
  SetCurrentValue(Stream_ReadInt64(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := IntToStr(Int64(fCurrentValue));
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(Int64(StrToInt64(Str)));
inherited;
end;

end.