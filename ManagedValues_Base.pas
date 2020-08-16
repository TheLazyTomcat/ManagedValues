unit ManagedValues_Base;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  SysUtils, Classes,
  AuxTypes, AuxClasses;

type
  EMVException = class(Exception);

  EMVInvalidValue      = class(EMVException);
  EMVIndexOutOfBounds  = class(EMVException);
  EMVIncompatibleClass = class(EMVException);
  EMVInvalidOperation  = class(EMVException);
  EMVAlreadyManaged    = class(EMVException);

{===============================================================================
--------------------------------------------------------------------------------
                               TManagedValueBase
--------------------------------------------------------------------------------
===============================================================================}
type
  TManagedValueType = (
    mvtBool,mvtInt8,mvtUInt8,mvtInt16,mvtUInt16,mvtInt32,mvtUInt32,mvtInt64,
    mvtUInt64,mvtFloat32,mvtFloat64,mvtDateTime,mvtCurrency,mvtAnsiChar,
    mvtWideChar,mvtUTF8Char,mvtUnicodeChar,mvtShortString,mvtAnsiString,
    mvtWideString,mvtUTF8String,mvtUnicodeString,mvtPointer,mvtObject);

{===============================================================================
    TManagedValueBase - class declaration
===============================================================================}
type
  TManagedValueBase = class(TCustomObject)
  protected
    fGlobalManager:           TObject;
    fLocalManager:            TObject;
    fName:                    String;
    fReadCount:               UInt64;
    fWriteCount:              UInt64;
    fEqualsToInitial:         Boolean;  // whether the current walue is equal to initial
    fFormatSettings:          TFormatSettings;
    // events
    fOnValueChangeInternal:   TNotifyEvent;
    fOnEqualsChangeInternal:  TNotifyEvent;
    fOnValueChangeEvent:      TNotifyEvent;
    fOnValueChangeCallback:   TNotifyCallback;
    fOnEqualsChangeEvent:     TNotifyEvent;
    fOnEqualsChangeCallback:  TNotifyCallback;
    // getters, setters
    class Function GetValueType: TManagedValueType; virtual; abstract;
    Function GetGloballyManaged: Boolean; virtual;
    Function GetLocallyManaged: Boolean; virtual;
    procedure Initialize; overload; virtual;
    procedure Finalize; virtual;
    procedure DoCurrentChange; virtual;
    procedure DoEqualChange; virtual;
    // utility methods
    Function CompareBaseValues(const A,B; Arg: Boolean): Integer; virtual; abstract;  // override or reintroduce for specific type
    Function SameBaseValues(const A,B; Arg: Boolean): Boolean; virtual;               // calls CompareBaseValues
    procedure ThreadSafeAssign; virtual;                                              // reintroduce is necessary if used
    procedure CheckAndSetEquality; virtual; abstract;                                 // must be overridden
    // protected properties (used by managers)
    property LocalManager: TObject read fLocalManager write fLocalManager;
    property OnValueChangeInternal: TNotifyEvent read fOnValueChangeInternal write fOnValueChangeInternal;
    property OnEqualsChangeInternal: TNotifyEvent read fOnEqualsChangeInternal write fOnEqualsChangeInternal;
  public
    constructor Create; overload;
    constructor Create(const Name: String); overload;
    constructor CreateAndLoad(Stream: TStream); overload;    
    constructor CreateAndLoad(const Name: String; Stream: TStream); overload;
    destructor Destroy; override;
    Function Compare: Integer; virtual; abstract;
    Function Same: Boolean; virtual; abstract;
    procedure Initialize(OnlyValues: Boolean); overload; virtual;
    procedure InitialToCurrent; virtual; abstract;
    procedure CurrentToInitial; virtual; abstract;
    procedure SwapInitialAndCurrent; virtual; abstract;
    Function SavedSize: TMemSize; virtual; abstract;
    procedure AssignFrom(Value: TManagedValueBase); virtual; abstract;
    procedure AssignTo(Value: TManagedValueBase); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    procedure LoadFromStream(Stream: TStream; Init: Boolean = False); virtual; abstract;
    Function ToString: String; virtual;
    procedure FromString(const Str: String); virtual;
    property ValueType: TManagedValueType read GetValueType;
    property GloballyManaged: Boolean read GetGloballyManaged;
    property LocallyManaged: Boolean read GetLocallyManaged;
    property Name: String read fName;
    property ReadCount: UInt64 read fReadCount;
    property WriteCount: UInt64 read fWriteCount;
    property EqualsToInitial: Boolean read fEqualsToInitial;
    property OnValueChangeEvent: TNotifyEvent read fOnValueChangeEvent write fOnValueChangeEvent;
    property OnValueChangeCallback: TNotifyCallback read fOnValueChangeCallback write fOnValueChangeCallback;
    property OnValueChange: TNotifyEvent read fOnValueChangeEvent write fOnValueChangeEvent;
    property OnEqualsToInitialChangeEvent: TNotifyEvent read fOnEqualsChangeEvent write fOnEqualsChangeEvent;
    property OnEqualsToInitialChangeCallback: TNotifyCallback read fOnEqualsChangeCallback write fOnEqualsChangeCallback;
    property OnEqualsToInitialChange: TNotifyEvent read fOnEqualsChangeEvent write fOnEqualsChangeEvent;
    property OnChange: TNotifyEvent read fOnValueChangeEvent write fOnValueChangeEvent;
  end;

