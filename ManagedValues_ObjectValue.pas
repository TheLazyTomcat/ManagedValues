{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Object managed value.

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
unit ManagedValues_ObjectValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVObjectValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = TObject;

{$UNDEF MV_Value_ConstParams}
{$DEFINE MV_Value_AssignIsThreadSafe}
{$UNDEF MV_Value_CaseSensitivity}
{$DEFINE MV_Value_ComplexStreamedSize}

{===============================================================================
    TMVObjectValue - class declaration
===============================================================================}
type
  TMVObjectValue = class(TMVOtherManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVObjectValue;

implementation

uses
  SysUtils,
  BinaryStreamingLite;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W4055:={$WARN 4055 OFF}} // Conversion between ordinals and pointers is not portable
  {$DEFINE W4056:={$WARN 4056 OFF}} // Conversion between ordinals and pointers is not portable
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVObjectValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = nil;

{===============================================================================
    TMVObjectValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVObjectValue - specific protected methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W4055 W5024{$ENDIF}
class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If PtrUInt(Pointer(TMVValueBaseType(A))) > PtrUInt(Pointer(TMVValueBaseType(B))) then
  Result := +1
else If PtrUInt(Pointer(TMVValueBaseType(A))) < PtrUInt(Pointer(TMVValueBaseType(B))) then
  Result := -1
else
  Result := 0;
end; 
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVObjectValue - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtObject;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.StreamedSize: TMemSize;
begin
Result := StreamedSize_UInt64;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUInt64(Stream,UInt64(Pointer(fCurrentValue)));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(TMVValueBaseType(Pointer(Stream_GetUInt64(Stream))),False)
else
  SetCurrentValue(TMVValueBaseType(Pointer(Stream_GetUInt64(Stream))));
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := Format('0x%p',[Pointer(fCurrentValue)],fFormatSettings);
inherited AsString;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055 W4056{$ENDIF}
procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(TMVValueBaseType(Pointer(StrToInt64(Str))));
inherited;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

end.
