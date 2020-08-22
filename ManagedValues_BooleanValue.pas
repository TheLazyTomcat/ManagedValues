unit ManagedValues_BooleanValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVBooleanValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Boolean;

{$UNDEF MV_Value_ConstParams}
{$DEFINE MV_Value_AssignIsThreadSafe}
{$UNDEF MV_Value_StringLikeType}
{$DEFINE MV_Value_ComplexStreaming}

{===============================================================================
    TMVBooleanValue - class declaration
===============================================================================}
type
  TMVBooleanValue = class(TMVOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVBooleanValue;

implementation   

uses
  SysUtils,
  BinaryStreaming;

{$message 'remove unused units; add code separators for cpecific public/protected/private methods'}  

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVBooleanValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = False;

{===============================================================================
    TMVBooleanValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtBoolean;
end;

//------------------------------------------------------------------------------

{$IFNDEF MV_Value_StringLikeType}{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}{$ENDIF}
class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If TMVValueBaseType(A) and not TMVValueBaseType(B) then
  Result := +1
else If not TMVValueBaseType(A) and TMVValueBaseType(B) then
  Result := -1
else
  Result := 0;
end; 
{$IFNDEF MV_Value_StringLikeType}{$IFDEF FPCDWM}{$POP}{$ENDIF}{$ENDIF}

//------------------------------------------------------------------------------

Function TMVValueClass.SavedSize: TMemSize;
begin
Result := 1;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteBool(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadBool(Stream),False)
else
  SetCurrentValue(Stream_ReadBool(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := BoolToStr(fCurrentValue,True);
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(StrToBool(Str));
inherited;
end;

end.
