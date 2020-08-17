unit ManagedValues_ShortStringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TShortStringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = ShortString;

{$DEFINE MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$DEFINE MV_StringLikeType}
{$DEFINE MV_ComplexStreaming}

{===============================================================================
    TShortStringValue - class declaration
===============================================================================}
type
  TMVShortStringValue = class(TStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVShortStringValue;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                TShortStringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = ShortString('');

{===============================================================================
    TShortStringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtShortString;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := ShortStringCompare(ShortString(A),ShortString(B),Arg);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.SavedSize: TMemSize;
begin
Result := 1 + Length(fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteShortString(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadShortString(Stream),False)
else
  SetCurrentValue(Stream_ReadShortString(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ToString: String;
begin
Result := ShortToStr(fCurrentValue);
inherited ToString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(StrToShort(Str));
inherited;
end;

end.
