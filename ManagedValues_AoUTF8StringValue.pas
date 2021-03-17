{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Array managed value of UTF8String.

  Version 1.0.1 alpha (2020-08-30) - requires extensive testing

  Last changed 2021-03-17

  ©2020-2021 František Milt

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
unit ManagedValues_AoUTF8StringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                              TMVAoUTF8StringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = UTF8String;
  TMVAoUTF8String       = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoUTF8String;

{$DEFINE MV_ArrayItem_ConstParams}
{$UNDEF MV_ArrayItem_AssignIsThreadSafe}
{$DEFINE MV_ArrayItem_CaseSensitivity}
{$DEFINE MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoUTF8StringValue - class declaration
===============================================================================}
type
  TMVAoUTF8StringValue = class(TMVAoStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoUTF8StringValue;

implementation

uses
  Math,
  BinaryStreaming, StrRect, ListSorters;

{===============================================================================
--------------------------------------------------------------------------------
                              TMVAoUTF8StringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = TMVValueArrayItemType('');
  
{===============================================================================
    TMVAoUTF8StringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoUTF8StringValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := UTF8StringCompare(TMVValueArrayItemType(A),TMVValueArrayItemType(B),Arg);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemThreadSafeAssign({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType): TMVValueArrayItemType;
begin
Result := Value;
UniqueString({$IFNDEF FPC}AnsiString{$ENDIF}(Result));
end;

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; const Value: TMVValueArrayItemType);
begin
Stream_WriteUTF8String(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_ReadUTF8String(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(const Value: TMVValueArrayItemType): String;
begin
Result := UTF8ToStr(Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := StrToUTF8(Str);
end;

{-------------------------------------------------------------------------------
    TMVAoUTF8StringValue - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtAoUTF8String;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemType: TMVArrayItemType;
begin
Result := aitUTF8String;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.StreamedSize: TMemSize;
var
  i:  Integer;
begin
Result := SizeOf(Int32);  // array length
For i := LowIndex to HighIndex do
  Inc(Result,TMemSize(4 + Length(fCurrentValue[i])));
end;

end.
