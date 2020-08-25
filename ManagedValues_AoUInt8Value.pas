unit ManagedValues_AoUInt8Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVAoUInt8Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = UInt8;
  TMVAoUInt8            = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoUInt8;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoUInt8Value - class declaration
===============================================================================}
type
  TMVAoUInt8Value = class(TMVAoIntegerManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoUInt8Value;

implementation

uses
  SysUtils, Math,
  BinaryStreaming, ListSorters;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}  

{===============================================================================
--------------------------------------------------------------------------------
                                TMVAoUInt8Value
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = 0;
  
{===============================================================================
    TMVAoUInt8Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoUInt8Value - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoUInt8;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitUInt8;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := Integer(TMVValueArrayItemType(A) - TMVValueArrayItemType(B));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVAoUInt8Value - specific public methods
-------------------------------------------------------------------------------}

procedure TMVValueClass.SaveToStream(Stream: TStream);
var
  i:  Integer;
begin
Stream_WriteInt32(Stream,fCurrentCount);
For i := LowIndex to HighIndex do
  Stream_WriteUInt8(Stream,fCurrentValue[i]);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
var
  Temp: TMVValueArrayType;
  i:    Integer;
begin
// load into temp
SetLength(Temp,Stream_ReadInt32(Stream));
For i := Low(Temp) to High(Temp) do
  Temp[i] := Stream_ReadUInt8(Stream);
// assign temp
If Init then
  Initialize(Temp,False)
else
  SetCurrentValue(Temp);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
var
  Strings:  TStringList;
  i:        Integer;
begin
Strings := TStringList.Create;
try
  For i := LowIndex to HighIndex do
    Strings.Add(IntToStr(fCurrentValue[i]));
  Result := Strings.DelimitedText
finally
  Strings.Free;
end;
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
var
  Strings:  TStringList;
  i:        Integer;
begin
Strings := TStringList.Create;
try
  Strings.DelimitedText := Str;
  SetLength(fCurrentValue,0);
  SetLength(fCurrentValue,Strings.Count);
  For i := 0 to Pred(Strings.Count) do
    fCurrentValue[i] := TMVValueArrayItemType(StrToInt(Strings[i]));
  fCurrentCount := Length(fCurrentValue);
  CheckAndSetEquality;
  DoCurrentChange;
finally
  Strings.Free;
end;
inherited;
end;

end.
