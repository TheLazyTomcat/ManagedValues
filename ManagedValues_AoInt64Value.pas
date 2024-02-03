{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Array managed value of Int64.

  Version 1.0.1 alpha (2020-08-30) - requires extensive testing

  Last changed 2024-02-03

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
    AuxTypes            - github.com/TheLazyTomcat/Lib.AuxTypes    
  * BinaryStreamingLite - github.com/TheLazyTomcat/Lib.BinaryStreamingLite
    ListSorters         - github.com/TheLazyTomcat/Lib.ListSorters
    StrRect             - github.com/TheLazyTomcat/Lib.StrRect
    UInt64Utils         - github.com/TheLazyTomcat/Lib.UInt64Utils   
     
  BinaryStreamingLite can be replaced by full BinaryStreaming.

===============================================================================}
unit ManagedValues_AoInt64Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                TMVAoInt64Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = Int64;
  TMVAoInt64            = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoInt64;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoInt64Value - class declaration
===============================================================================}
type
  TMVAoInt64Value = class(TMVAoIntegerManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoInt64Value;

implementation

uses
  SysUtils, Math,
  BinaryStreamingLite, ListSorters;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}  

{===============================================================================
--------------------------------------------------------------------------------
                                TMVAoInt64Value
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = 0;
  
{===============================================================================
    TMVAoInt64Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoInt64Value - specific protected methods
-------------------------------------------------------------------------------}

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
Stream_WriteInt64(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_GetInt64(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(Value: TMVValueArrayItemType): String;
begin
Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := StrToInt64(Str);
end;

{-------------------------------------------------------------------------------
    TMVAoInt64Value - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtAoInt64;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemType: TMVArrayItemType;
begin
Result := aitInt64;
end;

end.
