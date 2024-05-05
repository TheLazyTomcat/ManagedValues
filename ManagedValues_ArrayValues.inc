{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Implementation template for dynamic array values.

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
{!tun_end!} // ignore this line

{===============================================================================
    TMVValueClass - class declaration
===============================================================================}
{$IFDEF MV_ClassDeclaration}
  protected
    fCurrentValue:  TMVValueArrayType;
    fInitialValue:  TMVValueArrayType;
    // getters, setters
    Function GetCurrentValue: TMVValueArrayType; virtual;
    procedure SetCurrentValue(const Value: TMVValueArrayType); virtual;
    Function GetInitialValue: TMVValueArrayType; virtual;
    procedure SetInitialValue(const Value: TMVValueArrayType); virtual;
    Function GetItem(Index: Integer): TMVValueArrayItemType; virtual;
    procedure SetItem(Index: Integer;{$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType); virtual;
    Function GetCurrentValuePtr: Pointer; override;
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
    Function SortingCompare(Idx1,Idx2: Integer): Integer; virtual;
    // assignment methods
    Function ThreadSafeAssign(const Arr: TMVValueArrayType; Index: Integer; Count: Integer): TMVValueArrayType; overload; virtual;
    Function ThreadSafeAssign(const Arr: TMVValueArrayType): TMVValueArrayType; overload; virtual;
  {$IFNDEF MV_ArrayItem_AssignIsThreadSafe}
    Function ArrayItemThreadSafeAssign({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType): TMVValueArrayItemType; virtual;
  {$ENDIF}
    // streaming, string conversion
    class procedure ArrayItemStreamWrite(Stream: TStream; {$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType); virtual;
    class Function ArrayItemStreamRead(Stream: TStream): TMVValueArrayItemType; virtual;
    // following two cannot be class methods because in some instances, they use fFormatSettings field
    Function ArrayItemAsString({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType): String; virtual;
    Function ArrayItemFromString(const Str: String): TMVValueArrayItemType; virtual;
    // utility
    procedure CheckAndSetEquality; override;  
  public
    // class info
    class Function ValueType: TMVManagedValueType; override;
    class Function ArrayItemType: TMVArrayItemType; override;  
    // costructors, destructors
    constructor CreateAndInit(const Value: TMVValueArrayType); overload;
    constructor CreateAndInit(const Name: String; const Value: TMVValueArrayType); overload;
    // value manipulation
    procedure BuildFrom(const Source: array of TMVValueArrayItemType); reintroduce; virtual;
    procedure Initialize(const Value: TMVValueArrayType; OnlyValues: Boolean); reintroduce; overload; virtual;
    procedure InitialToCurrent; override;
    procedure CurrentToInitial; override;
    procedure SwapInitialAndCurrent; override;
    // public compare
    Function Compare(Value: TMVManagedValueBase{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean{$ENDIF}): Integer; reintroduce; virtual;
    Function Same(Value: TMVManagedValueBase{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean{$ENDIF}): Boolean; reintroduce; virtual;
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
    // list methods
    Function First: TMVValueArrayItemType; reintroduce; virtual;
    Function Last: TMVValueArrayItemType; reintroduce; virtual;
    Function IndexOf({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean = False{$ENDIF}): Integer; reintroduce; virtual;
    Function Add({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType): Integer; reintroduce; virtual;
    procedure Insert(Index: Integer; {$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType); reintroduce; virtual;
    procedure Exchange(Idx1,Idx2: Integer); override;
    procedure Move(SrcIdx,DstIdx: Integer); override;
    Function Remove({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean = False{$ENDIF}): Integer; reintroduce; virtual;
    procedure Delete(Index: Integer); override;
    procedure Clear; override;
    procedure Sort(Reversed: Boolean = False{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean = False{$ENDIF}); reintroduce; virtual;
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
    TMVValueClass - protected methods
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
    SetLength(fCurrentValue,0); // prevents reallocation and copying of memory
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

//------------------------------------------------------------------------------

Function TMVValueClass.GetCurrentValuePtr: Pointer;
begin
Result := Addr(fCurrentValue);
end;

//------------------------------------------------------------------------------

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

Function TMVValueClass.SortingCompare(Idx1,Idx2: Integer): Integer;
begin
If Idx1 <> Idx2 then
  Result := CompareArrayItemValues(fCurrentValue[Idx1],fCurrentValue[Idx2],fSortCompareArg)
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
Result := nil;
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
If fUpdateCounter <= 0 then
  begin
    IsEqual := SameBaseValuesCnt(fCurrentValue,fInitialValue,fCurrentCount,Length(fInitialValue),True);
    If IsEqual <> fEqualsToInitial then
      begin
        fEqualsToInitial := IsEqual;
        DoEqualsChange;
      end;
  end;
fUpdated := True;
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
SetLength(fCurrentValue,0); // prevents memory copy
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
    fCurrentValue := ThreadSafeAssign(fInitialValue);
    fCurrentCount := Length(fCurrentValue);
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
    fInitialValue := ThreadSafeAssign(fCurrentValue,Low(fCurrentValue),fCurrentCount);
    fEqualsToInitial := True;
    DoEqualsChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SwapInitialAndCurrent;
var
  Temp: TMVValueArrayType;
begin
Temp := nil;
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

Function TMVValueClass.Compare(Value: TMVManagedValueBase{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean{$ENDIF}): Integer;
begin
inherited Compare(Value);
Result := CompareBaseValues(fCurrentValue,TMVValueClass(Value).CurrentValuePtr^,
  {$IFDEF MV_ArrayItem_CaseSensitivity}CaseSensitive{$ELSE}True{$ENDIF});
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Same(Value: TMVManagedValueBase{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean{$ENDIF}): Boolean;
begin
Result := Compare(Value{$IFDEF MV_ArrayItem_CaseSensitivity},CaseSensitive{$ENDIF}) = 0;
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

{$IFNDEF MV_ArrayItem_ComplexStreamedSize}
Function TMVValueClass.StreamedSize: TMemSize;
begin
Result := SizeOf(Int32){array length} + (fCurrentCount * SizeOf(TMVValueArrayItemType));
end;
{$ENDIF}

//------------------------------------------------------------------------------

Function TMVValueClass.LowIndex: Integer;
begin
Result := Low(fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
var
  i:  Integer;
begin
Stream_WriteInt32(Stream,fCurrentCount);
For i := LowIndex to HighIndex do
  ArrayItemStreamWrite(Stream,fCurrentValue[i]);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
var
  Temp: TMVValueArrayType;
  i:    Integer;
begin
// load into temp
Temp := nil;
SetLength(Temp,Stream_GetInt32(Stream));
For i := Low(Temp) to High(Temp) do
  Temp[i] := ArrayItemStreamRead(Stream);
// assign temp
If Init then
  Initialize(Temp,False)
else
  SetCurrentValue(Temp);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
var
  Strings:  TStringList;
  i:        Integer;
begin
Strings := TStringList.Create;
try
  For i := LowIndex to HighIndex do
    Strings.Add(ArrayItemAsString(fCurrentValue[i]));
  Result := Strings.DelimitedText
finally
  Strings.Free;
end;
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
var
  Strings:  TStringList;
  i:        Integer;
begin
Strings := TStringList.Create;
try
  Strings.DelimitedText := Str;
  SetLength(fCurrentValue,0);
  SetLength(fCurrentValue,Strings.Count);
  For i := 0 to Pred(Strings.Count) do
    fCurrentValue[i] := ArrayItemFromString(Strings[i]);
  fCurrentCount := Length(fCurrentValue);
  CheckAndSetEquality;
  DoCurrentChange;
finally
  Strings.Free;
end;
inherited;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.First: TMVValueArrayItemType;
begin
Result := GetItem(LowIndex);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Last: TMVValueArrayItemType;
begin
Result := GetItem(HighIndex);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.IndexOf({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean = False{$ENDIF}): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If SameArrayItemValues(Value,fCurrentValue[i],{$IFDEF MV_ArrayItem_CaseSensitivity}CaseSensitive{$ELSE}True{$ENDIF}) then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Add({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType): Integer;
begin
Grow;
Result := fCurrentCount;
fCurrentValue[Result] := {$IFNDEF MV_ArrayItem_AssignIsThreadSafe}ArrayItemThreadSafeAssign{$ENDIF}(Value);
Inc(fCurrentCount);
CheckAndSetEquality;
DoCurrentChange;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Insert(Index: Integer; {$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    Grow;
    For i := HighIndex downto Index do
      fCurrentValue[i + 1] := fCurrentValue[i];
    fCurrentValue[Index] := {$IFNDEF MV_ArrayItem_AssignIsThreadSafe}ArrayItemThreadSafeAssign{$ENDIF}(Value);
    Inc(fCurrentCount);
    CheckAndSetEquality;
    DoCurrentChange;
  end
else If Index = fCurrentCount then
  Add(Value)
else
  raise EMVIndexOutOfBounds.CreateFmt('%s.Insert: Index (%d) out of bounds.',[Self.ClassName,Index]);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Exchange(Idx1,Idx2: Integer);
var
  Temp: TMVValueArrayItemType;
begin
If Idx1 <> Idx2 then
  begin
    If not CheckIndex(Idx1) then
      raise EMVIndexOutOfBounds.CreateFmt('%s.Exchange: Index 1 (%d) out of bounds.',[Self.ClassName,Idx1]);
    If not CheckIndex(Idx2) then
      raise EMVIndexOutOfBounds.CreateFmt('%s.Exchange: Index 2 (%d) out of bounds.',[Self.ClassName,Idx2]);
    Temp := fCurrentValue[Idx1];
    fCurrentValue[Idx1] := fCurrentValue[Idx2];
    fCurrentValue[Idx2] := Temp;
    CheckAndSetEquality;
    DoCurrentChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Move(SrcIdx,DstIdx: Integer);
var
  Temp: TMVValueArrayItemType;
  i:    Integer;
begin
If SrcIdx <> DstIdx then
  begin
    If not CheckIndex(SrcIdx) then
      raise EMVIndexOutOfBounds.CreateFmt('%s.Move: Source index (%d) out of bounds.',[Self.ClassName,SrcIdx]);
    If not CheckIndex(DstIdx) then
      raise EMVIndexOutOfBounds.CreateFmt('%s.Move: Destination index (%d) out of bounds.',[Self.ClassName,DstIdx]);    
    Temp := fCurrentValue[SrcIdx];
    If SrcIdx < DstIdx then
      For i := SrcIdx to Pred(DstIdx) do
        fCurrentValue[i] := fCurrentValue[i + 1]
    else
      For i := SrcIdx downto Succ(DstIdx) do
        fCurrentValue[i] := fCurrentValue[i - 1];
    fCurrentValue[DstIdx] := Temp;
    CheckAndSetEquality;
    DoCurrentChange;
  end;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.Remove({$IFDEF MV_ArrayItem_ConstParams}const{$ENDIF} Value: TMVValueArrayItemType{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean = False{$ENDIF}): Integer;
begin
Result := IndexOf(Value{$IFDEF MV_ArrayItem_CaseSensitivity},CaseSensitive{$ENDIF});
If CheckIndex(Result) then
  Delete(Result);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    For i := Index to Pred(HighIndex) do
      fCurrentValue[i] := fCurrentValue[i + 1];
    fCurrentValue[HighIndex] := MV_LOCAL_DEFAULT_ITEM_VALUE;
    Dec(fCurrentCount);
    Shrink;
    CheckAndSetEquality;
    DoCurrentChange;
  end
else raise EMVIndexOutOfBounds.CreateFmt('%s.Delete: Index (%d) out of bounds.',[Self.ClassName,Index]);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Clear;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fCurrentValue[i] := MV_LOCAL_DEFAULT_ITEM_VALUE;
SetLength(fCurrentValue,0);
fCurrentCount := 0;
CheckAndSetEquality;
DoCurrentChange;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Sort(Reversed: Boolean = False{$IFDEF MV_ArrayItem_CaseSensitivity}; CaseSensitive: Boolean = False{$ENDIF});
var
  Sorter: TListSorter;
begin
If fCurrentCount > 1 then
  begin
    Sorter := TListQuickSorter.Create(SortingCompare,Exchange);
    try
      fSortCompareArg := {$IFDEF MV_ArrayItem_CaseSensitivity}CaseSensitive{$ELSE}True{$ENDIF};
      Sorter.Reversed := Reversed;
      BeginUpdate;
      try
        Sorter.Sort(LowIndex,HighIndex);
      finally
        EndUpdate;
      end;
    finally
      Sorter.Free;
    end;
  end;
end;

{$ENDIF MV_ClassImplementation}
