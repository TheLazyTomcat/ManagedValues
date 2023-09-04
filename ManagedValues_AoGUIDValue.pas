{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Array managed value of GUID.

  Version 1.0.1 alpha (2020-08-30) - requires extensive testing

  Last changed 2023-09-04

  ©2020-2023 František Milt

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
    AuxClasses      - github.com/TheLazyTomcat/Lib.AuxClasses
    AuxTypes        - github.com/TheLazyTomcat/Lib.AuxTypes    
    BinaryStreaming - github.com/TheLazyTomcat/Lib.BinaryStreaming
    ListSorters     - github.com/TheLazyTomcat/Lib.ListSorters
    StrRect         - github.com/TheLazyTomcat/Lib.StrRect
    UInt64Utils     - github.com/TheLazyTomcat/Lib.UInt64Utils   

===============================================================================}
unit ManagedValues_AoGUIDValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVAoGUIDValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = TGUID;
  TMVAoGUID             = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoGUID;

{$DEFINE MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoGUIDValue - class declaration
===============================================================================}
type
  TMVAoGUIDValue = class(TMVAoOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoGUIDValue;

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
                                 TMVAoGUIDValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE: TGUID = '{00000000-0000-0000-0000-000000000000}';
  
{===============================================================================
    TMVAoGUIDValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoGUIDValue - specific protected methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
var
  i:  Integer;
begin
If TMVValueArrayItemType(A).D1 > TMVValueArrayItemType(B).D1 then
  Result := +1
else If TMVValueArrayItemType(A).D1 < TMVValueArrayItemType(B).D1 then
  Result := -1
else
  begin
    If TMVValueArrayItemType(A).D2 > TMVValueArrayItemType(B).D2 then
      Result := +1
    else If TMVValueArrayItemType(A).D2 < TMVValueArrayItemType(B).D2 then
      Result := -1
    else
      begin
        If TMVValueArrayItemType(A).D3 > TMVValueArrayItemType(B).D3 then
          Result := +1
        else If TMVValueArrayItemType(A).D3 < TMVValueArrayItemType(B).D3 then
          Result := -1
        else
          begin
            Result := 0;
            For i := Low(TMVValueArrayItemType(A).D4) to High(TMVValueArrayItemType(B).D4) do
              If TMVValueArrayItemType(A).D4[i] > TMVValueArrayItemType(B).D4[i] then
                begin
                  Result := +1;
                  Break{For i};
                end
              else If TMVValueArrayItemType(A).D4[i] < TMVValueArrayItemType(B).D4[i] then
                begin
                  Result := -1;
                  Break{For i};
                end;
          end;
      end;
  end;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; const Value: TMVValueArrayItemType);
begin
Stream_WriteUInt32(Stream,Value.D1);
Stream_WriteUInt16(Stream,Value.D2);
Stream_WriteUInt16(Stream,Value.D3);
Stream_WriteBuffer(Stream,Value.D4,SizeOf(Value.D4));
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result.D1 := Stream_GetUInt32(Stream);
Result.D2 := Stream_GetUInt16(Stream);
Result.D3 := Stream_GetUInt16(Stream);
Stream_ReadBuffer(Stream,Result.D4,SizeOf(Result.D4));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(const Value: TMVValueArrayItemType): String;
begin
Result := GUIDToString(Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := StringToGUID(Str);
end;

{-------------------------------------------------------------------------------
    TMVAoGUIDValue - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtAoGUID;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemType: TMVArrayItemType;
begin
Result := aitGUID;
end;

end.
