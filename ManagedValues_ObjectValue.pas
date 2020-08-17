unit ManagedValues_ObjectValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                  TObjectValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = TObject;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$UNDEF MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TObjectValue - class declaration
===============================================================================}
type
  TMVObjectValue = class(TOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVObjectValue;

implementation

uses
  SysUtils,
  BinaryStreaming;

{===============================================================================
--------------------------------------------------------------------------------
                                  TObjectValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = nil;

{===============================================================================
    TObjectValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtObject;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If PtrUInt(Pointer(TObject(A))) > PtrUInt(Pointer(TObject(B))) then
  Result := +1
else If PtrUInt(Pointer(TObject(A))) < PtrUInt(Pointer(TObject(B))) then
  Result := -1
else
  Result := 0;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUInt64(Stream,UInt64(Pointer(fCurrentValue)));
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(TObject(Pointer(Stream_ReadUInt64(Stream))),False)
else
  SetCurrentValue(TObject(Pointer(Stream_ReadUInt64(Stream))));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := Format('0x%p',[Pointer(fCurrentValue)]);
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(TObject(Pointer(StrToInt64(Str))));
inherited;
end;

end.
