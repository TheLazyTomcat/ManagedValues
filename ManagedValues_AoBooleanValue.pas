unit ManagedValues_AoBooleanValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAoBooleanValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVAoBoolean = array of Boolean;

  TMVValueItemType  = Boolean;
  TMVValueArrayType = TMVAoBoolean;

{$UNDEF MV_ItemConstParams}
{$DEFINE MV_ItemAssignIsThreadSafe}
{$UNDEF MV_ItemStringLikeType}

{===============================================================================
    TMVAoBooleanValue - class declaration
===============================================================================}
type
  TMVAoBooleanValue = class(TMVAoOtherManagedValue)
  //{$DEFINE MV_ClassDeclaration}
  //  {$INCLUDE './ManagedValues_ArrayValues.inc'}
  //{$UNDEF MV_ClassDeclaration}
  (*
  private
    fCurrentValue:  TMVValueArrayTypeInternal;
    fInitialValue:  TMVValueArrayTypeInternal;
    // getters,setters
    Function GetCurrentValue: TMVValueArrayType;
    procedure SetCurrentValue(const Value: TMVValueArrayType);
    Function GetInitialValue: TMVValueArrayType;
    procedure SetInitialValue(const Value: TMVValueArrayType);
  protected
    class Function GetValueType: TManagedValueType; override;
    class Function GetItemType: TArrayItemType; override;
    Function GetCurrentCount: Integer; override;
    procedure SetCurrentCount(Value: Integer); override;
    Function GetInitialCount: Integer; override;
    procedure Initialize; override;
    procedure Finalize; override;
    class Function CompareArrays(A,B: TMVValueArrayTypeInternal; Arg: Boolean): Integer; overload; virtual;
    class Function CompareArrays(A: TMVValueArrayTypeInternal; const B: TMVValueArrayType; Arg: Boolean): Integer; overload; virtual;
    class Function CompareArrays(const A: TMVValueArrayType; B: TMVValueArrayTypeInternal; Arg: Boolean): Integer; overload; virtual;
    class Function SameArrays(A,B: TMVValueArrayTypeInternal; Arg: Boolean): Boolean; overload; virtual;
    class Function SameArrays(A: TMVValueArrayTypeInternal; const B: TMVValueArrayType; Arg: Boolean): Boolean; overload; virtual;
    class Function SameArrays(const A: TMVValueArrayType; B: TMVValueArrayTypeInternal; Arg: Boolean): Boolean; overload; virtual;
    class procedure ArrayAssignTo(var Dst: TMVValueArrayTypeInternal; const Src: TMVValueArrayType); virtual;
    class procedure ArrayAssignFrom(var Dst: TMVValueArrayType; const Src: TMVValueArrayTypeInternal); virtual;
    procedure CheckAndSetEquality; override;
    class Function CompareItemValues(const A,B; Arg: Boolean): Integer; override;
  {$IFNDEF MV_ItemAssignIsThreadSafe}
    Function ItemThreadSafeAssign({$IFDEF MV_ItemConstParams}const{$ENDIF} Value: TMVValueItemType): TMVValueItemType; virtual;
  {$ENDIF}
    Function SortingCompare(Idx1,Idx2: Integer{$IFDEF MV_ItemStringLikeType}, CaseSensitive: Boolean{$ENDIF}): Integer; virtual;
  public
    {$message 'try if open array will work (if proper overload can be called in D7)'}
    //constructor CreateAndInit(const Value: TMVValueArrayType); overload;
    //constructor CreateAndInit(const Name: String; const Value: TMVValueArrayType); overload;
    //Function LowIndex: Integer; override;
    //Function HighIndex: Integer; virtual; abstract;
    //Function CheckIndex(Index: Integer): Boolean; virtual; abstract;
    //Function Compare(Value: TManagedValueBase{$IFDEF MV_ItemStringLikeType}; CaseSensitive: Boolean{$ENDIF}): Integer; virtual;
    //Function Same(Value: TManagedValueBase{$IFDEF MV_ItemStringLikeType}; CaseSensitive: Boolean{$ENDIF}): Boolean; virtual;
    //procedure Initialize(const Value: TMVValueArrayType; OnlyValues: Boolean); reintroduce; overload; virtual;
    //procedure InitialToCurrent; override;
    //procedure CurrentToInitial; override;
    //procedure SwapInitialAndCurrent; override;
    //Function SavedSize: TMemSize; override;
    //procedure AssignFrom(Value: TManagedValueBase); override;
    //procedure AssignTo(Value: TManagedValueBase); override;
    //procedure SaveToStream(Stream: TStream); override;
    //procedure LoadFromStream(Stream: TStream; Init: Boolean = False); override;
    //Function AsString: String; override;
    //procedure FromString(const Str: String); override;      
    property CurrentValue: TMVValueArrayType read GetCurrentValue write SetCurrentValue;
    property InitialValue: TMVValueArrayType read GetInitialValue write SetInitialValue;
    property Value: TMVValueArrayType read GetCurrentValue write SetCurrentValue;
    //property Items
  *)
  end;

type
  TMVValueClass = TMVAoBooleanValue;

implementation

uses
  Math;

