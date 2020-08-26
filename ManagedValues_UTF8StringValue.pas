unit ManagedValues_UTF8StringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVUTF8StringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = UTF8String;

{$DEFINE MV_Value_ConstParams}
{$UNDEF MV_Value_AssignIsThreadSafe}
{$DEFINE MV_Value_CaseSensitivity}
{$DEFINE MV_Value_ComplexStreamedSize}

{===============================================================================
    TMVUTF8StringValue - class declaration
===============================================================================}
type
  TMVUTF8StringValue = class(TMVStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVUTF8StringValue;

implementation

uses
  BinaryStreaming, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVUTF8StringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = TMVValueBaseType('');

{===============================================================================
    TMVUTF8StringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVUTF8StringValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtUTF8String;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := UTF8StringCompare(TMVValueBaseType(A),TMVValueBaseType(B),Arg);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ThreadSafeAssign(const Value: TMVValueBaseType): TMVValueBaseType;
begin
Result := Value;
UniqueString({$IFNDEF FPC}AnsiString{$ENDIF}(Result));
end;

{-------------------------------------------------------------------------------
    TMVUTF8StringValue - specific public methods
-------------------------------------------------------------------------------}

Function TMVValueClass.StreamedSize: TMemSize;
begin
Result := 4 + Length(fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUTF8String(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadUTF8String(Stream),False)
else
  SetCurrentValue(Stream_ReadUTF8String(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := UTF8ToStr(ThreadSafeAssign(fCurrentValue));
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(ThreadSafeAssign(StrToUTF8(Str)));
inherited;
end;

end.
