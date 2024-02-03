{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    UnicodeChar managed value.

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
unit ManagedValues_UnicodeCharValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                              TMVUnicodeCharValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = UnicodeChar;

{$UNDEF MV_Value_ConstParams}
{$DEFINE MV_Value_AssignIsThreadSafe}
{$DEFINE MV_Value_CaseSensitivity}
{$UNDEF MV_Value_ComplexStreamedSize}

{===============================================================================
    TMVUnicodeCharValue - class declaration
===============================================================================}
type
  TMVUnicodeCharValue = class(TMVCharManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVUnicodeCharValue;

implementation

uses
  BinaryStreamingLite, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                              TMVUnicodeCharValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = TMVValueBaseType(#0);

{===============================================================================
    TMVUnicodeCharValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVUnicodeCharValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := UnicodeStringCompare(TMVValueBaseType(A),TMVValueBaseType(B),Arg);
end;

{-------------------------------------------------------------------------------
    TMVUnicodeCharValue - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtUnicodeChar;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteUnicodeChar(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_GetUnicodeChar(Stream),False)
else
  SetCurrentValue(Stream_GetUnicodeChar(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := UnicodeToStr(fCurrentValue);
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
var
  Temp: UnicodeString;
begin
Temp := StrToUnicode(Str);
If Length(Temp) > 0 then
  SetCurrentValue(Temp[1])
else
  SetCurrentValue(MV_LOCAL_DEFAULT_VALUE);
inherited;
end;

end.
