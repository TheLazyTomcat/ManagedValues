unit ManagedValues_AoCharValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVAoCharValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = Char;
  TMVAoChar             = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoChar;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$DEFINE MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoCharValue - class declaration
===============================================================================}
type
  TMVAoCharValue = class(TMVAoCharManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoCharValue;

implementation

uses
  Math,
  BinaryStreaming, ListSorters, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVAoCharValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = TMVValueArrayItemType(#0);
  
{===============================================================================
    TMVAoCharValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoCharValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoChar;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitChar;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := StringCompare(TMVValueArrayItemType(A),TMVValueArrayItemType(B),Arg);
end;

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; Value: TMVValueArrayItemType);
begin
Stream_WriteChar(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_ReadChar(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(Value: TMVValueArrayItemType): String;
begin
Result := Value;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
If Length(Str) > 0 then
  Result := Str[1]
else
  Result := MV_LOCAL_DEFAULT_ITEM_VALUE
end;

end.
