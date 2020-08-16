{$IFDEF MV_ClassDeclaration}
  private
    fCurrentValue:  TMVValueBaseType;
    fInitialValue:  TMVValueBaseType;
    // getters,setters
    Function GetCurrentValue: TMVValueBaseType;
    procedure SetCurrentValue({$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
    procedure SetInitialValue({$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
  protected
    class Function GetValueType: TManagedValueType; override;
    procedure Initialize; override;
    Function CompareBaseValues(const A,B; Arg: Boolean): Integer; override;
    procedure CheckAndSetEquality; override;
  public
    constructor CreateAndInit({$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType); overload;
    constructor CreateAndInit(const Name: String; {$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType); overload;
    Function Compare(Value: TManagedValueBase{$IFDEF MV_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Integer; reintroduce;
    Function Same(Value: TManagedValueBase{$IFDEF MV_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Boolean; reintroduce;
    procedure Initialize({$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType; OnlyValues: Boolean); reintroduce; overload;
    procedure InitialToCurrent; override;
    procedure CurrentToInitial; override;
    procedure SwapInitialAndCurrent; override;
    Function SavedSize: TMemSize; override;
    procedure AssignFrom(Value: TManagedValueBase); override;
    procedure AssignTo(Value: TManagedValueBase); override;
    procedure SaveToStream(Stream: TStream); override;    
    procedure LoadFromStream(Stream: TStream; Init: Boolean = False); override;
    Function ToString: String; override;
    procedure FromString(const Str: String); override;
    property CurrentValue: TMVValueBaseType read GetCurrentValue write SetCurrentValue;
    property InitialValue: TMVValueBaseType read fInitialValue write SetInitialValue;
    property Value: TMVValueBaseType read GetCurrentValue write SetCurrentValue;
{$ENDIF MV_ClassDeclaration}

//==============================================================================

{$IFDEF MV_ClassImplementation}

{-------------------------------------------------------------------------------
    TMVValueClass - private methods
-------------------------------------------------------------------------------}

Function TMVValueClass.GetCurrentValue: TMVValueBaseType;
begin
Result := {$IFNDEF MV_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(fCurrentValue);
Inc(fReadCount);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetCurrentValue({$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
begin
If not SameBaseValues(Value,fCurrentValue,True) then
  begin
    fCurrentValue := {$IFNDEF MV_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(Value);
    Inc(fWriteCount);
    CheckAndSetEquality;
    DoCurrentChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetInitialValue({$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
begin
If not SameBaseValues(Value,fInitialValue,True) then
  begin
    fInitialValue := {$IFNDEF MV_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(Value);
    CheckAndSetEquality;
  end;
end;

{-------------------------------------------------------------------------------
    TMVValueClass - protected methods
-------------------------------------------------------------------------------}

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
    DoEqualChange;
  end;
end;

{-------------------------------------------------------------------------------
    TMVValueClass - public methods
-------------------------------------------------------------------------------}

constructor TMVValueClass.CreateAndInit({$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
begin
CreateAndInit('',Value);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TMVValueClass.CreateAndInit( const Name: String; {$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType);
begin
Create(Name);
Initialize(Value,False);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Compare(Value: TManagedValueBase{$IFDEF MV_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Integer;
var
  Temp: TMVValueBaseType;
begin
If Value is TMVValueClass then
  begin
    Temp := TMVValueClass(Value).CurrentValue;
    Result := CompareBaseValues(fCurrentValue,Temp,{$IFDEF MV_StringLikeType}CaseSensitive{$ELSE}True{$ENDIF});
  end
else raise EMVIncompatibleClass.CreateFmt('%s.Compare: Incompatible class (%s).',[Self.ClassName,Value.ClassName]);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Same(Value: TManagedValueBase{$IFDEF MV_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Boolean;
begin
Result := Compare(Value,{$IFDEF MV_StringLikeType}CaseSensitive{$ENDIF}) = 0;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Initialize({$IFDEF MV_ConstParams}const{$ENDIF} Value: TMVValueBaseType; OnlyValues: Boolean);
begin
inherited Initialize(OnlyValues);
fCurrentValue := {$IFNDEF MV_AssignIsThreadSafe}ThreadSafeAssign{$ENDIF}(Value);
fInitialValue := fCurrentValue;
CheckAndSetEquality;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.InitialToCurrent;
begin
SetCurrentValue(fInitialValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.CurrentToInitial;
begin
SetInitialValue(fCurrentValue);
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

{$IFNDEF MV_ComplexStreaming}
Function TMVValueClass.SavedSize: TMemSize;
begin
Result := SizeOf(TMVValueBaseType);
end;   
{$ENDIF}

//------------------------------------------------------------------------------

procedure TMVValueClass.AssignFrom(Value: TManagedValueBase);
begin
If Value is TMVValueClass then
  SetCurrentValue(TMVValueClass(Value).CurrentValue)
else
  raise EMVIncompatibleClass.CreateFmt('%s.AssignFrom: Incompatible class (%s).',[Self.ClassName,Value.ClassName]);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.AssignTo(Value: TManagedValueBase);
begin
If Value is TMVValueClass then
  TMVValueClass(Value).CurrentValue := fCurrentValue
else
  raise EMVIncompatibleClass.CreateFmt('%s.AssignTo: Incompatible class (%s).',[Self.ClassName,Value.ClassName]);
end;

{$ENDIF MV_ClassImplementation}
