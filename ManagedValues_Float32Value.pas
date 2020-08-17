unit ManagedValues_Float32Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TFloat32Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Float32;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$UNDEF MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TFloat32Value - class declaration
===============================================================================}
type
  TMVFloat32Value = class(TRealManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVFloat32Value;

implementation

uses
  SysUtils,
  BinaryStreaming;

{===============================================================================
--------------------------------------------------------------------------------
                                 TFloat32Value
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = 0.0;

{===============================================================================
    TFloat32Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtFloat32;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If Float32(A) > Float32(B) then
  Result := +1
else If Float32(A) < Float32(B) then
  Result := -1
else
  Result := 0;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteFloat32(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadFloat32(Stream),False)
else
  SetCurrentValue(Stream_ReadFloat32(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := FloatToStr(fCurrentValue,fFormatSettings);
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(StrToFloat(Str,fFormatSettings));
inherited;
end;

end.
