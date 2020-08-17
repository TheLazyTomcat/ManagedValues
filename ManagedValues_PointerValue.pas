unit ManagedValues_PointerValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TPointerValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Pointer;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$UNDEF MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TPointerValue - class declaration
===============================================================================}
type
  TMVPointerValue = class(TOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVPointerValue;

implementation

uses
  SysUtils,
  BinaryStreaming;

{===============================================================================
--------------------------------------------------------------------------------
                                 TPointerValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = nil;

{===============================================================================
    TPointerValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtPointer;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If PtrUInt(Pointer(A)) > PtrUInt(Pointer(B)) then
  Result := +1
else If PtrUInt(Pointer(A)) < PtrUInt(Pointer(B)) then
  Result := -1
else
  Result := 0;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUInt64(Stream,UInt64(fCurrentValue));
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Pointer(Stream_ReadUInt64(Stream)),False)
else
  SetCurrentValue(Pointer(Stream_ReadUInt64(Stream)));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := Format('0x%p',[fCurrentValue]);
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(Pointer(StrToInt64(Str)));
inherited;
end;

end.
