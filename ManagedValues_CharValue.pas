unit ManagedValues_CharValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                   TCharValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Char;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$DEFINE MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TCharValue - class declaration
===============================================================================}
type
  TMVCharValue = class(TCharManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVCharValue;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                   TCharValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = Char(#0);

{===============================================================================
    TCharValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtChar;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := StringCompare(Char(A),Char(B),Arg);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteChar(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadChar(Stream),False)
else
  SetCurrentValue(Stream_ReadChar(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := fCurrentValue;
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
If Length(Str) > 0 then
  SetCurrentValue(Str[1])
else
  SetCurrentValue(MV_LOCAL_DEFAULT_VALUE);  
inherited;
end;

end.
