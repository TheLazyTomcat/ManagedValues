unit ManagedValues_AnsiCharValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TAnsiCharValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = AnsiChar;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$DEFINE MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TAnsiCharValue - class declaration
===============================================================================}
type
  TMVAnsiCharValue = class(TCharManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAnsiCharValue;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                 TAnsiCharValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = AnsiChar(#0);

{===============================================================================
    TAnsiCharValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtAnsiChar;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := AnsiStringCompare(AnsiChar(A),AnsiChar(B),Arg);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteAnsiChar(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadAnsiChar(Stream),False)
else
  SetCurrentValue(Stream_ReadAnsiChar(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := AnsiToStr(fCurrentValue);
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
var
  Temp: AnsiString;
begin
Temp := StrToAnsi(Str);
If Length(Temp) > 0 then
  SetCurrentValue(Temp[1])
else
  SetCurrentValue(MV_LOCAL_DEFAULT_VALUE);  
inherited;
end;

end.
