unit ManagedValues_DateTimeValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVDateTimeValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = TDateTime;

{$UNDEF MV_Value_ConstParams}
{$DEFINE MV_Value_AssignIsThreadSafe}
{$UNDEF MV_Value_StringLikeType}
{$UNDEF MV_Value_ComplexStreaming}

{===============================================================================
    TMVDateTimeValue - class declaration
===============================================================================}
type
  TMVDateTimeValue = class(TMVRealManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVDateTimeValue;

implementation

uses
  SysUtils,
  BinaryStreaming;  

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                TMVDateTimeValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = 0.0;

{===============================================================================
    TMVDateTimeValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVDateTimeValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtDateTime;
end;

//------------------------------------------------------------------------------

{$IFNDEF MV_Value_StringLikeType}{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}{$ENDIF}
class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If TMVValueBaseType(A) > TMVValueBaseType(B) then
  Result := +1
else If TMVValueBaseType(A) < TMVValueBaseType(B) then
  Result := -1
else
  Result := 0;
end;
{$IFNDEF MV_Value_StringLikeType}{$IFDEF FPCDWM}{$POP}{$ENDIF}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVDateTimeValue - specific public methods
-------------------------------------------------------------------------------}

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteDateTime(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadDateTime(Stream),False)
else
  SetCurrentValue(Stream_ReadDateTime(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := DateTimeToStr(fCurrentValue,fFormatSettings);
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(StrToDateTime(Str,fFormatSettings));
inherited;
end;

end.
