{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Array managed value of Int8.

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
unit ManagedValues_AoInt8Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVAoInt8Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = Int8;
  TMVAoInt8             = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoInt8;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoInt8Value - class declaration
===============================================================================}
type
  TMVAoInt8Value = class(TMVAoIntegerManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoInt8Value;

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
                                 TMVAoInt8Value
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = 0;
  
{===============================================================================
    TMVAoInt8Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoInt8Value - specific protected methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := Integer(TMVValueArrayItemType(A) - TMVValueArrayItemType(B));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; Value: TMVValueArrayItemType);
begin
Stream_WriteInt8(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_GetInt8(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(Value: TMVValueArrayItemType): String;
begin
Result := IntToStr(Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := TMVValueArrayItemType(StrToInt(Str));
end;

{-------------------------------------------------------------------------------
    TMVAoInt8Value - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtAoInt8;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemType: TMVArrayItemType;
begin
Result := aitInt8;
end;

end.