{===============================================================================
    TManagedValueBase - derived classes groups
===============================================================================}
{
  This exists pretty much only to split large number of classes to smaller
  groups. There may be some implementation differences in the future, but right
  now all groups are the same. 
}
type
  TIntegerManagedValue = class(TManagedValueBase);
  TRealManagedValue    = class(TManagedValueBase);
  TCharManagedValue    = class(TManagedValueBase);
  TStringManagedValue  = class(TManagedValueBase);
  TOtherManagedValue   = class(TManagedValueBase);
  

{===============================================================================
--------------------------------------------------------------------------------
                              TValuesManagerBase
--------------------------------------------------------------------------------
===============================================================================}
type
  TValueManagerUpdated = (vmuValue,vmuEquals,vmuList);

  TValueManagerUpdatedSet = set of TValueManagerUpdated;

  TValueManagerStreamingEvent    = procedure(Sender: TObject; Index: Integer; var CanStream: Boolean) of object;
  TValueManagerStreamingCallback = procedure(Sender: TObject; Index: Integer; var CanStream: Boolean);

{===============================================================================
    TValuesManagerBase - class declaration
===============================================================================}
type
  TValuesManagerBase = class(TCustomListObject)
  protected
    fValues:                  array of TManagedValueBase;
    fCount:                   Integer;
    fEqualsToInit:            Boolean;
    fSearchIndex:             Integer;
    fUpdateCounter:           Integer;
    fUpdated:                 TValueManagerUpdatedSet;
    // events
    fOnValueChangeEvent:      TObjectEvent;
    fOnValueChangeCallback:   TObjectCallback;
    fOnEqualsChangeEvent:     TObjectEvent;
    fOnEqualsChangeCallback:  TObjectCallback;
    fOnChangeEvent:           TNotifyEvent;
    fOnChangeCallback:        TNotifyCallback;
    fOnStreamingEvent:        TValueManagerStreamingEvent;
    fOnStreamingCallback:     TValueManagerStreamingCallback;
    // getters, setters
    Function GetValue(Index: Integer): TManagedValueBase; virtual;
    // list management
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    procedure SetCount(Value: Integer); override;
    // events
    procedure ValueChangeHandler(Sender: TObject); virtual;
    procedure EqualsChangeHandler(Sender: TObject); virtual;
    procedure DoChange; virtual;
    procedure DoStreaming(Index: Integer; var CanStream: Boolean); virtual;
    // init/final
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    // utility
    procedure CheckAndSetEquality; virtual;
    procedure ProcessAddedValue(var Value: TManagedValueBase); virtual;
    procedure ProcessDeletedValue(var Value: TManagedValueBase); virtual;
    Function GetSortedAdditionIndex: Integer; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    procedure Lock; virtual;
    procedure Unlock; virtual;
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    // list methods
    Function IndexOf(const Name: String): Integer; overload; virtual;
    Function IndexOf(Value: TManagedValueBase): Integer; overload; virtual;
    Function FindFirst(const Name: String; out Index: Integer): Boolean; overload; virtual;
    Function FindFirst(const Name: String; out Value: TManagedValueBase): Boolean; overload; virtual;
    Function FindNext(const Name: String; out Index: Integer): Boolean; overload; virtual;
    Function FindNext(const Name: String; out Value: TManagedValueBase): Boolean; overload; virtual;
    Function Find(const Name: String; out Index: Integer): Boolean; overload; virtual;
    Function Find(const Name: String; out Value: TManagedValueBase): Boolean; overload; virtual;
    Function Find(Value: TManagedValueBase; out Index: Integer): Boolean; overload; virtual;
    Function Add(Value: TManagedValueBase): Integer; virtual;
    procedure Insert(Index: Integer; Value: TManagedValueBase); virtual;
    procedure Exchange(Idx1,Idx2: Integer); virtual;
    procedure Move(SrcIdx,DstIdx: Integer); virtual;
    Function Remove(const Name: String): Integer; overload; virtual;
    Function Remove(Value: TManagedValueBase): Integer; overload; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    procedure FreeValuesAndClear; virtual;
    // streaming
    procedure SaveToStream(Stream: TStream; StreamingEvents: Boolean = False); virtual;
    procedure LoadFromStream(Stream: TStream; Init: Boolean = False; StreamingEvents: Boolean = False); virtual;
    // properties
    property Values[Index: Integer]: TManagedValueBase read GetValue; default;
    property EqualsToInitial: Boolean read fEqualsToInit;
    property OnValueChangeEvent: TObjectEvent read fOnValueChangeEvent write fOnValueChangeEvent;
    property OnValueChangeCallback: TObjectCallback read fOnValueChangeCallback write fOnValueChangeCallback;
    property OnValueChange: TObjectEvent read fOnValueChangeEvent write fOnValueChangeEvent;
    property OnEqualsToInitialChangeEvent: TObjectEvent read fOnEqualsChangeEvent write fOnEqualsChangeEvent;
    property OnEqualsToInitialChangeCallback: TObjectCallback read fOnEqualsChangeCallback write fOnEqualsChangeCallback;
    property OnEqualsToInitialChange: TObjectEvent read fOnEqualsChangeEvent write fOnEqualsChangeEvent;
    property OnChangeEvent: TNotifyEvent read fOnChangeEvent write fOnChangeEvent;
    property OnChangeCallback: TNotifyCallback read fOnChangeCallback write fOnChangeCallback;
    property OnChange: TNotifyEvent read fOnChangeEvent write fOnChangeEvent;
  {
    Following are called for each streamed item (value) when StreamingEvents
    parameter is set to true in streaming functions.
  }
    property OnStreamingEvent: TValueManagerStreamingEvent read fOnStreamingEvent write fOnStreamingEvent;
    property OnStreamingCallback: TValueManagerStreamingCallback read fOnStreamingCallback write fOnStreamingCallback;
    property OnStreaming: TValueManagerStreamingEvent read fOnStreamingEvent write fOnStreamingEvent;
  end;

