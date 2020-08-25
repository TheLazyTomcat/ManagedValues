unit ManagedValues_AoInt16Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVAoInt16Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = Int16;
  TMVAoInt16            = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoInt16;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoInt16Value - class declaration
===============================================================================}
type
  TMVAoInt16Value = class(TMVAoIntegerManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoInt16Value;

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
                                TMVAoInt16Value
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = 0;
  
{===============================================================================
    TMVAoInt16Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoInt16Value - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoInt16;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitInt16;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := Integer(TMVValueArrayItemType(A) - TMVValueArrayItemType(B));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVAoInt16Value - specific public methods
-------------------------------------------------------------------------------}

procedure TMVValueClass.SaveToStream(Stream: TStream);
var
  i:  Integer;
begin
Stream_WriteInt32(Stream,fCurrentCount);
For i := LowIndex to HighIndex do
  Stream_WriteInt16(Stream,fCurrentValue[i]);
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
  Temp[i] := Stream_ReadInt16(Stream);
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
