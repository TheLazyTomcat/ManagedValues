{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Array managed value of AnsiString.

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
unit ManagedValues_AoAnsiStringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                              TMVAoAnsiStringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = AnsiString;
  TMVAoAnsiString       = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoAnsiString;

{$DEFINE MV_ArrayItem_ConstParams}
{$UNDEF MV_ArrayItem_AssignIsThreadSafe}
{$DEFINE MV_ArrayItem_CaseSensitivity}
{$DEFINE MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoAnsiStringValue - class declaration
===============================================================================}
type
  TMVAoAnsiStringValue = class(TMVAoStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoAnsiStringValue;

implementation

uses
  Math,
  BinaryStreamingLite, StrRect, ListSorters;

{===============================================================================
--------------------------------------------------------------------------------
                              TMVAoAnsiStringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = TMVValueArrayItemType('');
  
{===============================================================================
    TMVAoAnsiStringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoAnsiStringValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := AnsiStringCompare(TMVValueArrayItemType(A),TMVValueArrayItemType(B),Arg);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemThreadSafeAssign({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType): TMVValueArrayItemType;
begin
Result := Value;
UniqueString(Result);
end;

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; const Value: TMVValueArrayItemType);
begin
Stream_WriteAnsiString(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_GetAnsiString(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(const Value: TMVValueArrayItemType): String;
begin
Result := AnsiToStr(Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := StrToAnsi(Str);
end;

{-------------------------------------------------------------------------------
    TMVAoAnsiStringValue - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtAoAnsiString;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemType: TMVArrayItemType;
begin
Result := aitAnsiString;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.StreamedSize: TMemSize;
var
  i:  Integer;
begin
Result := SizeOf(Int32);  // array length
For i := LowIndex to HighIndex do
  Inc(Result,StreamedSize_AnsiString(fCurrentValue[i]));
end;

end.
