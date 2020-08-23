{===============================================================================
    TMVValueClass - class declaration
===============================================================================}
{$IFDEF MV_ClassDeclaration}
  private
    fCurrentValue:  TMVValueArrayType;
    fInitialValue:  TMVValueArrayType;
    // getters, setters
    Function GetCurrentValue: TMVValueArrayType;
    procedure SetCurrentValue(const Value: TMVValueArrayType);
    Function GetInitialValue: TMVValueArrayType;
    procedure SetInitialValue(const Value: TMVValueArrayType);
    Function GetItem(Index: Integer): TMVValueArrayItemType;
    procedure SetItem(Index: Integer;{$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType);
  protected
    // class info
    class Function GetValueType: TMVManagedValueType; override;
    class Function GetArrayItemType: TMVArrayItemType; override;
    // list management
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    procedure SetCount(Value: Integer); override;
    Function GetInitialCount: Integer; override;
    // init, final
    procedure Initialize; overload; override;
    procedure Finalize; override;
    // compare methods
    class Function CompareBaseValuesCnt(const A,B; CntA,CntB: Integer; Arg: Boolean): Integer; override;
    class Function CompareBaseValues(const A,B; Arg: Boolean): Integer; override;
    class Function CompareArrayItemValues(const A,B; Arg: Boolean): Integer; override;
    Function SortingCompare(Idx1,Idx2: Integer{$IFDEF MV_ArrayItem_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Integer; virtual;
    // assignment methods
    Function ThreadSafeAssign(const Arr: TMVValueArrayType; Index: Integer; Count: Integer): TMVValueArrayType; overload; virtual;
    Function ThreadSafeAssign(const Arr: TMVValueArrayType): TMVValueArrayType; overload; virtual;
  {$IFNDEF MV_ArrayItem_AssignIsThreadSafe}
    Function ArrayItemThreadSafeAssign({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType): TMVValueArrayItemType; virtual;
  {$ENDIF}
    // utility
    procedure CheckAndSetEquality; override;  
  public
    // costructors, destructors
    constructor CreateAndInit(const Value: TMVValueArrayType); overload;
    constructor CreateAndInit(const Name: String; const Value: TMVValueArrayType); overload;
    // value manipulation
    procedure BuildFrom(const Source: array of TMVValueArrayItemType); virtual;
    procedure Initialize(const Value: TMVValueArrayType; OnlyValues: Boolean); reintroduce; overload; virtual;
    procedure InitialToCurrent; override;
    procedure CurrentToInitial; override;
    procedure SwapInitialAndCurrent; override;
    // public compare
    Function Compare(Value: TMVManagedValueBase{$IFDEF MV_ArrayItem_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Integer; virtual;
    Function Same(Value: TMVManagedValueBase{$IFDEF MV_ArrayItem_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Boolean; virtual;
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
    // index methods
    Function LowIndex: Integer; override;
    // value-specific properties
    property CurrentValue: TMVValueArrayType read GetCurrentValue write SetCurrentValue;
    property InitialValue: TMVValueArrayType read GetInitialValue write SetInitialValue;
    property Value: TMVValueArrayType read GetCurrentValue write SetCurrentValue;
    property Items[Index: Integer]: TMVValueArrayItemType read GetItem write SetItem; default;
{$ENDIF MV_ClassDeclaration}

{===============================================================================
    TMVValueClass - class implementation
===============================================================================}
{$IFDEF MV_ClassImplementation}
{-------------------------------------------------------------------------------
    TMVValueClass - private methods
-------------------------------------------------------------------------------}

Function TMVValueClass.GetCurrentValue: TMVValueArrayType;
begin
Result := ThreadSafeAssign(fCurrentValue,Low(fCurrentValue),fCurrentCount);
Inc(fReadCount);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetCurrentValue(const Value: TMVValueArrayType);
begin
If not SameBaseValuesCnt(Value,fCurrentValue,Length(Value),fCurrentCount,True) then
  begin
    SetLength(fCurrentValue,0);
    fCurrentValue := ThreadSafeAssign(Value);
    fCurrentCount := Length(fCurrentValue);
    Inc(fWriteCount);
    CheckAndSetEquality;
    DoCurrentChange;
  end;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.GetInitialValue: TMVValueArrayType;
begin
Result := ThreadSafeAssign(fInitialValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetInitialValue(const Value: TMVValueArrayType);
begin
If not SameBaseValues(Value,fInitialValue,True) then
  begin
    SetLength(fInitialValue,0);
    fInitialValue := ThreadSafeAssign(Value);
    CheckAndSetEquality;
  end;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.GetItem(Index: Integer): TMVValueArrayItemType;
begin
If CheckIndex(Index) then
  begin
    Result := {$IFNDEF MV_ArrayItem_AssignIsThreadSafe}ArrayItemThreadSafeAssign{$ENDIF}(fCurrentValue[Index]);
    Inc(fReadCount);
  end
else raise EMVIndexOutOfBounds.CreateFmt('%s.GetItem: Index (%d) out of bounds.',[Self.ClassName,Index]);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetItem(Index: Integer;{$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType);
begin
If CheckIndex(Index) then
  begin
    If not SameArrayItemValues(fCurrentValue[Index],Value,True) then
      begin
        fCurrentValue[Index] := {$IFNDEF MV_ArrayItem_AssignIsThreadSafe}ArrayItemThreadSafeAssign{$ENDIF}(Value);
        Inc(fWriteCount);
        CheckAndSetEquality;
        DoCurrentChange;
      end;
  end
else raise EMVIndexOutOfBounds.CreateFmt('%s.SetItem: Index (%d) out of bounds.',[Self.ClassName,Index]);
end;

{-------------------------------------------------------------------------------
    TMVValueClass - protected methods
-------------------------------------------------------------------------------}

Function TMVValueClass.GetCapacity: Integer;
begin
Result := Length(fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetCapacity(Value: Integer);
var
  i:  Integer;
begin
If Value >= 0 then
  begin
    If Value <> Length(fCurrentValue) then
      begin
        If Value < fCurrentCount then
          begin
            For i := Value to HighIndex do
              fCurrentValue[i] := MV_LOCAL_DEFAULT_ITEM_VALUE;
            fCurrentCount := Value;
            CheckAndSetEquality;
            DoCurrentChange;
          end;
        SetLength(fCurrentValue,Value);
      end;
  end
else raise EMVInvalidValue.CreateFmt('%.SetCapacity: Invalid capacitny (%d).',[Self.ClassName,Value]);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetCount(Value: Integer);
var
  i:  Integer;
begin
If Value >= 0 then
  begin
    If Value <> fCurrentCount then
      begin
        If Value > Capacity then
          SetCapacity(Value);
        If Value < fCurrentCount then
          begin
            // existing items are removed
            For i := Value to HighIndex do
              fCurrentValue[i] := MV_LOCAL_DEFAULT_ITEM_VALUE;
          end
        else 
          begin
            // new empty items are addded
            For i := HighIndex to Pred(Value) do
              fCurrentValue[i] := MV_LOCAL_DEFAULT_ITEM_VALUE;
          end;
        fCurrentCount := Value;
        CheckAndSetEquality;
        DoCurrentChange;
      end;
  end
else raise EMVInvalidValue.CreateFmt('%.SetCount: Invalid count (%d).',[Self.ClassName,Value]);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.GetInitialCount: Integer;
begin
Result := Length(fInitialValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Initialize;
begin
inherited;
SetLength(fCurrentValue,0);
SetLength(fInitialValue,0);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Finalize;
var
  i:  Integer;
begin
For i := Low(fCurrentValue) to High(fCurrentValue) do
  fCurrentValue[i] := MV_LOCAL_DEFAULT_ITEM_VALUE;
SetLength(fCurrentValue,0);
For i := Low(fInitialValue) to High(fInitialValue) do
  fInitialValue[i] := MV_LOCAL_DEFAULT_ITEM_VALUE;
SetLength(fInitialValue,0);
inherited;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareBaseValuesCnt(const A,B; CntA,CntB: Integer; Arg: Boolean): Integer;
var
  i:  Integer;
begin
// first compare items at common indices
For i := 0 to Pred(Min(CntA,CntB)) do
  begin
    Result := CompareArrayItemValues(TMVValueArrayType(A)[i],TMVValueArrayType(B)[i],Arg);
    If Result <> 0 then
      Exit;
  end;
// all items at common indices match, compare lengths
If CntA < CntB then
  Result := -1
else If CntA > CntB then
  Result := +1
else
  Result := 0;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
Result := CompareBaseValuesCnt(A,B,Length(TMVValueArrayType(A)),Length(TMVValueArrayType(B)),Arg);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.SortingCompare(Idx1,Idx2: Integer{$IFDEF MV_ArrayItem_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Integer;
begin
If Idx1 <> Idx2 then
  Result := CompareArrayItemValues(fCurrentValue[Idx1],fCurrentValue[Idx2],
    {$IFDEF MV_ArrayItem_StringLikeType}CaseSensitive{$ELSE}True{$ENDIF})
else
  Result := 0;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.ThreadSafeAssign(const Arr: TMVValueArrayType; Index: Integer; Count: Integer): TMVValueArrayType;
{$IFNDEF MV_ArrayItem_AssignIsThreadSafe}
var
  i:  Integer;
{$ENDIF}
begin
{$IFDEF MV_ArrayItem_AssignIsThreadSafe}
Result := Copy(Arr,Index,Count);
{$ELSE}
SetLength(Result,Count);
For i := 0 to Pred(Count) do
  Result[i] := {$IFNDEF MV_ArrayItem_AssignIsThreadSafe}ArrayItemThreadSafeAssign{$ENDIF}(Arr[Index + i]);
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TMVValueClass.ThreadSafeAssign(const Arr: TMVValueArrayType): TMVValueArrayType;
begin
Result := ThreadSafeAssign(Arr,Low(Arr),Length(Arr));
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.CheckAndSetEquality;
var
  IsEqual:  Boolean;
begin
IsEqual := SameBaseValuesCnt(fCurrentValue,fInitialValue,fCurrentCount,Length(fInitialValue),True);
If IsEqual <> fEqualsToInitial then
  begin
    fEqualsToInitial := IsEqual;
    DoEqualChange;
  end;
end;

{-------------------------------------------------------------------------------
    TMVValueClass - public methods
-------------------------------------------------------------------------------}    

constructor TMVValueClass.CreateAndInit(const Value: TMVValueArrayType);
begin
CreateAndInit('',Value);
end;

//------------------------------------------------------------------------------

constructor TMVValueClass.CreateAndInit(const Name: String; const Value: TMVValueArrayType);
begin
Create(Name);
Initialize(Value,False);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.BuildFrom(const Source: array of TMVValueArrayItemType);
var
  i:  Integer;
begin
SetLength(fCurrentValue,Length(Source));
For i := Low(Source) to High(Source) do
  fCurrentValue[i] := {$IFNDEF MV_ArrayItem_AssignIsThreadSafe}ArrayItemThreadSafeAssign{$ENDIF}(Source[i]);
fCurrentCount := Length(fCurrentValue);
CheckAndSetEquality;
DoCurrentChange;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Initialize(const Value: TMVValueArrayType; OnlyValues: Boolean);
begin
inherited Initialize(OnlyValues);
fCurrentValue := ThreadSafeAssign(Value);
fCurrentCount := Length(fCurrentValue);
fInitialValue := ThreadSafeAssign(fCurrentValue);
CheckAndSetEquality;
DoCurrentChange;
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
  Temp: TMVValueArrayType;
begin
SetLength(Temp,0);  // suppressing warnings
If not fEqualsToInitial then
  begin
    Temp := ThreadSafeAssign(fCurrentValue,Low(fCurrentValue),fCurrentCount);
    fCurrentValue := fInitialValue;
    fCurrentCount := Length(fCurrentValue);
    fInitialValue := Temp;
    DoCurrentChange;
    // no need to check equality, temp is deallocated automatically
  end;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Compare(Value: TMVManagedValueBase{$IFDEF MV_ArrayItem_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Integer;
var
  Temp: TMVValueArrayType;
begin
If Value is TMVValueClass then
  begin
    Temp := TMVValueClass(Value).CurrentValue;
    Result := CompareBaseValues(fCurrentValue,Temp,{$IFDEF MV_ArrayItem_StringLikeType}CaseSensitive{$ELSE}True{$ENDIF});
  end
else raise EMVIncompatibleClass.CreateFmt('%s.Compare: Incompatible class (%s).',[Self.ClassName,Value.ClassName]);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Same(Value: TMVManagedValueBase{$IFDEF MV_ArrayItem_StringLikeType}; CaseSensitive: Boolean{$ENDIF}): Boolean;
begin
Result := Compare(Value{$IFDEF MV_ArrayItem_StringLikeType},CaseSensitive{$ENDIF}) = 0;
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

{$IFNDEF MV_ArrayItem_ComplexStreaming}
Function TMVValueClass.SavedSize: TMemSize;
begin
Result := SizeOf(Int32){array length} + (fCurrentCount * SizeOf(TMVValueArrayItemType));
end;
{$ENDIF}

//------------------------------------------------------------------------------

Function TMVValueClass.LowIndex: Integer;
begin
Result := Low(fCurrentValue);
end;

{$ENDIF MV_ClassImplementation}
