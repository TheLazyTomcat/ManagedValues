{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    AnsiString managed value.

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
unit ManagedValues_AnsiStringValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAnsiStringValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = AnsiString;

{$DEFINE MV_Value_ConstParams}
{$UNDEF MV_Value_AssignIsThreadSafe}
{$DEFINE MV_Value_CaseSensitivity}
{$DEFINE MV_Value_ComplexStreamedSize}

{===============================================================================
    TMVAnsiStringValue - class declaration
===============================================================================}
type
  TMVAnsiStringValue = class(TMVStringManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVAnsiStringValue;

implementation

uses
  BinaryStreamingLite, StrRect;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAnsiStringValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = TMVValueBaseType('');

{===============================================================================
    TMVAnsiStringValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues_PrimitiveValues.inc'}
{$UNDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVAnsiStringValue - specific protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := AnsiStringCompare(TMVValueBaseType(A),TMVValueBaseType(B),Arg);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ThreadSafeAssign(const Value: TMVValueBaseType): TMVValueBaseType;
begin
Result := Value;
UniqueString(Result);
end;

{-------------------------------------------------------------------------------
    TMVAnsiStringValue - specific public methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.ValueType: TMVManagedValueType;
begin
Result := mvtAnsiString;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.StreamedSize: TMemSize;
begin
Result := StreamedSize_AnsiString(fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteAnsiString(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_GetAnsiString(Stream),False)
else
  SetCurrentValue(Stream_GetAnsiString(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := AnsiToStr(ThreadSafeAssign(fCurrentValue));
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(ThreadSafeAssign(StrToAnsi(Str)));
inherited;
end;

end.
