unit ManagedValues_AoBooleanValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAoBooleanValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = Boolean;
  TMVAoBoolean          = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoBoolean;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$DEFINE MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoBooleanValue - class declaration
===============================================================================}
type
  TMVAoBooleanValue = class(TMVAoOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoBooleanValue;

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
                               TMVAoBooleanValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = False;
  
{===============================================================================
    TMVAoBooleanValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoBooleanValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoBoolean;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitBoolean;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
If TMVValueArrayItemType(A) and not TMVValueArrayItemType(B) then
  Result := +1
else If not TMVValueArrayItemType(A) and TMVValueArrayItemType(B) then
  Result := -1
else
  Result := 0;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVAoBooleanValue - specific public methods
-------------------------------------------------------------------------------}

Function TMVValueClass.StreamedSize: TMemSize;
begin
// each boolean item is saved as one byte
Result := SizeOf(Int32){array length} + fCurrentCount;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
var
  i:  Integer;
begin
Stream_WriteInt32(Stream,fCurrentCount);
For i := LowIndex to HighIndex do
  Stream_WriteBool(Stream,fCurrentValue[i]);
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
  Temp[i] := Stream_ReadBool(Stream);
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
    Strings.Add(BoolToStr(fCurrentValue[i],True));
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
    fCurrentValue[i] := StrToBool(Strings[i]);
  fCurrentCount := Length(fCurrentValue);
  CheckAndSetEquality;
  DoCurrentChange;
finally
  Strings.Free;
end;
inherited;
end;

end.
