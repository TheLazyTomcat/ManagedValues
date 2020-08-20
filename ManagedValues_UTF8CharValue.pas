unit ManagedValues_UTF8CharValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVUTF8CharValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = UTF8Char;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$DEFINE MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TMVUTF8CharValue - class declaration
===============================================================================}
type
  TMVUTF8CharValue = class(TMVCharManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVUTF8CharValue;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVUTF8CharValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = UTF8Char(#0);

{===============================================================================
    TMVUTF8CharValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtUTF8Char;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := UTF8StringCompare(UTF8Char(A),UTF8Char(B),Arg);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUTF8Char(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadUTF8Char(Stream),False)
else
  SetCurrentValue(Stream_ReadUTF8Char(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := UTF8ToStr(fCurrentValue);
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
var
  Temp: UTF8String;
begin
Temp := StrToUTF8(Str);
If Length(Temp) > 0 then
  SetCurrentValue(Temp[1])
else
  SetCurrentValue(MV_LOCAL_DEFAULT_VALUE);
inherited;
end;

end.
