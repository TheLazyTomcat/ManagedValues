{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Array managed value of UnicodeString.

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
unit ManagedValues_AoUnicodeStringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                            TMVAoUnicodeStringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = UnicodeString;
  TMVAoUnicodeString    = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoUnicodeString;

{$DEFINE MV_ArrayItem_ConstParams}
{$UNDEF MV_ArrayItem_AssignIsThreadSafe}
{$DEFINE MV_ArrayItem_CaseSensitivity}
{$DEFINE MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoUnicodeStringValue - class declaration
===============================================================================}
type
  TMVAoUnicodeStringValue = class(TMVAoStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoUnicodeStringValue;

implementation

uses
  Math,
  BinaryStreaming, StrRect, ListSorters;

{===============================================================================
--------------------------------------------------------------------------------
                            TMVAoUnicodeStringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = TMVValueArrayItemType('');
  
{===============================================================================
    TMVAoUnicodeStringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoUnicodeStringValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtAoUnicodeString;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetArrayItemType: TMVArrayItemType;
begin
Result := aitUnicodeString;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
Result := UnicodeStringCompare(TMVValueArrayItemType(A),TMVValueArrayItemType(B),Arg);
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
Stream_WriteUnicodeString(Stream,Value);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Stream_ReadUnicodeString(Stream);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(const Value: TMVValueArrayItemType): String;
begin
Result := UnicodeToStr(Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := StrToUnicode(Str);
end;

{-------------------------------------------------------------------------------
    TMVAoUnicodeStringValue - specific public methods
-------------------------------------------------------------------------------}  

Function TMVValueClass.StreamedSize: TMemSize;
var
  i:  Integer;
begin
Result := SizeOf(Int32);  // array length
For i := LowIndex to HighIndex do
  Inc(Result,TMemSize(4 + (Length(fCurrentValue[i]) * SizeOf(UnicodeChar))));
end;

end.