Function GetGlobalValuesManager: TValuesManagerBase;

implementation

{$IFDEF Windows}
uses
  Windows;
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                              TValuesManagerGlobal
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TValuesManagerGlobal - class declaration
===============================================================================}
type
  TValuesManagerGlobal = class(TValuesManagerBase)
  protected
    fSynchronizer:  TRTLCriticalSection;
    procedure Initialize; override;
    procedure Finalize; override;
    {$message 'impl. ordered list with binary searching'}
//    Function GetSortedAdditionIndex: Integer; override;
  public
    procedure Lock; override;
    procedure Unlock; override;
    //Function IndexOf(Value: TManagedValueBase): Integer; overload; override;    
  end;

{===============================================================================
    TValuesManagerGlobal - global variable
===============================================================================}
var
  MV_GlobalManager: TValuesManagerGlobal = nil;

//------------------------------------------------------------------------------

Function GetGlobalValuesManager: TValuesManagerBase;
begin
Result := MV_GlobalManager;
end;

{===============================================================================
    TValuesManagerGlobal - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TValuesManagerGlobal - protected methods
-------------------------------------------------------------------------------}

procedure TValuesManagerGlobal.Initialize;
begin
{$IF Defined(FPC) and not Defined(Windows)}
InitCriticalSection(fSynchronizer);
{$ELSE}
InitializeCriticalSection(fSynchronizer);
{$IFEND}
inherited;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerGlobal.Finalize;
begin
inherited;
{$IF Defined(FPC) and not Defined(Windows)}
DoneCriticalSection(fSynchronizer);
{$ELSE}
DeleteCriticalSection(fSynchronizer);
{$IFEND}
end;

