{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Array managed value of Float32.

  Version 1.0 alpha (2020-08-29) - requires extensive testing

  Last changed 2020-08-29

  ©2020 František Milt

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
    AuxTypes        - github.com/TheLazyTomcat/Lib.AuxTypes
    AuxClasses      - github.com/TheLazyTomcat/Lib.AuxClasses
    BinaryStreaming - github.com/TheLazyTomcat/Lib.BinaryStreaming
    StrRect         - github.com/TheLazyTomcat/Lib.StrRect
    UInt64Utils     - github.com/TheLazyTomcat/Lib.UInt64Utils
    ListSorters     - github.com/TheLazyTomcat/Lib.ListSorters

===============================================================================}
unit ManagedValues_AoFloat32Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAoFloat32Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = Float32;
  TMVAoFloat32          = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoFloat32;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoFloat32Value - class declaration
===============================================================================}
type
  TMVAoFloat32Value = class(TMVAoRealManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoFloat32Value;

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
                                TMVAoFloat32Value
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = 0.0;
  
{===============================================================================
    TMVAoFloat32Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoFloat32Value - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoFloat32;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitFloat32;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
If TMVValueArrayItemType(A) > TMVValueArrayItemType(B) then
  Result := +1
else If TMVValueArrayItemType(A) < TMVValueArrayItemType(B) then
  Result := -1
else
  Result := 0;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; Value: TMVValueArrayItemType);
begin
Stream_WriteFloat32(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_ReadFloat32(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(Value: TMVValueArrayItemType): String;
begin
Result := FloatToStr(Value,fFormatSettings);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := StrToFloat(Str,fFormatSettings);
end;

end.
