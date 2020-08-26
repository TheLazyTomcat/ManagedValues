unit ManagedValues_AoUnicodeCharValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                             TMVAoUnicodeCharValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = UnicodeChar;
  TMVAoUnicodeChar      = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoUnicodeChar;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$DEFINE MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoUnicodeCharValue - class declaration
===============================================================================}
type
  TMVAoUnicodeCharValue = class(TMVAoCharManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoUnicodeCharValue;

implementation

uses
  Math,
  BinaryStreaming, ListSorters, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                             TMVAoUnicodeCharValue                              
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = TMVValueArrayItemType(#0);
  
{===============================================================================
    TMVAoUnicodeCharValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoUnicodeCharValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoUnicodeChar;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitUnicodeChar;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := UnicodeStringCompare(TMVValueArrayItemType(A),TMVValueArrayItemType(B),Arg);
end;

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; Value: TMVValueArrayItemType);
begin
Stream_WriteUnicodeChar(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_ReadUnicodeChar(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(Value: TMVValueArrayItemType): String;
begin
Result := UnicodeToStr(Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
var
  Temp: UnicodeString;
begin
Temp := StrToUnicode(Str);
If Length(Temp) > 0 then
  Result := Temp[1]
else
  Result := MV_LOCAL_DEFAULT_ITEM_VALUE
end;

end.