{-------------------------------------------------------------------------------
    TValuesManagerGlobal - public methods
-------------------------------------------------------------------------------}

procedure TValuesManagerGlobal.Lock;
begin
EnterCriticalSection(fSynchronizer);
end;

//------------------------------------------------------------------------------

procedure TValuesManagerGlobal.Unlock;
begin
LeaveCriticalSection(fSynchronizer);
end;


{===============================================================================
--------------------------------------------------------------------------------
                               TManagedValueBase
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TManagedValueBase - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TManagedValueBase - protected methods
-------------------------------------------------------------------------------}

Function TManagedValueBase.GetGloballyManaged: Boolean;
var
  Index:  Integer;
begin
If Assigned(fGlobalManager) then
  Result := TValuesManagerBase(fGlobalManager).Find(Self,Index)
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TManagedValueBase.GetLocallyManaged: Boolean;
var
  Index:  Integer;
begin
If Assigned(fLocalManager) then
  Result := TValuesManagerBase(fLocalManager).Find(Self,Index)
else
  Result := False;
end;

//------------------------------------------------------------------------------

procedure TManagedValueBase.Initialize;
begin
fGlobalManager := MV_GlobalManager;
If Assigned(fGlobalManager) then
  TValuesManagerBase(fGlobalManager).Add(Self);
fLocalManager := nil;
// fields init
{
  Do not set the name, is is set in constructor before initialization as the
  instance must have its name before it is passed to global manager.
}
fReadCount := 0;
fWriteCount := 0;
fEqualsToInitial := True;
// format setting
{$WARN SYMBOL_PLATFORM OFF}
{$IF not Defined(FPC) and (CompilerVersion >= 18)}
// Delphi 2006+
fFormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);
{$ELSE}
// older delphi and FPC
{$IFDEF Windows}
// windows
GetLocaleFormatSettings(LOCALE_USER_DEFAULT,fFormatSettings);
{$ELSE}
// non-windows
fFormatSettings := DefaultFormatSettings;
{$ENDIF}
{$IFEND}
{$WARN SYMBOL_PLATFORM ON}
// events
fOnValueChangeInternal := nil;
fOnEqualsChangeInternal := nil;
fOnValueChangeEvent := nil;
fOnValueChangeCallback := nil;
fOnEqualsChangeEvent := nil;
fOnEqualsChangeCallback := nil;
end;

//------------------------------------------------------------------------------

procedure TManagedValueBase.Finalize;
begin
If Assigned(fGlobalManager) then
  TValuesManagerBase(fGlobalManager).Remove(Self);
end;

//------------------------------------------------------------------------------

procedure TManagedValueBase.DoCurrentChange;
begin
If Assigned(fOnValueChangeInternal) then
  fOnValueChangeInternal(Self);
If Assigned(fOnValueChangeEvent) then
  fOnValueChangeEvent(Self);
If Assigned(fOnValueChangeCallback) then
  fOnValueChangeCallback(Self);
end;

//------------------------------------------------------------------------------

procedure TManagedValueBase.DoEqualChange;
begin
If Assigned(fOnEqualsChangeInternal) then
  fOnEqualsChangeInternal(Self);
