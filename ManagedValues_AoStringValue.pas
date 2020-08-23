unit ManagedValues_AoStringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVAoStringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVAoString = array of String;

  TMVValueArrayItemType = String;
  TMVValueArrayType     = TMVAoString;

{$DEFINE MV_ArrayItem_ConstParams}
{$UNDEF MV_ArrayItem_AssignIsThreadSafe}
{$DEFINE MV_ArrayItem_StringLikeType}
{$DEFINE MV_ArrayItem_ComplexStreaming}

{===============================================================================
    TMVAoStringValue - class declaration
===============================================================================}
type
  TMVAoStringValue = class(TMVAoStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoStringValue;

implementation

uses
  Math,
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVAoStringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = String('');
  
{===============================================================================
    TMVAoStringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoStringValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoString;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitString;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := StringCompare(TMVValueArrayItemType(A),TMVValueArrayItemType(B),Arg);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemThreadSafeAssign({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType): TMVValueArrayItemType;
begin
Result := Value;
UniqueString(Result);
end;

{-------------------------------------------------------------------------------
    TMVAoStringValue - specific public methods
-------------------------------------------------------------------------------}  

Function TMVValueClass.StreamedSize: TMemSize;
var
  i:  Integer;
begin
Result := SizeOf(Int32);  // array length
For i := LowIndex to HighIndex do
  Inc(Result,4 + Length(StrToUTF8(fCurrentValue[i])));
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
var
  i:  Integer;
begin
Stream_WriteInt32(Stream,fCurrentCount);
For i := LowIndex to HighIndex do
  Stream_WriteString(Stream,fCurrentValue[i]);
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
  Temp[i] := Stream_ReadString(Stream);
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
    Strings.Add(fCurrentValue[i]);
  Result := Strings.DelimitedText;
finally
  Strings.Free;
end;
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
var
  Strings:  TStringList;
  Temp:     TMVValueArrayType;
  i:        Integer;
begin
Strings := TStringList.Create;
try
  Strings.DelimitedText := Str;
  SetLength(Temp,Strings.Count);
  For i := 0 to Pred(Strings.Count) do
    Temp[i] := Strings[i];
  SetCurrentValue(Temp);
finally
  Strings.Free;
end;
inherited;
end;

end.
