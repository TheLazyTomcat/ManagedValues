unit ManagedValues_GUIDValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                  TMVGUIDValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = TGUID;

{$DEFINE MV_Value_ConstParams}
{$DEFINE MV_Value_AssignIsThreadSafe}
{$UNDEF MV_Value_CaseSensitivity}
{$UNDEF MV_Value_ComplexStreamedSize}

{===============================================================================
    TMVGUIDValue - class declaration
===============================================================================}
type
  TMVGUIDValue = class(TMVOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVGUIDValue;

implementation

uses
  SysUtils,
  BinaryStreaming;  

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                  TMVGUIDValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE: TGUID = '{00000000-0000-0000-0000-000000000000}';

{===============================================================================
    TMVGUIDValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVGUIDValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtGUID;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
var
  i:  Integer;
begin
If TMVValueBaseType(A).D1 > TMVValueBaseType(B).D1 then
  Result := +1
else If TMVValueBaseType(A).D1 < TMVValueBaseType(B).D1 then
  Result := -1
else
  begin
    If TMVValueBaseType(A).D2 > TMVValueBaseType(B).D2 then
      Result := +1
    else If TMVValueBaseType(A).D2 < TMVValueBaseType(B).D2 then
      Result := -1
    else
      begin
        If TMVValueBaseType(A).D3 > TMVValueBaseType(B).D3 then
          Result := +1
        else If TMVValueBaseType(A).D3 < TMVValueBaseType(B).D3 then
          Result := -1
        else
          begin
            Result := 0;
            For i := Low(TMVValueBaseType(A).D4) to High(TMVValueBaseType(B).D4) do
              If TMVValueBaseType(A).D4[i] > TMVValueBaseType(B).D4[i] then
                begin
                  Result := +1;
                  Break{For i};
                end
              else If TMVValueBaseType(A).D4[i] < TMVValueBaseType(B).D4[i] then
                begin
                  Result := -1;
                  Break{For i};
                end;
          end;
      end;
  end;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVGUIDValue - specific public methods
-------------------------------------------------------------------------------}

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUInt32(Stream,fCurrentValue.D1);
Stream_WriteUInt16(Stream,fCurrentValue.D2);
Stream_WriteUInt16(Stream,fCurrentValue.D3);
Stream_WriteBuffer(Stream,fCurrentValue.D4,SizeOf(fCurrentValue.D4));
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
var
  Temp: TMVValueBaseType;
begin
Temp.D1 := Stream_ReadUInt32(Stream);
Temp.D2 := Stream_ReadUInt16(Stream);
Temp.D3 := Stream_ReadUInt16(Stream);
Stream_ReadBuffer(STream,Temp.D4,SizeOf(Temp.D4));
If Init then
  Initialize(Temp,False)
else
  SetCurrentValue(Temp);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := GUIDToString(fCurrentValue);
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(StringToGUID(Str));
inherited;
end;

end.