If Assigned(fOnEqualsChangeEvent) then
  fOnEqualsChangeEvent(Self);
If Assigned(fOnEqualsChangeCallback) then
  fOnEqualsChangeCallback(Self);
end;

//------------------------------------------------------------------------------

Function TManagedValueBase.SameBaseValues(const A,B; Arg: Boolean): Boolean;
begin
Result := CompareBaseValues(A,B,Arg) = 0;
end;

//------------------------------------------------------------------------------

procedure TManagedValueBase.ThreadSafeAssign;
begin
// do nothing in here
end;

{-------------------------------------------------------------------------------
    TManagedValueBase - public methods
-------------------------------------------------------------------------------}

constructor TManagedValueBase.Create;
begin
Create('');
end;

//------------------------------------------------------------------------------

constructor TManagedValueBase.Create(const Name: String);
begin
inherited Create;
If Length(Name) > 0 then
  fName := Name
else
  fName := InstanceString;
Initialize;
end;

//------------------------------------------------------------------------------

constructor TManagedValueBase.CreateAndLoad(Stream: TStream);
begin
CreateAndLoad('',Stream);
end;

//------------------------------------------------------------------------------

constructor TManagedValueBase.CreateAndLoad(const Name: String; Stream: TStream);
begin
Create(Name);
LoadFromStream(Stream,True);
end;

//------------------------------------------------------------------------------

destructor TManagedValueBase.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

procedure TManagedValueBase.Initialize(OnlyValues: Boolean);
begin
If not OnlyValues then
  begin
    fReadCount := 0;
    fWriteCount := 0;
  end;
end;

//------------------------------------------------------------------------------

Function TManagedValueBase.ToString: String;
begin
Inc(fReadCount);
end;

//------------------------------------------------------------------------------

procedure TManagedValueBase.FromString(const Str: String);
begin
Inc(fWriteCount);
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TValuesManagerBase
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TValuesManagerBase - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TValuesManagerBase - protected methods
-------------------------------------------------------------------------------}

Function TValuesManagerBase.GetValue(Index: Integer): TManagedValueBase;
begin
If CheckIndex(Index) then
  Result := fValues[Index]
