{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    GUID managed value.

  Version 1.0.1 alpha 2 (2024-05-05) - requires extensive testing

  Last changed 2024-05-05

  ©2020-2024 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/ManagedValues

  Dependencies:
    AuxClasses          - github.com/TheLazyTomcat/Lib.AuxClasses
  * AuxExceptions       - github.com/TheLazyTomcat/Lib.AuxExceptions
    AuxTypes            - github.com/TheLazyTomcat/Lib.AuxTypes
  * BinaryStreamingLite - github.com/TheLazyTomcat/Lib.BinaryStreamingLite
    ListSorters         - github.com/TheLazyTomcat/Lib.ListSorters
    StrRect             - github.com/TheLazyTomcat/Lib.StrRect
    UInt64Utils         - github.com/TheLazyTomcat/Lib.UInt64Utils

  Library AuxExceptions is required only when rebasing local exception classes
  (see symbol ManagedValues_UseAuxExceptions for details).

  BinaryStreamingLite can be replaced by full BinaryStreaming.

  Library AuxExceptions might also be required as an indirect dependency.

  Indirect dependencies:
    SimpleCPUID - github.com/TheLazyTomcat/Lib.SimpleCPUID
    WinFileInfo - github.com/TheLazyTomcat/Lib.WinFileInfo

===============================================================================}
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
  BinaryStreamingLite;  

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

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtGUID;
end;

//------------------------------------------------------------------------------

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
Temp.D1 := Stream_GetUInt32(Stream);
Temp.D2 := Stream_GetUInt16(Stream);
Temp.D3 := Stream_GetUInt16(Stream);
Stream_ReadBuffer(Stream,Temp.D4,SizeOf(Temp.D4));
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
