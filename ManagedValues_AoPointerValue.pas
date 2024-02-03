{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Array managed value of Pointer.

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
unit ManagedValues_AoPointerValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAoPointerValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueArrayItemType = Pointer;
  TMVAoPointer          = array of TMVValueArrayItemType;
  TMVValueArrayType     = TMVAoPointer;

{$UNDEF MV_ArrayItem_ConstParams}
{$DEFINE MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$DEFINE MV_ArrayItem_ComplexStreamedSize}

{===============================================================================
    TMVAoPointerValue - class declaration
===============================================================================}
type
  TMVAoPointerValue = class(TMVAoOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_ArrayValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAoPointerValue;

implementation

uses
  SysUtils, Math,
  BinaryStreamingLite, ListSorters;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W4055:={$WARN 4055 OFF}} // Conversion between ordinals and pointers is not portable
  {$DEFINE W4056:={$WARN 4056 OFF}} // Conversion between ordinals and pointers is not portable
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}  

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAoPointerValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = nil;
  
{===============================================================================
    TMVAoPointerValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_ArrayValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAoPointerValue - specific protected methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W4055 W5024{$ENDIF}
class Function TMVValueClass.CompareArrayItemValues(const A,B; Arg: Boolean): Integer;
begin
If PtrUInt(TMVValueArrayItemType(A)) > PtrUInt(TMVValueArrayItemType(B)) then
  Result := +1
else If PtrUInt(TMVValueArrayItemType(A)) < PtrUInt(TMVValueArrayItemType(B)) then
  Result := -1
else
  Result := 0;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
class procedure TMVValueClass.ArrayItemStreamWrite(Stream: TStream; Value: TMVValueArrayItemType);
begin
Stream_WriteUInt64(Stream,UInt64(Value));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
class Function TMVValueClass.ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType;
begin
Result := Pointer(Stream_GetUInt64(Stream));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

Function TMVValueClass.ArrayItemAsString(Value: TMVValueArrayItemType): String;
begin
Result := Format('0x%p',[Value],fFormatSettings);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
Function TMVValueClass.ArrayItemFromString(const Str: String): TMVValueArrayItemType;
begin
Result := Pointer(StrToInt64(Str));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVAoPointerValue - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtAoPointer;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.ArrayItemType: TMVArrayItemType;
begin
Result := aitPointer;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.StreamedSize: TMemSize;
begin
Result := SizeOf(Int32){array length} + (TMemSize(fCurrentCount) * StreamedSize_UInt64);
end;

end.