else
  raise EMVIndexOutOfBounds.CreateFmt('TValuesManagerBase.GetValue: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.GetCapacity: Integer;
begin
Result := Length(fValues);
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.SetCapacity(Value: Integer);
begin
If Value >= 0 then
  begin
    If Value <> Length(fValues) then
      begin
        SetLength(fValues,Value);
        If Value < fCount then
          fCount := Value;
      end;
  end
else raise EMVInvalidValue.CreateFmt('TValuesManagerBase.SetCapacity: Invalid capacity (%d).',[Value]);
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.GetCount: Integer;
begin
Result := fCount;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.SetCount(Value: Integer);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.ValueChangeHandler(Sender: TObject);
begin
If not(Self is TValuesManagerGlobal) then
  If fUpdateCounter <= 0 then
    begin
      Include(fUpdated,vmuValue);
      If Assigned(fOnValueChangeEvent) then
        fOnValueChangeEvent(Self,Sender);
      If Assigned(fOnValueChangeCallback) then
        fOnValueChangeCallback(Self,Sender);
    end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.EqualsChangeHandler(Sender: TObject);
begin
If not(Self is TValuesManagerGlobal) then
  If fUpdateCounter <= 0 then
    begin
      CheckAndSetEquality;
      Include(fUpdated,vmuEquals);
      If Assigned(fOnEqualsChangeEvent) then
        fOnEqualsChangeEvent(Self,Sender);
      If Assigned(fOnEqualsChangeCallback) then
        fOnEqualsChangeCallback(Self,Sender);
    end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.DoChange;
begin
If not(Self is TValuesManagerGlobal) then
  If fUpdateCounter <= 0 then
    begin
      Include(fUpdated,vmuList);
      If Assigned(fOnChangeEvent) then
        fOnChangeEvent(Self);
      If Assigned(fOnChangeCallback) then
        fOnChangeCallback(Self);
    end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.DoStreaming(Index: Integer; var CanStream: Boolean);
begin
If Assigned(fOnStreamingEvent) then
  fOnStreamingEvent(Self,Index,CanStream);
If Assigned(fOnStreamingCallback) then
  fOnStreamingCallback(Self,Index,CanStream);
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Initialize;
begin
SetLength(fValues,0);
fCount := 0;
fEqualsToInit := True;
fSearchIndex := Pred(LowIndex);
fUpdateCounter := 0;
fUpdated := [];
// events
fOnValueChangeEvent := nil;
fOnValueChangeCallback := nil;
fOnEqualsChangeEvent := nil;
fOnEqualsChangeCallback := nil;
fOnChangeEvent := nil;
fOnChangeCallback := nil;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Finalize;
begin
// prevent updates on clear
fOnChangeEvent := nil;
fOnChangeCallback := nil;
Clear;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.CheckAndSetEquality;
var
  i:  Integer;
begin
If not (Self is TValuesManagerGlobal) then
  begin
    fEqualsToInit := True;
    For i := LowIndex to HighIndex do
      If not fValues[i].EqualsToInitial then
        begin
          fEqualsToInit := False;
          Break{For i};
        end;
  end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.ProcessAddedValue(var Value: TManagedValueBase);
begin
If not (Self is TValuesManagerGlobal) then
  begin
    Value.LocalManager := Self;
    Value.OnValueChangeInternal := ValueChangeHandler;
    Value.OnEqualsChangeInternal := EqualsChangeHandler;
  end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.ProcessDeletedValue(var Value: TManagedValueBase);
begin
Value.LocalManager := nil;
Value.OnValueChangeInternal := nil;
Value.OnEqualsChangeInternal := nil;
If Self is TValuesManagerGlobal then
  FreeAndNil(Value);
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.GetSortedAdditionIndex: Integer;
begin
Result := fCount;
end;

{-------------------------------------------------------------------------------
    TValuesManagerBase - public methods
-------------------------------------------------------------------------------}

constructor TValuesManagerBase.Create;
begin
inherited Create;
Initialize;
end;

//------------------------------------------------------------------------------

destructor TValuesManagerBase.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.LowIndex: Integer;
begin
Lock;
try
  Result := Low(fValues);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.HighIndex: Integer;
begin
Lock;
try
  Result := Pred(fCount);
finally
  Unlock;
end;  
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Lock;
begin
// do nothing in this class
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Unlock;
begin
// do nothing in this class
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.BeginUpdate;
begin
If not (Self is TValuesManagerGlobal) then
  begin
    If fUpdateCounter <= 0 then
      fUpdated := [];
    Inc(fUpdateCounter);
  end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.EndUpdate;
begin
If not (Self is TValuesManagerGlobal) then
  begin
    Dec(fUpdateCounter);
    If fUpdateCounter <= 0 then
      begin
        fUpdateCounter := 0;
        If vmuValue in fUpdated then
          ValueChangeHandler(nil);
        If vmuEquals in fUpdated then
          EqualsChangeHandler(nil);
        If vmuList in fUpdated then
          DoChange;
        fUpdated := [];
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.IndexOf(const Name: String): Integer;
var
  i:  Integer;
begin
Lock;
try
  Result := -1;
  For i := LowIndex to HighIndex do
    If AnsiSameText(Name,fValues[i].Name) then
      begin
        Result := i;
        Break{For i};
      end;
finally
  Unlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TValuesManagerBase.IndexOf(Value: TManagedValueBase): Integer;
var
  i:  Integer;
begin
Lock;
try
  Result := -1;
  For i := LowIndex to HighIndex do
    If Value = fValues[i] then
      begin
        Result := i;
        Break{For i};
      end;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.FindFirst(const Name: String; out Index: Integer): Boolean;
begin
Lock;
try
  fSearchIndex := Pred(LowIndex);
  Result := FindNext(Name,Index);
finally
  Unlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TValuesManagerBase.FindFirst(const Name: String; out Value: TManagedValueBase): Boolean;
begin
Lock;
try
  fSearchIndex := Pred(LowIndex);
  Result := FindNext(Name,Value);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.FindNext(const Name: String; out Index: Integer): Boolean;
var
  i:  Integer;
begin
Lock;
try
  Result := False;
  For i := Succ(fSearchIndex) to HighIndex do
    If AnsiSameText(Name,fValues[i].Name) then
      begin
        Index := i;
        fSearchIndex := i;
        Result := True;
        Break{For i};
      end;
finally
  Unlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TValuesManagerBase.FindNext(const Name: String; out Value: TManagedValueBase): Boolean;
var
  Index:  Integer;
begin
Lock;
try
  If FindNext(Name,Index) then
    Value := fValues[Index]
  else
    Value := nil;
  Result := Assigned(Value);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.Find(const Name: String; out Index: Integer): Boolean;
begin
Lock;
try
  Index := IndexOf(Name);
  Result := CheckIndex(Index);
finally
  Unlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TValuesManagerBase.Find(const Name: String; out Value: TManagedValueBase): Boolean;
var
  Index:  Integer;
begin
Lock;
try
  Index := IndexOf(Name);
  Result := CheckIndex(Index);
  If Result then
    Value := fValues[Index]
  else
    Value := nil;
finally
  Unlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TValuesManagerBase.Find(Value: TManagedValueBase; out Index: Integer): Boolean;
begin
Lock;
try
  Index := IndexOf(Value);
  Result := CheckIndex(Index);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.Add(Value: TManagedValueBase): Integer;
var
  i:  Integer;
begin
Lock;
try
  Result := IndexOf(Value);
  If not CheckIndex(Result) then
    begin
      // value must not be already locally managed elsewhere
      If not Value.LocallyManaged or (Self is TValuesManagerGlobal) then
        begin
          Grow;
          Result := GetSortedAdditionIndex;
          For i := HighIndex downto Result do
            fValues[i + 1] := fValues[i];
          fValues[Result] := Value;
          ProcessAddedValue(Value);
          Inc(fCount);
          CheckAndSetEquality;
          DoChange;
        end
      else raise EMVAlreadyManaged.CreateFmt('TValuesManagerBase.Add: Value %s is already managed.',[Value.InstanceString]);
    end;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Insert(Index: Integer; Value: TManagedValueBase);
var
  Idx,i:  Integer;
begin
Lock;
try
  If not(Self is TValuesManagerGlobal) then
    begin
      Idx := IndexOf(Value);
      If not CheckIndex(Idx) then
        begin
          If not Value.LocallyManaged then
            begin
              If CheckIndex(Index) then
                begin
                  Grow;
                  For i := HighIndex downto Index do
                    fValues[i + 1] := fValues[i];
                  fValues[Index] := Value;
                  ProcessAddedValue(Value);
                  Inc(fCount);
                  CheckAndSetEquality;
                  DoChange;
                end
              else If Index = fCount then
                Add(Value)
              else
                raise EMVIndexOutOfBounds.CreateFmt('TValuesManagerBase.Insert: Index (%d) out of bounds.',[Index]);
            end
          else raise EMVAlreadyManaged.CreateFmt('TValuesManagerBase.Insert: Value %s is already managed.',[Value.InstanceString]);
        end;
    end
  else raise EMVInvalidOperation.Create('TValuesManagerBase.Insert: Invalid operation.');
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Exchange(Idx1,Idx2: Integer);
var
  Temp: TManagedValueBase;
begin
Lock;
try
  If not(Self is TValuesManagerGlobal) then
    begin
      If Idx1 <> Idx2 then
        begin
          If not CheckIndex(Idx1) then
            raise EMVIndexOutOfBounds.CreateFmt('TValuesManagerBase.Exchange: Index 1 (%d) out of bounds.',[Idx1]);
          If not CheckIndex(Idx2) then
            raise EMVIndexOutOfBounds.CreateFmt('TValuesManagerBase.Exchange: Index 2 (%d) out of bounds.',[Idx2]);
          Temp := fValues[Idx1];
          fValues[Idx1] := fValues[Idx2];
          fValues[Idx2] := Temp;
          DoChange;
        end
    end
  else raise EMVInvalidOperation.Create('TValuesManagerBase.Exchange: Invalid operation.');
finally
  Unlock;
end;    
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Move(SrcIdx,DstIdx: Integer);
var
  Temp: TManagedValueBase;
  i:    Integer;
begin
Lock;
try
  If not(Self is TValuesManagerGlobal) then
    begin
      If SrcIdx <> DstIdx then
        begin
          If not CheckIndex(SrcIdx) then
            raise EMVIndexOutOfBounds.CreateFmt('TValuesManagerBase.Move: Source index (%d) out of bounds.',[SrcIdx]);
          If not CheckIndex(DstIdx) then
            raise EMVIndexOutOfBounds.CreateFmt('TValuesManagerBase.Move: Destination index (%d) out of bounds.',[DstIdx]);
          Temp := fValues[SrcIdx];
          If SrcIdx < DstIdx then
            For i := SrcIdx to Pred(DstIdx) do
              fValues[i] := fValues[i + 1]
          else
            For i := SrcIdx downto Succ(DstIdx) do
              fValues[i] := fValues[i - 1];
          fValues[DstIdx] := Temp;
          DoChange;
        end
    end
  else raise EMVInvalidOperation.Create('TValuesManagerBase.Move: Invalid operation.');
finally
  Unlock;
end;    
end;

//------------------------------------------------------------------------------

Function TValuesManagerBase.Remove(const Name: String): Integer;
begin
Lock;
try
  Result := IndexOf(Name);
  If CheckIndex(Result) then
    Delete(Result);
finally
  Unlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TValuesManagerBase.Remove(Value: TManagedValueBase): Integer;
begin
Lock;
try
  Result := IndexOf(Value);
  If CheckIndex(Result) then
    Delete(Result);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Delete(Index: Integer);
var
  i:  Integer;
begin
Lock;
try
  If CheckIndex(Index) then
    begin
      ProcessDeletedValue(fValues[Index]);
      For i := Index to Pred(HighIndex) do
        fValues[i] := fValues[i + 1];
      fValues[HighIndex] := nil;
      Dec(fCount);
      CheckAndSetEquality;
      Shrink;
      DoChange;
    end
  else raise EMVIndexOutOfBounds.CreateFmt('TValuesManagerBase.Delete: Index (%d) out of bounds.',[Index]);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.Clear;
var
  i:  Integer;
begin
Lock;
try
  For i := LowIndex to HighIndex do
    ProcessDeletedValue(fValues[i]);
  SetLength(fValues,0);
  fCount := 0;
  fEqualsToInit := True;
  DoChange;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.FreeValuesAndClear;
var
  i:  Integer;
begin
Lock;
try
  For i := LowIndex to HighIndex do
    begin
      ProcessDeletedValue(fValues[i]);
      If not(Self is TValuesManagerGlobal) then
        FreeandNil(fValues[i]);
    end;
  SetLength(fValues,0);
  fCount := 0;
  fEqualsToInit := True;
  DoChange;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.SaveToStream(Stream: TStream; StreamingEvents: Boolean = False);
var
  i:          Integer;
  CanStream:  Boolean;
begin
For i := lowIndex to HighIndex do
  begin
    CanStream := True;
    If StreamingEvents then
      DoStreaming(i,CanStream);
    If CanStream then
      fValues[i].SaveToStream(Stream);
  end;
end;

//------------------------------------------------------------------------------

procedure TValuesManagerBase.LoadFromStream(Stream: TStream; Init: Boolean = False; StreamingEvents: Boolean = False);
var
  i:          Integer;
  CanStream:  Boolean;
begin
For i := lowIndex to HighIndex do
  begin
    CanStream := True;
    If StreamingEvents then
      DoStreaming(i,CanStream);
    If CanStream then
      fValues[i].LoadFromStream(Stream,Init);
  end;
end;


{===============================================================================
    Unit initialization/finalization
===============================================================================}
{$IFDEF MV_GlobalManager}
initialization
  MV_GlobalManager := TValuesManagerGlobal.Create;

finalization
  FreeAndNil(MV_GlobalManager);
{$ENDIF}

end.
