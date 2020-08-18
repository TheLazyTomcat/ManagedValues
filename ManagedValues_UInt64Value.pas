unit ManagedValues_UInt64Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                  TUInt64Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = UInt64;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$UNDEF MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TUInt64Value - class declaration
===============================================================================}
type
  TMVUInt64Value = class(TIntegerManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVUInt64Value;

implementation

uses
  SysUtils,
  UInt64Utils,
  BinaryStreaming;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                  TUInt64Value                                  
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = 0;

{===============================================================================
    TUInt64Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtUInt64;
end;

//------------------------------------------------------------------------------

{$IFNDEF MV_StringLikeType}{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}{$ENDIF}
Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := CompareUInt64(UInt64(A),UInt64(B));
end;    
{$IFNDEF MV_StringLikeType}{$IFDEF FPCDWM}{$POP}{$ENDIF}{$ENDIF}

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUInt64(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadUInt64(Stream),False)
else
  SetCurrentValue(Stream_ReadUInt64(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := UInt64ToStr(fCurrentValue);
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(StrToUInt64(Str));
inherited;
end;

end.
