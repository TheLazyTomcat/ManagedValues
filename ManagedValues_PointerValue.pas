unit ManagedValues_PointerValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVPointerValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Pointer;

{$UNDEF MV_Value_ConstParams}
{$DEFINE MV_Value_AssignIsThreadSafe}
{$UNDEF MV_Value_StringLikeType}
{$UNDEF MV_Value_ComplexStreaming}

{===============================================================================
    TMVPointerValue - class declaration
===============================================================================}
type
  TMVPointerValue = class(TMVOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVPointerValue;

implementation

uses
  SysUtils,
  BinaryStreaming;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W4055:={$WARN 4055 OFF}} // Conversion between ordinals and pointers is not portable
  {$DEFINE W4056:={$WARN 4056 OFF}} // Conversion between ordinals and pointers is not portable
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                TMVPointerValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = nil;

{===============================================================================
    TMVPointerValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVPointerValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtPointer;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 {$IFNDEF MV_Value_StringLikeType}W5024{$ENDIF}{$ENDIF}
class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If PtrUInt(TMVValueBaseType(A)) > PtrUInt(TMVValueBaseType(B)) then
  Result := +1
else If PtrUInt(TMVValueBaseType(A)) < PtrUInt(TMVValueBaseType(B)) then
  Result := -1
else
  Result := 0;
end;  
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVPointerValue - specific public methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUInt64(Stream,UInt64(fCurrentValue));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Pointer(Stream_ReadUInt64(Stream)),False)
else
  SetCurrentValue(Pointer(Stream_ReadUInt64(Stream)));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := Format('0x%p',[fCurrentValue]);
inherited AsString;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(Pointer(StrToInt64(Str)));
inherited;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

end.
