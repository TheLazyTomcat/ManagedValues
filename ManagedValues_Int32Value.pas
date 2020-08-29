{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Int32 managed value.

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
unit ManagedValues_Int32Value;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVInt32Value
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Int32;

{$UNDEF MV_Value_ConstParams}
{$DEFINE MV_Value_AssignIsThreadSafe}
{$UNDEF MV_Value_CaseSensitivity}
{$UNDEF MV_Value_ComplexStreamedSize}

{===============================================================================
    TMVInt32Value - class declaration
===============================================================================}
type
  TMVInt32Value = class(TMVIntegerManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVInt32Value;

implementation

uses
  SysUtils,
  BinaryStreaming; 

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                 TMVInt32Value
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = 0;

{===============================================================================
    TMVInt32Value - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVInt32Value - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TMVManagedValueType;
begin
Result := mvtInt32;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := Integer(TMVValueBaseType(A) - TMVValueBaseType(B));
end; 
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{-------------------------------------------------------------------------------
    TMVInt32Value - specific public methods
-------------------------------------------------------------------------------}

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteInt32(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadInt32(Stream),False)
else
  SetCurrentValue(Stream_ReadInt32(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := IntToStr(fCurrentValue);
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(StrToInt(Str));
inherited;
end;

end.
