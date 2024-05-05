{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Char managed value.

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
unit ManagedValues_CharValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                  TMVCharValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Char;

{$UNDEF MV_Value_ConstParams}
{$DEFINE MV_Value_AssignIsThreadSafe}
{$DEFINE MV_Value_CaseSensitivity}
{$DEFINE MV_Value_ComplexStreamedSize}

{===============================================================================
    TMVCharValue - class declaration
===============================================================================}
type
  TMVCharValue = class(TMVCharManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVCharValue;

implementation

uses
  BinaryStreamingLite, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                                  TMVCharValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = TMVValueBaseType(#0);

{===============================================================================
    TMVCharValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVCharValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := StringCompare(TMVValueBaseType(A),TMVValueBaseType(B),Arg);
end;

{-------------------------------------------------------------------------------
    TMVCharValue - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtChar;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.StreamedSize: TMemSize;
begin
Result := StreamedSize_Char;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteChar(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_GetChar(Stream),False)
else
  SetCurrentValue(Stream_GetChar(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := fCurrentValue;
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
If Length(Str) > 0 then
  SetCurrentValue(Str[1])
else
  SetCurrentValue(MV_LOCAL_DEFAULT_VALUE);  
inherited;
end;

end.