{===============================================================================
--------------------------------------------------------------------------------
                               TMVAoBooleanValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_ITEM_VALUE = False;
  
{===============================================================================
    TMVAoBooleanValue - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMVValueClass - private methods
-------------------------------------------------------------------------------}
(*
Function TMVValueClass.GetCurrentValue: TMVValueArrayType;
begin
ArrayAssignFrom(Result,fCurrentValue);
Inc(fReadCount);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetCurrentValue(const Value: TMVValueArrayType);
begin
If not SameArrays(Value,fCurrentValue,True) then
  begin
    ArrayAssignTo(fCurrentValue,Value);
    Inc(fWriteCount);
    CheckAndSetEquality;
    DoCurrentChange;
  end;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.GetInitialValue: TMVValueArrayType;
begin
ArrayAssignFrom(Result,fInitialValue);
Inc(fReadCount);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetInitialValue(const Value: TMVValueArrayType);
begin
If not SameArrays(Value,fInitialValue,True) then
  begin
    ArrayAssignTo(fInitialValue,Value);
    CheckAndSetEquality;
  end;
end;

{-------------------------------------------------------------------------------
    TMVValueClass - protected methods
-------------------------------------------------------------------------------}

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtAoBoolean;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.GetItemType: TArrayItemType;
begin
Result := aitBoolean;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.GetCurrentCount: Integer;
begin
Result := CDA_Count(fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.SetCurrentCount(Value: Integer);
begin
CDA_SetCount(fCurrentValue,Value);
end;

//------------------------------------------------------------------------------

Function TMVValueClass.GetInitialCount: Integer;
begin
Result := CDA_Count(fInitialValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Initialize;
begin
CDA_Init(fCurrentValue);
CDA_Init(fInitialValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.Finalize;
begin
CDA_Clear(fCurrentValue);
CDA_Clear(fInitialValue);
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareArrays(A,B: TMVValueArrayTypeInternal; Arg: Boolean): Integer;
begin
Result := CDA_Compare(A,B{$IFDEF MV_ItemStringLikeType},Arg{$ENDIF});
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class Function TMVValueClass.CompareArrays(A: TMVValueArrayTypeInternal; const B: TMVValueArrayType; Arg: Boolean): Integer;
var
  i:  Integer;
begin
// first compare items at common indices
For i := 0 to Pred(Min(CDA_Count(A),Length(B))) do
  begin
    Result := CompareItemValues(CDA_GetItemPtr(A,i)^,B[i],Arg);
    If Result <> 0 then
      Exit;
  end;
// all items at common indices match, compare lengths
If CDA_Count(A) < Length(B) then
  Result := -1
else If CDA_Count(A) > Length(B) then
  Result := +1
else
  Result := 0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class Function TMVValueClass.CompareArrays(const A: TMVValueArrayType; B: TMVValueArrayTypeInternal; Arg: Boolean): Integer;
var
  i:  Integer;
begin
// first compare items at common indices
For i := 0 to Pred(Min(Length(A),CDA_Count(B))) do
  begin
    Result := CompareItemValues(A[i],CDA_GetItemPtr(B,i)^,Arg);
    If Result <> 0 then
      Exit;
  end;
// all items at common indices match, compare lengths
If Length(A) < CDA_Count(B) then
  Result := -1
else If Length(A) > CDA_Count(B) then
  Result := +1
else
  Result := 0;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.SameArrays(A,B: TMVValueArrayTypeInternal; Arg: Boolean): Boolean;
begin
Result := CompareArrays(A,B,Arg) = 0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class Function TMVValueClass.SameArrays(A: TMVValueArrayTypeInternal; const B: TMVValueArrayType; Arg: Boolean): Boolean;
begin
Result := CompareArrays(A,B,Arg) = 0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class Function TMVValueClass.SameArrays(const A: TMVValueArrayType; B: TMVValueArrayTypeInternal; Arg: Boolean): Boolean;
begin
Result := CompareArrays(A,B,Arg) = 0;
end;

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayAssignTo(var Dst: TMVValueArrayTypeInternal; const Src: TMVValueArrayType);
var
  i:  Integer;
begin
If Length(Src) > 0 then
  begin
    CDA_SetCount(Dst,Length(Src));
    For i := Low(Src) to High(Src) do
      CDA_SetItem(Dst,i,{$IFNDEF MV_ItemAssignIsThreadSafe}ItemThreadSafeAssign{$ENDIF}(Src[i]));
  end
else CDA_SetCount(Dst,0);
end;

//------------------------------------------------------------------------------

class procedure TMVValueClass.ArrayAssignFrom(var Dst: TMVValueArrayType; const Src: TMVValueArrayTypeInternal);
var
  i:  Integer;
begin
If CDA_Count(Src) > 0 then
  begin
    SetLength(Dst,CDA_Count(Src));
    For i := CDA_Low(Src) to CDA_High(Src) do
      Dst[i] := {$IFNDEF MV_ItemAssignIsThreadSafe}ItemThreadSafeAssign{$ENDIF}(CDA_GetItem(Src,i));
  end
else SetLength(Dst,0);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.CheckAndSetEquality;
var
  IsEqual:  Boolean;
begin
IsEqual := SameArrays(fCurrentValue,fInitialValue,True);
If IsEqual <> fEqualsToInitial then
  begin
    fEqualsToInitial := IsEqual;
    DoEqualChange;
  end;
end;

//------------------------------------------------------------------------------

class Function TMVValueClass.CompareItemValues(const A,B; Arg: Boolean): Integer;
begin
If Boolean(A) and not Boolean(B) then
  Result := +1
else If not Boolean(A) and Boolean(B) then
  Result := -1
else
  Result := 0;
end;

//------------------------------------------------------------------------------

Function TMVValueClass.SortingCompare(Idx1,Idx2: Integer{$IFDEF MV_ItemStringLikeType}, CaseSensitive: Boolean{$ENDIF}): Integer;
begin
If Idx1 <> Idx2 then
  Result := CompareItemValues(CDA_GetItemPtr(fCurrentValue,Idx1)^,
    CDA_GetItemPtr(fCurrentValue,Idx2)^{$IFDEF MV_ItemStringLikeType},CaseSensitive{$ELSE},True{$ENDIF})
else
  Result := 0;
end;
*)
end.
