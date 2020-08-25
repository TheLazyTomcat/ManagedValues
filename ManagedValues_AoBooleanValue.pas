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

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; Value: TMVValueArrayItemType);
begin
Stream_WriteBool(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_ReadBool(Stream);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemAsString(Value: TMVValueArrayItemType): String;
begin
Result := BoolToStr(Value,True);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := StrToBool(Str);
end;

{-------------------------------------------------------------------------------
    TMVAoBooleanValue - specific public methods
-------------------------------------------------------------------------------}

Function TMVValueClass.StreamedSize: TMemSize;
begin
// each boolean item is saved as one byte
Result := SizeOf(Int32){array length} + fCurrentCount;
end;

end.
