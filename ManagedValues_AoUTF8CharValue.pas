unit ManagedValues_AoUTF8CharValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAoUTF8CharValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = UTF8Char;
  TMVAoUTF8Char         = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoUTF8Char;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$DEFINE MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoUTF8CharValue - class declaration
===============================================================================}
type
  TMVAoUTF8CharValue = class(TMVAoCharManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoUTF8CharValue;

implementation

uses
  Math,
  BinaryStreaming, ListSorters, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAoUTF8CharValue                                
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = TMVValueArrayItemType(#0);
  
{===============================================================================
    TMVAoUTF8CharValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoUTF8CharValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoUTF8Char;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitUTF8Char;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := UTF8StringCompare(TMVValueArrayItemType(A),TMVValueArrayItemType(B),Arg);
end;

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; Value: TMVValueArrayItemType);
begin
Stream_WriteUTF8Char(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_ReadUTF8Char(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(Value: TMVValueArrayItemType): String;
begin
Result := UTF8ToStr(Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
var
  Temp: UTF8String;
begin
Temp := StrToUTF8(Str);
If Length(Temp) > 0 then
  Result := Temp[1]
else
  Result := MV_LOCAL_DEFAULT_ITEM_VALUE
end;

end.
