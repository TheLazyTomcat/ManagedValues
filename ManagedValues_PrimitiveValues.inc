{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Implementation template for primitive-type values.

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

{===============================================================================
    TMVValueClass - class declaration
===============================================================================}
{$IFDEF MV_ClassDeclaration}
  protected
    fCurrentValue:  TMVValueBaseType;
    fInitialValue:  TMVValueBaseType;
    // getters, setters
    Function GetCurrentValue: TMVValueBaseType; virtual;
    procedure SetCurrentValue({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType); virtual;
    procedure SetInitialValue({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType); virtual;
    Function GetCurrentValuePtr: Pointer; override;
    // init, final
    procedure Initialize; override;
    // compare methods
    class Function CompareBaseValues(const A,B; Arg: Boolean): Integer; override;
    // assignment methods
  {$IFNDEF MV_Value_AssignIsThreadSafe}
    Function ThreadSafeAssign({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType): TMVValueBaseType; virtual;
  {$ENDIF}
    // utility
    procedure CheckAndSetEquality; override;
  public
    // class info
    class Function ValueType: TMVManagedValueType; override;
    // costructors, destructors
    constructor CreateAndInit({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType); overload;
    constructor CreateAndInit(const Name: String; {$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType); overload;
    // value manipulation
    procedure Initialize({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType; OnlyValues: Boolean); reintroduce; overload; virtual;
    procedure InitialToCurrent; override;
    procedure CurrentToInitial; override;
    procedure SwapInitialAndCurrent; override;
    // public compare
    Function Compare(Value: TMVManagedValueBase{$IFDEF MV_Value_CaseSensitivity}; CaseSensitive: Boolean{$ENDIF}): Integer; reintroduce; virtual;
    Function Same(Value: TMVManagedValueBase{$IFDEF MV_Value_CaseSensitivity}; CaseSensitive: Boolean{$ENDIF}): Boolean; reintroduce; virtual;
    // assigning
    procedure AssignFrom(Value: TMVManagedValueBase); override;
    procedure AssignTo(Value: TMVManagedValueBase); override;
    // streaming
    Function StreamedSize: TMemSize; override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream; Init: Boolean = False); override;
    // string conversion
    Function AsString: String; override;
    procedure FromString(const Str: String); override;
    // value-specific properties
    property CurrentValue: TMVValueBaseType read GetCurrentValue write SetCurrentValue;
    property InitialValue: TMVValueBaseType read fInitialValue write SetInitialValue;
    property Value: TMVValueBaseType read GetCurrentValue write SetCurrentValue;
{$ENDIF MV_ClassDeclaration}

{===============================================================================
    TMVValueClass - class implementation
===============================================================================}
{$IFDEF MV_ClassImplementation}
{-------------------------------------------------------------------------------
    TMVValueClass - protected methods
-------------------------------------------------------------------------------}

Function TMVValueClass.GetCurrentValue: TMVValueBaseType;
begin
Result := {$IFNDEF MV_Value_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(fCurrentValue);
Inc(fReadCount);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetCurrentValue({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
begin
If not SameBaseValues(Value,fCurrentValue,True) then
  begin
    fCurrentValue := {$IFNDEF MV_Value_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(Value);
    Inc(fWriteCount);
    CheckAndSetEquality;
    DoCurrentChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetInitialValue({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
begin
If not SameBaseValues(Value,fInitialValue,True) then
  begin
    fInitialValue := {$IFNDEF MV_Value_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(Value);
    CheckAndSetEquality;
  end;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.GetCurrentValuePtr: Pointer;
begin
Result := Addr(fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Initialize;
begin
inherited;
fCurrentValue := MV_LOCAL_DEFAULT_VALUE;
fInitialValue := MV_LOCAL_DEFAULT_VALUE;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.CheckAndSetEquality;
var
  IsEqual:  Boolean;
begin
IsEqual := SameBaseValues(fCurrentValue,fInitialValue,True);
If IsEqual <> fEqualsToInitial then
  begin
    fEqualsToInitial := IsEqual;
    DoEqualsChange;
  end;
end;

{-------------------------------------------------------------------------------
    TMVValueClass - public methods
-------------------------------------------------------------------------------}

constructor TMVValueClass.CreateAndInit({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
begin
CreateAndInit('',Value);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TMVValueClass.CreateAndInit( const Name: String; {$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
begin
Create(Name);
Initialize(Value,False);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Initialize({$IFDEF MV_Value_ConstParams}const{$ENDIF} Value: TMVValueBaseType; OnlyValues: Boolean);
begin
inherited Initialize(OnlyValues);
fCurrentValue := {$IFNDEF MV_Value_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(Value);
fInitialValue := {$IFNDEF MV_Value_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(fCurrentValue);
If not fEqualsToInitial then
  begin
    fEqualsToInitial := True;
    DoEqualsChange;
  end;
DoCurrentChange;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.InitialToCurrent;
begin
If not fEqualsToInitial then
  begin
    fCurrentValue := {$IFNDEF MV_Value_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(fInitialValue);
    fEqualsToInitial := True;
    DoEqualsChange;
    DoCurrentChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.CurrentToInitial;
begin
If not fEqualsToInitial then
  begin
    fInitialValue := {$IFNDEF MV_Value_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(fCurrentValue);
    fEqualsToInitial := True;
    DoEqualsChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SwapInitialAndCurrent;
var
  Temp: TMVValueBaseType;
begin
If not fEqualsToInitial then
  begin
    Temp := fCurrentValue;
    fCurrentValue := fInitialValue;
    fInitialValue := Temp;
    DoCurrentChange;
    // no need to check equality
  end;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Compare(Value: TMVManagedValueBase{$IFDEF MV_Value_CaseSensitivity}; CaseSensitive: Boolean{$ENDIF}): Integer;
begin
inherited Compare(Value);
Result := CompareBaseValues(fCurrentValue,TMVValueClass(Value).CurrentValuePtr^,
  {$IFDEF MV_Value_CaseSensitivity}CaseSensitive{$ELSE}True{$ENDIF});
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Same(Value: TMVManagedValueBase{$IFDEF MV_Value_CaseSensitivity}; CaseSensitive: Boolean{$ENDIF}): Boolean;
begin
Result := Compare(Value{$IFDEF MV_Value_CaseSensitivity},CaseSensitive{$ENDIF}) = 0;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.AssignFrom(Value: TMVManagedValueBase);
begin
If Value is TMVValueClass then
  SetCurrentValue(TMVValueClass(Value).CurrentValue)
else
  raise EMVIncompatibleClass.CreateFmt('%s.AssignFrom: Incompatible class (%s).',[Self.ClassName,Value.ClassName]);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.AssignTo(Value: TMVManagedValueBase);
begin
If Value is TMVValueClass then
  TMVValueClass(Value).CurrentValue := fCurrentValue
else
  raise EMVIncompatibleClass.CreateFmt('%s.AssignTo: Incompatible class (%s).',[Self.ClassName,Value.ClassName]);
end;

//------------------------------------------------------------------------------

{$IFNDEF MV_Value_ComplexStreamedSize}
Function TMVValueClass.StreamedSize: TMemSize;
begin
Result := SizeOf(TMVValueBaseType);
end;
{$ENDIF}

{$ENDIF MV_ClassImplementation}
