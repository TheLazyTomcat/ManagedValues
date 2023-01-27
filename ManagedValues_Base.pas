{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Managed Values

    Implementation base (classes, types, functions, constants, ...).

    Global values manager is also implemented and managed in this unit.

  Version 1.0.1 alpha (2020-08-30) - requires extensive testing

  Last changed 2023-01-26

  ©2020-2023 František Milt

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
    AuxClasses         - github.com/TheLazyTomcat/Lib.AuxClasses
    AuxTypes           - github.com/TheLazyTomcat/Lib.AuxTypes    
    BinaryStreaming    - github.com/TheLazyTomcat/Lib.BinaryStreaming
    ListSorters        - github.com/TheLazyTomcat/Lib.ListSorters
    StaticMemoryStream - github.com/TheLazyTomcat/Lib.StaticMemoryStream   
    StrRect            - github.com/TheLazyTomcat/Lib.StrRect
    UInt64Utils        - github.com/TheLazyTomcat/Lib.UInt64Utils   

===============================================================================}
unit ManagedValues_Base;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  SysUtils, Classes,
  AuxTypes, AuxClasses;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W3031:={$WARN 3031 OFF}} // Values in enumeration types have to be ascending
{$ENDIF}

{===============================================================================
    Exceptions
===============================================================================}
type
  EMVException = class(Exception);

  EMVInvalidValue      = class(EMVException);
  EMVIndexOutOfBounds  = class(EMVException);
  EMVIncompatibleClass = class(EMVException);
  EMVInvalidOperation  = class(EMVException);
  EMVAlreadyManaged    = class(EMVException);

{===============================================================================
--------------------------------------------------------------------------------
                              TMVManagedValueBase
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVManagedValueType = (
    // primitive values  - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    mvtBoolean,mvtInt8,mvtUInt8,mvtInt16,mvtUInt16,mvtInt32,mvtUInt32,mvtInt64,
    mvtUInt64,mvtFloat32,mvtFloat64,mvtDateTime,mvtCurrency,mvtAnsiChar,
    mvtUTF8Char,mvtWideChar,mvtUnicodeChar,mvtChar,mvtShortString,mvtAnsiString,
    mvtUTF8String,mvtWideString,mvtUnicodeString,mvtString,mvtPointer,mvtObject,
    mvtGUID,

    // array values  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    mvtAoBoolean,mvtAoInt8,mvtAoUInt8,mvtAoInt16,mvtAoUInt16,mvtAoInt32,
    mvtAoUInt32,mvtAoInt64,mvtAoUInt64,mvtAoFloat32,mvtAoFloat64,mvtAoDateTime,
    mvtAoCurrency,mvtAoAnsiChar,mvtAoUTF8Char,mvtAoWideChar,mvtAoUnicodeChar,
    mvtAoChar,mvtAoShortString,mvtAoAnsiString,mvtAoUTF8String,mvtAoWideString,
    mvtAoUnicodeString,mvtAoString,mvtAoPointer,mvtAoObject,mvtAoGUID,

  {$IFDEF FPCDWM}{$PUSH}W3031{$ENDIF}
    // primitive value aliases - - - - - - - - - - - - - - - - - - - - - - - - -
    mvtBool = mvtBoolean,
    mvtShortInt = mvtInt8,
    mvtByte = mvtUInt8,
    mvtSmalInt = mvtInt16,
    mvtWord = mvtUInt16,
    mvtDWord = mvtUInt32,
    mvtQWord = mvtUInt64, mvtQuadWord = mvtUInt64,
    mvtSingle = mvtFloat32,
    mvtDouble = mvtFloat64, mvtFloat = mvtFloat64, mvtReal = mvtFloat64,
    mvtDate = mvtDateTime,
    mvtTime = mvtDateTime,

    // size-dependent primitive value aliases  - - - - - - - - - - - - - - - - -  
        {$IF SizeOf(LongInt) = 4}mvtLongInt = mvtInt32,
    {$ELSEIF SizeOf(LongInt) = 8}mvtLongInt = mvtInt64,
    {$ELSE}{$MESSAGE FATAL 'Unssuported size of LongInt type.'}{$IFEND}
        {$IF SizeOf(LongWord) = 4}mvtLongWord = mvtUInt32,
    {$ELSEIF SizeOf(LongWord) = 8}mvtLongWord = mvtUInt64,
    {$ELSE}{$MESSAGE FATAL 'Unssuported size of LongWord type.'}{$IFEND}
        {$IF SizeOf(Integer) = 2}mvtInteger = mvtInt16,
    {$ELSEIF SizeOf(Integer) = 4}mvtInteger = mvtInt32,
    {$ELSEIF SizeOf(Integer) = 8}mvtInteger = mvtInt64,
    {$ELSE}{$MESSAGE FATAL 'Unssuported size of Integer type.'}{$IFEND}
        {$IF SizeOf(Cardinal) = 2}mvtCardinal = mvtUInt16,
    {$ELSEIF SizeOf(Cardinal) = 4}mvtCardinal = mvtUInt32,
    {$ELSEIF SizeOf(Cardinal) = 8}mvtCardinal = mvtUInt64,
    {$ELSE}{$MESSAGE FATAL 'Unssuported size of Cardinal type.'}{$IFEND}
  {$IF SizeOf(Pointer) = 4}
    mvtPtrInt = mvtInt32, mvtPtrUInt = mvtUInt32, mvtNativeInt = mvtInt32,
    mvtNativeUInt = mvtUInt32,
  {$ELSEIF SizeOf(Pointer) = 8}
    mvtPtrInt = mvtInt64, mvtPtrUInt = mvtUInt64, mvtNativeInt = mvtInt64,
    mvtNativeUInt = mvtUInt64,
  {$ELSE}{$MESSAGE FATAL 'Unssuported CPU architecture.'}{$IFEND}
  
    // array value aliases - - - - - - - - - - - - - - - - - - - - - - - - - - -
    mvtAoBool = mvtAoBoolean, mvtArrayOfBoolean = mvtAoBoolean, mvtArraOfBool = mvtAoBoolean,
    mvtArrayOfInt8 = mvtAoInt8, mvtAoShortInt = mvtAoInt8, mvtArrayOfShortInt = mvtAoInt8,
    mvtArrayOfUInt8 = mvtAoUInt8, mvtAoByte = mvtAoUInt8, mvtArrayOfByte = mvtAoUInt8,
    mvtArrayOfInt16 = mvtAoInt16, mvtAoSmallInt = mvtAoInt16, mvtArrayOfSmallInt = mvtAoInt16,
    mvtArrayOfUInt16 = mvtAoUInt16, mvtAoWord = mvtAoUInt16, mvtArrayOfWord = mvtAoUInt16,
    mvtArrayOfInt32 = mvtAoInt32,
    mvtArrayOfUInt32 = mvtAoUInt32, mvtAoDWord = mvtAoUInt32, mvtArrayOfDWord = mvtAoUInt32,
    mvtArrayOfInt64 = mvtAoInt64,
    mvtArrayOfUInt64 = mvtAoUInt64, mvtAoQword = mvtAoUInt64, mvtArrayOfQword = mvtAoUInt64,
      mvtAoQuadWord = mvtAoUInt64, mvtArrayOfQuadWord = mvtAoUInt64,
    mvtArrayOfFloat32 = mvtAoFloat32, mvtAoSingle = mvtAoFloat32, mvtArrayOfSingle = mvtAoFloat32,
    mvtArrayOfFloat64 = mvtAoFloat64, mvtAoDouble = mvtAoFloat64, mvtArrayOfDouble = mvtAoFloat64,
      mvtAoFloat = mvtAoFloat64, mvtArrayOfFloat = mvtAoFloat64, mvtAoReal = mvtAoFloat64,
      mvtArrayOfReal = mvtAoFloat64,
    mvtArrayOfDateTime = mvtAoDateTime, mvtAoDate = mvtAoDateTime, mvtArrayOfDate = mvtAoDateTime,
      mvtAoTime = mvtAoDateTime, mvtArrayOfTime = mvtAoDateTime,
    mvtArrayOfCurrency = mvtAoCurrency,
    mvtArrayOfAnsiChar = mvtAoAnsiChar,
    mvtArrayOfUTF8Char = mvtAoUTF8Char,
    mvtArrayOfWideChar = mvtAoWideChar,
    mvtArrayOfUnicodeChar = mvtAoUnicodeChar,
    mvtArrayOfChar = mvtAoChar,
    mvtArrayOfShortString = mvtAoShortString,
    mvtArrayOfAnsiString = mvtAoAnsiString,
    mvtArrayOfUTF8String = mvtAoUTF8String,
    mvtArrayOfWideString = mvtAoWideString,
    mvtArrayOfUnicodeString = mvtAoUnicodeString,
    mvtArrayOfString = mvtAoString,
    mvtArrayOfPointer = mvtAoPointer,
    mvtArrayOfObject = mvtAoObject,
    mvtArrayOfGUID = mvtAoGUID,

    // size-dependent array value aliases  - - - - - - - - - - - - - - - - - - - 
        {$IF SizeOf(LongInt) = 4}mvtAoLongInt = mvtAoInt32, mvtArrayOfLongInt = mvtAoInt32,
    {$ELSEIF SizeOf(LongInt) = 8}mvtAoLongInt = mvtAoInt64, mvtArrayOfLongInt = mvtAoInt64,
    {$ELSE}{$MESSAGE FATAL 'Unssuported size of LongInt type.'}{$IFEND}
        {$IF SizeOf(LongWord) = 4}mvtAoLongWord = mvtAoUInt32, mvtArrayOfLongWord = mvtAoUInt32,
    {$ELSEIF SizeOf(LongWord) = 8}mvtAoLongWord = mvtAoUInt64, mvtArrayOfLongWord = mvtAoUInt64,
    {$ELSE}{$MESSAGE FATAL 'Unssuported size of LongWord type.'}{$IFEND}
        {$IF SizeOf(Integer) = 2}mvtAoInteger = mvtAoInt16, mvtArrayOfInteger = mvtAoInt16,
    {$ELSEIF SizeOf(Integer) = 4}mvtAoInteger = mvtAoInt32, mvtArrayOfInteger = mvtAoInt32,
    {$ELSEIF SizeOf(Integer) = 8}mvtAoInteger = mvtAoInt64, mvtArrayOfInteger = mvtAoInt64,
    {$ELSE}{$MESSAGE FATAL 'Unssuported size of Integer type.'}{$IFEND}
        {$IF SizeOf(Cardinal) = 2}mvtAoCardinal = mvtAoUInt16, mvtArrayOfCardinal = mvtAoUInt16,
    {$ELSEIF SizeOf(Cardinal) = 4}mvtAoCardinal = mvtAoUInt32, mvtArrayOfCardinal = mvtAoUInt32,
    {$ELSEIF SizeOf(Cardinal) = 8}mvtAoCardinal = mvtAoUInt64, mvtArrayOfCardinal = mvtAoUInt64,
    {$ELSE}{$MESSAGE FATAL 'Unssuported size of Cardinal type.'}{$IFEND}
  {$IF SizeOf(Pointer) = 4}
    mvtAoPtrInt = mvtAoInt32, mvtArrayOfPtrInt = mvtAoInt32,
    mvtAoPtrUInt = mvtAoUInt32, mvtArrayOfPtrUInt = mvtAoUInt32,
    mvtAoNativeInt = mvtAoInt32, mvtArrayOfNativeInt = mvtAoInt32,
    mvtAoNativeUInt = mvtAoUInt32, mvtArrayOfNativeUInt = mvtAoUInt32
  {$ELSEIF SizeOf(Pointer) = 8}
    mvtAoPtrInt = mvtAoInt64, mvtArrayOfPtrInt = mvtAoInt64,
    mvtAoPtrUInt = mvtAoUInt64, mvtArraOfPtrUInt = mvtAoUInt64,
    mvtAoNativeInt = mvtAoInt64, mvtArrayOfNativeInt = mvtAoInt64,
    mvtAoNativeUInt = mvtAoUInt64, mvtArrayOfNativeUInt = mvtAoUInt64
  {$ELSE}{$MESSAGE FATAL 'Unssuported CPU architecture.'}{$IFEND}
  {$IFDEF FPCDWM}{$POP}{$ENDIF});

{===============================================================================
    TMVManagedValueBase - class declaration
===============================================================================}
type
  TMVManagedValueBase = class(TCustomObject)
  protected
    fGlobalManager:           TObject;
    fLocalManager:            TObject;
    fName:                    String;
    fReadCount:               UInt64;
    fWriteCount:              UInt64;
    fEqualsToInitial:         Boolean;
    fFormatSettings:          TFormatSettings;
    // events
    fOnValueChangeInternal:   TNotifyEvent;
    fOnEqualsChangeInternal:  TNotifyEvent;
    fOnValueChangeEvent:      TNotifyEvent;
    fOnValueChangeCallback:   TNotifyCallback;
    fOnEqualsChangeEvent:     TNotifyEvent;
    fOnEqualsChangeCallback:  TNotifyCallback;
    // getters, setters
    Function GetCurrentValuePtr: Pointer; virtual; abstract;
    Function GetGloballyManaged: Boolean; virtual;
    Function GetLocallyManaged: Boolean; virtual;
    // init/final
    procedure Initialize; overload; virtual;
    procedure Finalize; virtual;
    // event calls
    procedure DoCurrentChange; virtual;
    procedure DoEqualsChange; virtual;
    // compare methods
    class Function CompareBaseValues(const A,B; Arg: Boolean): Integer; virtual; abstract;  // override or reintroduce for specific type
    class Function SameBaseValues(const A,B; Arg: Boolean): Boolean; virtual;               // calls CompareBaseValues
    // auxiliary methods (pretty much macro methods)
    procedure CheckAndSetEquality; virtual; abstract;                                       // must be overridden
    // protected properties (mostly used by managers)
    property CurrentValuePtr: Pointer read GetCurrentValuePtr;
    property LocalManager: TObject read fLocalManager write fLocalManager;
    property OnValueChangeInternal: TNotifyEvent read fOnValueChangeInternal write fOnValueChangeInternal;
    property OnEqualsChangeInternal: TNotifyEvent read fOnEqualsChangeInternal write fOnEqualsChangeInternal;
  public
    // class info
    class Function ValueType: TMVManagedValueType; virtual; abstract;
    // constructors, destructors
    constructor Create; overload;
    constructor Create(const Name: String); overload;
    constructor CreateAndLoad(Stream: TStream); overload;
    constructor CreateAndLoad(const Name: String; Stream: TStream); overload;
    destructor Destroy; override;
    // value manipulation
    procedure Initialize(OnlyValues: Boolean); overload; virtual;
    procedure InitialToCurrent; virtual; abstract;
    procedure CurrentToInitial; virtual; abstract;
    procedure SwapInitialAndCurrent; virtual; abstract;
    // public compare
    Function Compare(Value: TMVManagedValueBase): Integer; virtual;
    Function Same(Value: TMVManagedValueBase): Boolean; virtual;
    // assigning
    procedure AssignFrom(Value: TMVManagedValueBase); virtual; abstract;
    procedure AssignTo(Value: TMVManagedValueBase); virtual; abstract;
    procedure Assign(Value: TMVManagedValueBase); virtual;
    // streaming
    Function StreamedSize: TMemSize; virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    procedure LoadFromStream(Stream: TStream; Init: Boolean = False); virtual; abstract;
    // string conversion
    Function AsString: String; virtual;
    procedure FromString(const Str: String); virtual;
    // properties
    property GloballyManaged: Boolean read GetGloballyManaged;
    property LocallyManaged: Boolean read GetLocallyManaged;
    property Name: String read fName;
    property ReadCount: UInt64 read fReadCount;
    property WriteCount: UInt64 read fWriteCount;
    property EqualsToInitial: Boolean read fEqualsToInitial;  // indicates whether the current walue is equal to initial
    // event properties
    property OnValueChangeEvent: TNotifyEvent read fOnValueChangeEvent write fOnValueChangeEvent;
    property OnValueChangeCallback: TNotifyCallback read fOnValueChangeCallback write fOnValueChangeCallback;
    property OnValueChange: TNotifyEvent read fOnValueChangeEvent write fOnValueChangeEvent;
    property OnEqualsToInitialChangeEvent: TNotifyEvent read fOnEqualsChangeEvent write fOnEqualsChangeEvent;
    property OnEqualsToInitialChangeCallback: TNotifyCallback read fOnEqualsChangeCallback write fOnEqualsChangeCallback;
    property OnEqualsToInitialChange: TNotifyEvent read fOnEqualsChangeEvent write fOnEqualsChangeEvent;
    property OnChangeEvent: TNotifyEvent read fOnValueChangeEvent write fOnValueChangeEvent;
    property OnChangeCallback: TNotifyCallback read fOnValueChangeCallback write fOnValueChangeCallback;
    property OnChange: TNotifyEvent read fOnValueChangeEvent write fOnValueChangeEvent;
  end;

{===============================================================================
    TMVManagedValueBase - derived classes groups
===============================================================================}
{
  This exists pretty much only to split large number of classes to smaller
  groups and give it some order. There may be some implementation differences
  in the future, but right now all groups are the same.
}
type
  TMVIntegerManagedValue = class(TMVManagedValueBase);
  TMVRealManagedValue    = class(TMVManagedValueBase);
  TMVCharManagedValue    = class(TMVManagedValueBase);
  TMVStringManagedValue  = class(TMVManagedValueBase);
  TMVOtherManagedValue   = class(TMVManagedValueBase);

  TMVComplexManagedValue = class(TMVManagedValueBase);

{===============================================================================
--------------------------------------------------------------------------------
                              TMVArrayManagedValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVArrayItemType = (aitBoolean,aitInt8,aitUInt8,aitInt16,aitUInt16,aitInt32,
    aitUInt32,aitInt64,aitUInt64,aitFloat32,aitFloat64,aitDateTime,aitCurrency,
    aitAnsiChar,aitWideChar,aitUTF8Char,aitUnicodeChar,aitChar,aitShortString,
    aitAnsiString,aitUTF8String,aitWideString,aitUnicodeString,aitString,
    aitPointer,aitObject,aitGUID);

{===============================================================================
    TMVArrayManagedValue - class declaration
===============================================================================}
type
  TMVArrayManagedValue = class(TMVComplexManagedValue)
  protected
    // initial array has capacity equal to count, current array is counted
    fListDelegate:    TCustomListObject;
    fCurrentCount:    Integer;
    fUpdateCounter:   Integer;
    fUpdated:         Boolean;
    fSortCompareArg:  Boolean;
    // list management (eg. growing)
    Function GetCapacity: Integer; virtual; abstract;
    procedure SetCapacity(Value: Integer); virtual; abstract;
    Function GetCount: Integer; virtual;
    procedure SetCount(Value: Integer); virtual; abstract;
    Function GetInitialCount: Integer; virtual; abstract;
    procedure Grow; virtual;
    procedure Shrink; virtual;
    // init/final
    procedure Initialize; overload; override;
    procedure Finalize; override;
    // event calls
    procedure DoCurrentChange; override;
    procedure DoEqualsChange; override;
    // compare methods
    class Function CompareBaseValuesCnt(const A,B; CntA,CntB: Integer; Arg: Boolean): Integer; virtual; abstract;
    class Function SameBaseValuesCnt(const A,B; CntA,CntB: Integer; Arg: Boolean): Boolean; virtual;
    class Function CompareArrayItemValues(const A,B; Arg: Boolean): Integer; virtual; abstract;
    class Function SameArrayItemValues(const A,B; Arg: Boolean): Boolean; virtual;
  public
    // class info
    class Function ArrayItemType: TMVArrayItemType; virtual; abstract;
    // array building
    procedure BuildFrom; virtual;
    // updating
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    // index methods
    Function LowIndex: Integer; virtual; abstract;                              
    Function HighIndex: Integer; virtual;
    Function CheckIndex(Index: Integer): Boolean; virtual;
    // list methods
    procedure First; virtual;
    procedure Last; virtual;
    procedure IndexOf; virtual;
    procedure Add; virtual;
    procedure Insert; virtual;
    procedure Exchange(Idx1,Idx2: Integer); virtual; abstract;
    procedure Move(SrcIdx,DstIdx: Integer); virtual; abstract;
    procedure Remove; virtual;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure Clear; virtual; abstract;
    procedure Sort; virtual;
    // properties common to all arrays
    property CurrentCapacity: Integer read GetCapacity write SetCapacity;
    property CurrentCount: Integer read GetCount write SetCount;
    property InitialCount: Integer read GetInitialCount;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
  end;

{===============================================================================
    TMVArrayManagedValue - derived classes groups
===============================================================================}

type
  TMVAoIntegerManagedValue = class(TMVArrayManagedValue);
  TMVAoRealManagedValue    = class(TMVArrayManagedValue);
  TMVAoCharManagedValue    = class(TMVArrayManagedValue);
  TMVAoStringManagedValue  = class(TMVArrayManagedValue);
  TMVAoOtherManagedValue   = class(TMVArrayManagedValue);

{===============================================================================
--------------------------------------------------------------------------------
                              TMVValuesManagerBase                              
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueManagerUpdated = (vmuValue,vmuEquals,vmuList);  // only used internally

  TMVValueManagerUpdatedSet = set of TMVValueManagerUpdated;

  TMVStreamingEvent    = procedure(Sender: TObject; Index: Integer; var CanStream: Boolean) of object;
  TMVStreamingCallback = procedure(Sender: TObject; Index: Integer; var CanStream: Boolean);

{===============================================================================
    TMVValuesManagerBase - class declaration
===============================================================================}
type
  TMVValuesManagerBase = class(TCustomListObject)
  protected
    fValues:                  array of TMVManagedValueBase;
    fCount:                   Integer;
    fEqualsToInit:            Boolean;
    fSearchIndex:             Integer;
    fUpdateCounter:           Integer;
    fUpdated:                 TMVValueManagerUpdatedSet;
    // events
    fOnValueChangeEvent:      TObjectEvent;
    fOnValueChangeCallback:   TObjectCallback;
    fOnEqualsChangeEvent:     TObjectEvent;
    fOnEqualsChangeCallback:  TObjectCallback;
    fOnChangeEvent:           TNotifyEvent;
    fOnChangeCallback:        TNotifyCallback;
    fOnStreamingEvent:        TMVStreamingEvent;
    fOnStreamingCallback:     TMVStreamingCallback;
    // getters, setters
    Function GetValue(Index: Integer): TMVManagedValueBase; virtual;
    Function GetReadCount: UInt64; virtual;
    Function GetWriteCount: UInt64; virtual;
    // list management
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    procedure SetCount(Value: Integer); override;
    // event calls and handlers
    procedure ValueChangeHandler(Sender: TObject); virtual;
    procedure EqualsChangeHandler(Sender: TObject); virtual;
    procedure DoChange; virtual;
    procedure DoStreaming(Index: Integer; var CanStream: Boolean); virtual;
    // init/final
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    // utility
    procedure CheckAndSetEquality; virtual;
    procedure ProcessAddedValue(var Value: TMVManagedValueBase); virtual;
    procedure ProcessDeletedValue(var Value: TMVManagedValueBase; CanBeFreed: Boolean); virtual;
    Function GetAdditionIndex(Addition: TMVManagedValueBase): Integer; virtual;
    procedure DeleteInternal(Index: Integer; CanFree: Boolean = True); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Lock; virtual;
    procedure Unlock; virtual;
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    // list methods
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    Function IndexOf(const Name: String): Integer; overload; virtual;
    Function IndexOf(Value: TMVManagedValueBase): Integer; overload; virtual;
    Function FindFirst(const Name: String; out Index: Integer): Boolean; overload; virtual;
    Function FindFirst(const Name: String; out Value: TMVManagedValueBase): Boolean; overload; virtual;
    Function FindNext(const Name: String; out Index: Integer): Boolean; overload; virtual;
    Function FindNext(const Name: String; out Value: TMVManagedValueBase): Boolean; overload; virtual;
    Function Find(const Name: String; out Index: Integer): Boolean; overload; virtual;
    Function Find(const Name: String; out Value: TMVManagedValueBase): Boolean; overload; virtual;
    Function Find(Value: TMVManagedValueBase; out Index: Integer): Boolean; overload; virtual;
    Function Add(Value: TMVManagedValueBase): Integer; virtual;
    procedure Insert(Index: Integer; Value: TMVManagedValueBase); virtual;
    procedure Exchange(Idx1,Idx2: Integer); virtual;
    procedure Move(SrcIdx,DstIdx: Integer); virtual;
    Function Extract(const Name: String): TMVManagedValueBase; overload; virtual;
    Function Extract(Value: TMVManagedValueBase): TMVManagedValueBase; overload; virtual;
    Function Remove(const Name: String): Integer; overload; virtual;
    Function Remove(Value: TMVManagedValueBase): Integer; overload; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    procedure FreeValuesAndClear; virtual;
    // streaming
    procedure SaveToStream(Stream: TStream; StreamingEvents: Boolean = False); virtual;
    procedure LoadFromStream(Stream: TStream; Init: Boolean = False; StreamingEvents: Boolean = False); virtual;
    // properties
    property Values[Index: Integer]: TMVManagedValueBase read GetValue; default;
    property EqualsToInitial: Boolean read fEqualsToInit;
    property ReadCount: UInt64 read GetReadCount;
    property WriteCount: UInt64 read GetWriteCount;
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
    property OnStreamingEvent: TMVStreamingEvent read fOnStreamingEvent write fOnStreamingEvent;
    property OnStreamingCallback: TMVStreamingCallback read fOnStreamingCallback write fOnStreamingCallback;
    property OnStreaming: TMVStreamingEvent read fOnStreamingEvent write fOnStreamingEvent;
  end;

{===============================================================================
    Public auxiliary functions - declaration
===============================================================================}

Function GetGlobalValuesManager: TMVValuesManagerBase;

{$UNDEF FPCDWM}

implementation

uses
  {$IFDEF Windows}Windows,{$ENDIF} Math;

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W4055:={$WARN 4055 OFF}} // Conversion between ordinals and pointers is not portable
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                             TMVValuesManagerGlobal
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMVValuesManagerGlobal - class declaration
===============================================================================}
type
  TMVValuesManagerGlobal = class(TMVValuesManagerBase)
  protected
    fSynchronizer:  TRTLCriticalSection;
    fLockReady:     Boolean;
    procedure ValueChangeHandler(Sender: TObject); override;
    procedure EqualsChangeHandler(Sender: TObject); override;
    procedure DoChange; override;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure CheckAndSetEquality; override;
    procedure ProcessAddedValue(var Value: TMVManagedValueBase); override;
    procedure ProcessDeletedValue(var Value: TMVManagedValueBase; CanBeFreed: Boolean); override;
    class Function CompareObjects(A,B: TMVManagedValueBase): Integer; virtual;
    Function GetAdditionIndex(Addition: TMVManagedValueBase): Integer; override;
  public
    procedure Lock; override;
    procedure Unlock; override;
    procedure BeginUpdate; override;
    procedure EndUpdate; override;
    Function IndexOf(Value: TMVManagedValueBase): Integer; override;
    procedure Insert(Index: Integer; Value: TMVManagedValueBase); override;
    procedure Exchange(Idx1,Idx2: Integer); override;
    procedure Move(SrcIdx,DstIdx: Integer); override;
  end;

{===============================================================================
    TMVValuesManagerGlobal - global variable
===============================================================================}
var
  MVGlobalManager: TMVValuesManagerGlobal = nil;

{===============================================================================
    TMVValuesManagerGlobal - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMVValuesManagerGlobal - protected methods
-------------------------------------------------------------------------------}

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVValuesManagerGlobal.ValueChangeHandler(Sender: TObject);
begin
// do nothing
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVValuesManagerGlobal.EqualsChangeHandler(Sender: TObject);
begin
// do nothing
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TMVValuesManagerGlobal.DoChange;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerGlobal.Initialize;
begin
{$IF Defined(FPC) and not Defined(Windows)}
InitCriticalSection(fSynchronizer);
{$ELSE}
InitializeCriticalSection(fSynchronizer);
{$IFEND}
fLockReady := True;
inherited;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerGlobal.Finalize;
begin
inherited;
If fLockReady then
{$IF Defined(FPC) and not Defined(Windows)}
  DoneCriticalSection(fSynchronizer);
{$ELSE}
  DeleteCriticalSection(fSynchronizer);
{$IFEND}
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerGlobal.CheckAndSetEquality;
begin
// do nothing
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVValuesManagerGlobal.ProcessAddedValue(var Value: TMVManagedValueBase);
begin
// do nothing
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TMVValuesManagerGlobal.ProcessDeletedValue(var Value: TMVManagedValueBase; CanBeFreed: Boolean);
begin
inherited ProcessDeletedValue(Value,CanBeFreed);
If CanBeFreed then
  FreeAndNil(Value);
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W4055{$ENDIF}
class Function TMVValuesManagerGlobal.CompareObjects(A,B: TMVManagedValueBase): Integer;
begin
If PtrUInt(Pointer(A)) > PtrUInt(Pointer(B)) then
  Result := +1
else If PtrUInt(Pointer(A)) < PtrUInt(Pointer(B)) then
  Result := -1
else
  Result := 0;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

Function TMVValuesManagerGlobal.GetAdditionIndex(Addition: TMVManagedValueBase): Integer;
var
  L,C,R:  Integer;  // left, center, right
begin
If fCount > 0 then
  begin
    L := LowIndex;
    R := HighIndex;
    C := (L + R) shr 1; // just to suppress warnings
    while L <= R do     // this must be true at least once when count > 0
      begin
        C := (L + R) shr 1;
        case Sign(CompareObjects(fValues[C],Addition)) of
          -1: L := Succ(C); // center is "smaller" than addition
          +1: begin         // center is "bigger" than addition
                R := Pred(C);
                Dec(C);
              end;
        else
          Break{while};
        end;
      end;
    Result := Succ(C);  
  end
else Result := 0;
end;

{-------------------------------------------------------------------------------
    TMVValuesManagerGlobal - public methods
-------------------------------------------------------------------------------}

procedure TMVValuesManagerGlobal.Lock;
begin
If fLockReady then
  EnterCriticalSection(fSynchronizer);
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerGlobal.Unlock;
begin
If fLockReady then
  LeaveCriticalSection(fSynchronizer);
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerGlobal.BeginUpdate;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerGlobal.EndUpdate;
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerGlobal.IndexOf(Value: TMVManagedValueBase): Integer;
var
  L,C,R:  Integer;
begin
Lock;
try
  If fCount > 25 then   // use binary searching only on larger lists
    begin
      Result := -1;
      L := LowIndex;
      R := HighIndex;
      while L <= R do
        begin
          C := (L + R) shr 1;
          case Sign(CompareObjects(fValues[C],Value)) of
            -1: L := Succ(C);
            +1: R := Pred(C);
          else
            Result := C;
            Break{while};
          end;
        end;
    end
  else Result := inherited IndexOf(Value);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVValuesManagerGlobal.Insert(Index: Integer; Value: TMVManagedValueBase);
begin
raise EMVInvalidOperation.Create('TMVValuesManagerGlobal.Insert: Invalid operation.');
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVValuesManagerGlobal.Exchange(Idx1,Idx2: Integer);
begin
raise EMVInvalidOperation.Create('TMVValuesManagerGlobal.Exchange: Invalid operation.');
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVValuesManagerGlobal.Move(SrcIdx,DstIdx: Integer);
begin
raise EMVInvalidOperation.Create('TMVValuesManagerGlobal.Move: Invalid operation.');
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

{===============================================================================
    Public auxiliary functions - implementation
===============================================================================}

Function GetGlobalValuesManager: TMVValuesManagerBase;
begin
Result := MVGlobalManager;
end;


{===============================================================================
--------------------------------------------------------------------------------
                               TMVManagedValueBase
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMVManagedValueBase - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMVManagedValueBase - protected methods
-------------------------------------------------------------------------------}

Function TMVManagedValueBase.GetGloballyManaged: Boolean;
var
  Index:  Integer;
begin
If Assigned(fGlobalManager) then
  Result := TMVValuesManagerBase(fGlobalManager).Find(Self,Index)
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TMVManagedValueBase.GetLocallyManaged: Boolean;
var
  Index:  Integer;
begin
If Assigned(fLocalManager) then
  Result := TMVValuesManagerBase(fLocalManager).Find(Self,Index)
else
  Result := False;
end;

//------------------------------------------------------------------------------

procedure TMVManagedValueBase.Initialize;
begin
fGlobalManager := MVGlobalManager;
If Assigned(fGlobalManager) then
  TMVValuesManagerBase(fGlobalManager).Add(Self);
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

procedure TMVManagedValueBase.Finalize;
begin
If Assigned(fLocalManager) then
  TMVValuesManagerBase(fLocalManager).Remove(Self);
If Assigned(fGlobalManager) then
  TMVValuesManagerBase(fGlobalManager).Extract(Self);
end;

//------------------------------------------------------------------------------

procedure TMVManagedValueBase.DoCurrentChange;
begin
If Assigned(fOnValueChangeInternal) then
  fOnValueChangeInternal(Self);
If Assigned(fOnValueChangeEvent) then
  fOnValueChangeEvent(Self)
else If Assigned(fOnValueChangeCallback) then
  fOnValueChangeCallback(Self);
end;

//------------------------------------------------------------------------------

procedure TMVManagedValueBase.DoEqualsChange;
begin
If Assigned(fOnEqualsChangeInternal) then
  fOnEqualsChangeInternal(Self);
If Assigned(fOnEqualsChangeEvent) then
  fOnEqualsChangeEvent(Self)
else If Assigned(fOnEqualsChangeCallback) then
  fOnEqualsChangeCallback(Self);
end;

//------------------------------------------------------------------------------

class Function TMVManagedValueBase.SameBaseValues(const A,B; Arg: Boolean): Boolean;
begin
Result := CompareBaseValues(A,B,Arg) = 0;
end;

{-------------------------------------------------------------------------------
    TMVManagedValueBase - public methods
-------------------------------------------------------------------------------}

constructor TMVManagedValueBase.Create;
begin
Create('');
end;

//------------------------------------------------------------------------------

constructor TMVManagedValueBase.Create(const Name: String);
begin
inherited Create;
If Length(Name) > 0 then
  fName := Name
else
  fName := InstanceString;
Initialize;
end;

//------------------------------------------------------------------------------

constructor TMVManagedValueBase.CreateAndLoad(Stream: TStream);
begin
CreateAndLoad('',Stream);
end;

//------------------------------------------------------------------------------

constructor TMVManagedValueBase.CreateAndLoad(const Name: String; Stream: TStream);
begin
Create(Name);
LoadFromStream(Stream,True);
end;

//------------------------------------------------------------------------------

destructor TMVManagedValueBase.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

procedure TMVManagedValueBase.Initialize(OnlyValues: Boolean);
begin
If not OnlyValues then
  begin
    fReadCount := 0;
    fWriteCount := 0;
  end;
end;

//------------------------------------------------------------------------------

Function TMVManagedValueBase.Compare(Value: TMVManagedValueBase): Integer;
begin
Result := 0;
If not(Value is Self.ClassType) then
  raise EMVIncompatibleClass.CreateFmt('TMVManagedValueBase.Compare: Incompatible class (%s).',[Value.ClassName]);
end;

//------------------------------------------------------------------------------

Function TMVManagedValueBase.Same(Value: TMVManagedValueBase): Boolean;
begin
Result := Compare(Value) = 0;
end;

//------------------------------------------------------------------------------

procedure TMVManagedValueBase.Assign(Value: TMVManagedValueBase);
begin
AssignFrom(Value);
end;

//------------------------------------------------------------------------------

Function TMVManagedValueBase.AsString: String;
begin
Inc(fReadCount);
Result := '';
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVManagedValueBase.FromString(const Str: String);
begin
Inc(fWriteCount);
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}


{===============================================================================
--------------------------------------------------------------------------------
                              TMVArrayListDelegate
--------------------------------------------------------------------------------
===============================================================================}
{
  Small class delegated to list management in array values.
}
{===============================================================================
    TMVArrayListDelegate - class declaration
===============================================================================}
type
  TMVArrayListDelegate = class(TCustomListObject)
  protected
    fArrayValue:  TMVArrayManagedValue;
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    procedure SetCount(Value: Integer); override;
  public
    constructor Create(ArrayValue: TMVArrayManagedValue);
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    procedure Grow(MinDelta: Integer = 1); override;  // only to heighten visibility
    procedure Shrink; override;
  end;

{===============================================================================
    TMVArrayListDelegate - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMVArrayListDelegate - protected methods
-------------------------------------------------------------------------------}

Function TMVArrayListDelegate.GetCapacity: Integer;
begin
Result := fArrayValue.GetCapacity;
end;

//------------------------------------------------------------------------------

procedure TMVArrayListDelegate.SetCapacity(Value: Integer);
begin
fArrayValue.SetCapacity(Value);
end;

//------------------------------------------------------------------------------

Function TMVArrayListDelegate.GetCount: Integer;
begin
Result := fArrayValue.GetCount;
end;

//------------------------------------------------------------------------------

procedure TMVArrayListDelegate.SetCount(Value: Integer);
begin
fArrayValue.SetCount(Value);
end;

{-------------------------------------------------------------------------------
    TMVArrayListDelegate - public methods
-------------------------------------------------------------------------------}

constructor TMVArrayListDelegate.Create(ArrayValue: TMVArrayManagedValue);
begin
inherited Create;
fArrayValue := ArrayValue;
end;

//------------------------------------------------------------------------------

Function TMVArrayListDelegate.LowIndex: Integer;
begin
Result := fArrayValue.LowIndex;
end;

//------------------------------------------------------------------------------

Function TMVArrayListDelegate.HighIndex: Integer;
begin
Result := fArrayValue.HighIndex;
end;

//------------------------------------------------------------------------------

procedure TMVArrayListDelegate.Grow(MinDelta: Integer = 1);
begin
inherited Grow(MinDelta);
end;

//------------------------------------------------------------------------------

procedure TMVArrayListDelegate.Shrink;
begin
inherited Shrink;
end;


{===============================================================================
--------------------------------------------------------------------------------
                              TMVArrayManagedValue                              
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMVArrayManagedValue - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMVArrayManagedValue - protected methods
-------------------------------------------------------------------------------}

Function TMVArrayManagedValue.GetCount: Integer;
begin
Result := fCurrentCount;
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Grow;
begin
TMVArrayListDelegate(fListDelegate).Grow;
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Shrink;
begin
TMVArrayListDelegate(fListDelegate).Shrink;
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Initialize;
begin
fListDelegate := TMVArrayListDelegate.Create(Self);
inherited;
fCurrentCount := 0;
fSortCompareArg := True;
fUpdateCounter := 0;
fUpdated := False;
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Finalize;
begin
fCurrentCount := 0;
inherited;
FreeAndNil(fListDelegate);
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.DoCurrentChange;
begin
If fUpdateCounter <= 0 then
  inherited DoCurrentChange;
fUpdated := True;
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.DoEqualsChange;
begin
If fUpdateCounter <= 0 then
  inherited DoEqualsChange;
fUpdated := True;
end;

//------------------------------------------------------------------------------

class Function TMVArrayManagedValue.SameBaseValuesCnt(const A,B; CntA,CntB: Integer; Arg: Boolean): Boolean;
begin
Result := CompareBaseValuesCnt(A,B,CntA,CntB,Arg) = 0;
end;

//------------------------------------------------------------------------------

class Function TMVArrayManagedValue.SameArrayItemValues(const A,B; Arg: Boolean): Boolean;
begin
Result := CompareArrayItemValues(A,B,Arg) = 0;
end;

{-------------------------------------------------------------------------------
    TMVArrayManagedValue - public methods
-------------------------------------------------------------------------------}

procedure TMVArrayManagedValue.BuildFrom;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.BeginUpdate;
begin
If fUpdateCounter <= 0 then
  fUpdated := False;
Inc(fUpdateCounter);
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.EndUpdate;
begin
Dec(fUpdateCounter);
If fUpdateCounter <= 0 then
  begin
    fUpdateCounter := 0;
    If fUpdated then
      begin
        CheckAndSetEquality;
        DoCurrentChange;
      end;
    fUpdated := False;
  end;
end;

//------------------------------------------------------------------------------

Function TMVArrayManagedValue.HighIndex: Integer;
begin
Result := Pred(fCurrentCount);
end;

//------------------------------------------------------------------------------

Function TMVArrayManagedValue.CheckIndex(Index: Integer): Boolean;
begin
Result := fListDelegate.CheckIndex(Index);
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.First;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Last;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.IndexOf;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Add;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Insert;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Remove;
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TMVArrayManagedValue.Sort;
begin
// do nothing
end;

{===============================================================================
--------------------------------------------------------------------------------
                              TMVValuesManagerBase
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TMVValuesManagerBase - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TMVValuesManagerBase - protected methods
-------------------------------------------------------------------------------}

Function TMVValuesManagerBase.GetValue(Index: Integer): TMVManagedValueBase;
begin
If CheckIndex(Index) then
  Result := fValues[Index]
else
  raise EMVIndexOutOfBounds.CreateFmt('TMVValuesManagerBase.GetValue: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.GetReadCount: UInt64;
var
  i:  Integer;
begin
Result := 0;
For i := LowIndex to HighIndex do
  Result := Result + fValues[i].ReadCount;
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.GetWriteCount: UInt64;
var
  i:  Integer;
begin
Result := 0;
For i := LowIndex to HighIndex do
  Result := Result + fValues[i].WriteCount;
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.GetCapacity: Integer;
begin
Result := Length(fValues);
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.SetCapacity(Value: Integer);
var
  i:  Integer;
begin
If Value >= 0 then
  begin
    If Value <> Length(fValues) then
      begin
        If Value < fCount then
          begin
            For i := Value to HighIndex do
              ProcessDeletedValue(fValues[i],True);
            fCount := Value;
          end;
        SetLength(fValues,Value);
      end;
  end
else raise EMVInvalidValue.CreateFmt('TMVValuesManagerBase.SetCapacity: Invalid capacity (%d).',[Value]);
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.GetCount: Integer;
begin
Result := fCount;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVValuesManagerBase.SetCount(Value: Integer);
begin
// do nothing
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.ValueChangeHandler(Sender: TObject);
begin
Include(fUpdated,vmuValue);
If fUpdateCounter <= 0 then
  begin
    If Assigned(fOnValueChangeEvent) then
      fOnValueChangeEvent(Self,Sender)
    else If Assigned(fOnValueChangeCallback) then
      fOnValueChangeCallback(Self,Sender);
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.EqualsChangeHandler(Sender: TObject);
begin
Include(fUpdated,vmuEquals);
If fUpdateCounter <= 0 then
  begin
    If (Sender as TMVManagedValueBase).EqualsToInitial then
      CheckAndSetEquality
    else
      fEqualsToInit := False;
    If Assigned(fOnEqualsChangeEvent) then
      fOnEqualsChangeEvent(Self,Sender)
    else If Assigned(fOnEqualsChangeCallback) then
      fOnEqualsChangeCallback(Self,Sender);
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.DoChange;
begin
Include(fUpdated,vmuList);
If fUpdateCounter <= 0 then
  begin
    If Assigned(fOnChangeEvent) then
      fOnChangeEvent(Self)
    else If Assigned(fOnChangeCallback) then
      fOnChangeCallback(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.DoStreaming(Index: Integer; var CanStream: Boolean);
begin
If Assigned(fOnStreamingEvent) then
  fOnStreamingEvent(Self,Index,CanStream)
else If Assigned(fOnStreamingCallback) then
  fOnStreamingCallback(Self,Index,CanStream);
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.Initialize;
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
fOnStreamingEvent := nil;
fOnStreamingCallback := nil;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.Finalize;
begin
// prevent updates on clear
fOnChangeEvent := nil;
fOnChangeCallback := nil;
Clear;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.CheckAndSetEquality;
var
  i:  Integer;
begin
fEqualsToInit := True;
For i := LowIndex to HighIndex do
  If not fValues[i].EqualsToInitial then
    begin
      fEqualsToInit := False;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.ProcessAddedValue(var Value: TMVManagedValueBase);
begin
Value.LocalManager := Self;
Value.OnValueChangeInternal := ValueChangeHandler;
Value.OnEqualsChangeInternal := EqualsChangeHandler;
end;

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
procedure TMVValuesManagerBase.ProcessDeletedValue(var Value: TMVManagedValueBase; CanBeFreed: Boolean);
begin
Value.LocalManager := nil;
Value.OnValueChangeInternal := nil;
Value.OnEqualsChangeInternal := nil;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}
Function TMVValuesManagerBase.GetAdditionIndex(Addition: TMVManagedValueBase): Integer;
begin
Result := fCount;
end;
{$IFDEF FPCDWM}{$POP}{$ENDIF}

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.DeleteInternal(Index: Integer; CanFree: Boolean = True);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    ProcessDeletedValue(fValues[Index],CanFree);
    For i := Index to Pred(HighIndex) do
      fValues[i] := fValues[i + 1];
    fValues[HighIndex] := nil;
    Dec(fCount);
    CheckAndSetEquality;
    Shrink;
    DoChange;
  end
else raise EMVIndexOutOfBounds.CreateFmt('TMVValuesManagerBase.DeleteInternal: Index (%d) out of bounds.',[Index]);
end;

{-------------------------------------------------------------------------------
    TMVValuesManagerBase - public methods
-------------------------------------------------------------------------------}

constructor TMVValuesManagerBase.Create;
begin
inherited Create;
Initialize;
end;

//------------------------------------------------------------------------------

destructor TMVValuesManagerBase.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.Lock;
begin
// do nothing in this class
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.Unlock;
begin
// do nothing in this class
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.BeginUpdate;
begin
Lock;
try
  If fUpdateCounter <= 0 then
    fUpdated := [];
  Inc(fUpdateCounter);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.EndUpdate;
begin
Lock;
try
  Dec(fUpdateCounter);
  If fUpdateCounter <= 0 then
    begin
      fUpdateCounter := 0;
      If vmuList in fUpdated then
        DoChange;
      If vmuEquals in fUpdated then
        EqualsChangeHandler(nil);
      If vmuValue in fUpdated then
        ValueChangeHandler(nil);
      fUpdated := [];
    end;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.LowIndex: Integer;
begin
Lock;
try
  Result := Low(fValues);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.HighIndex: Integer;
begin
Lock;
try
  Result := Pred(fCount);
finally
  Unlock;
end;  
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.IndexOf(const Name: String): Integer;
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

Function TMVValuesManagerBase.IndexOf(Value: TMVManagedValueBase): Integer;
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

Function TMVValuesManagerBase.FindFirst(const Name: String; out Index: Integer): Boolean;
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

Function TMVValuesManagerBase.FindFirst(const Name: String; out Value: TMVManagedValueBase): Boolean;
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

Function TMVValuesManagerBase.FindNext(const Name: String; out Index: Integer): Boolean;
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

Function TMVValuesManagerBase.FindNext(const Name: String; out Value: TMVManagedValueBase): Boolean;
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

Function TMVValuesManagerBase.Find(const Name: String; out Index: Integer): Boolean;
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

Function TMVValuesManagerBase.Find(const Name: String; out Value: TMVManagedValueBase): Boolean;
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

Function TMVValuesManagerBase.Find(Value: TMVManagedValueBase; out Index: Integer): Boolean;
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

Function TMVValuesManagerBase.Add(Value: TMVManagedValueBase): Integer;
var
  i:  Integer;
begin
Lock;
try
  Result := IndexOf(Value);
  If not CheckIndex(Result) then
    begin
      // value must not be already locally managed elsewhere
      If not Value.LocallyManaged or (Self is TMVValuesManagerGlobal) then
        begin
          Grow;
          Result := GetAdditionIndex(Value);
          For i := HighIndex downto Result do
            fValues[i + 1] := fValues[i];
          fValues[Result] := Value;
          ProcessAddedValue(Value);
          Inc(fCount);
          CheckAndSetEquality;
          DoChange;
        end
      else raise EMVAlreadyManaged.CreateFmt('TMVValuesManagerBase.Add: Value %s is already managed elsewhere.',[Value.InstanceString]);
    end;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.Insert(Index: Integer; Value: TMVManagedValueBase);
var
  Idx,i:  Integer;
begin
Lock;
try
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
            raise EMVIndexOutOfBounds.CreateFmt('TMVValuesManagerBase.Insert: Index (%d) out of bounds.',[Index]);
        end
      else raise EMVAlreadyManaged.CreateFmt('TMVValuesManagerBase.Insert: Value %s is already managed elsewhere.',[Value.InstanceString]);
    end;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.Exchange(Idx1,Idx2: Integer);
var
  Temp: TMVManagedValueBase;
begin
Lock;
try
  If Idx1 <> Idx2 then
    begin
      If not CheckIndex(Idx1) then
        raise EMVIndexOutOfBounds.CreateFmt('TMVValuesManagerBase.Exchange: Index 1 (%d) out of bounds.',[Idx1]);
      If not CheckIndex(Idx2) then
        raise EMVIndexOutOfBounds.CreateFmt('TMVValuesManagerBase.Exchange: Index 2 (%d) out of bounds.',[Idx2]);
      Temp := fValues[Idx1];
      fValues[Idx1] := fValues[Idx2];
      fValues[Idx2] := Temp;
      DoChange;
    end;
finally
  Unlock;
end;    
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.Move(SrcIdx,DstIdx: Integer);
var
  Temp: TMVManagedValueBase;
  i:    Integer;
begin
Lock;
try
  If SrcIdx <> DstIdx then
    begin
      If not CheckIndex(SrcIdx) then
        raise EMVIndexOutOfBounds.CreateFmt('TMVValuesManagerBase.Move: Source index (%d) out of bounds.',[SrcIdx]);
      If not CheckIndex(DstIdx) then
        raise EMVIndexOutOfBounds.CreateFmt('TMVValuesManagerBase.Move: Destination index (%d) out of bounds.',[DstIdx]);
      Temp := fValues[SrcIdx];
      If SrcIdx < DstIdx then
        For i := SrcIdx to Pred(DstIdx) do
          fValues[i] := fValues[i + 1]
      else
        For i := SrcIdx downto Succ(DstIdx) do
          fValues[i] := fValues[i - 1];
      fValues[DstIdx] := Temp;
      DoChange;
    end;
finally
  Unlock;
end;    
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.Extract(const Name: String): TMVManagedValueBase;
var
  Index: Integer;
begin
Lock;
try
  Index := IndexOf(Name);
  If CheckIndex(Index) then
    begin
      Result := fValues[Index];
      DeleteInternal(Index,False);
    end
  else Result := nil;
finally
  Unlock;
end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TMVValuesManagerBase.Extract(Value: TMVManagedValueBase): TMVManagedValueBase;
var
  Index: Integer;
begin
Lock;
try
  Index := IndexOf(Value);
  If CheckIndex(Index) then
    begin
      Result := fValues[Index];
      DeleteInternal(Index,False);
    end
  else Result := nil;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

Function TMVValuesManagerBase.Remove(const Name: String): Integer;
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

Function TMVValuesManagerBase.Remove(Value: TMVManagedValueBase): Integer;
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

procedure TMVValuesManagerBase.Delete(Index: Integer);
begin
Lock;
try
  DeleteInternal(Index,True);
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.Clear;
var
  i:  Integer;
begin
Lock;
try
  For i := LowIndex to HighIndex do
    ProcessDeletedValue(fValues[i],True);
  SetLength(fValues,0);
  fCount := 0;
  fEqualsToInit := True;
  DoChange;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.FreeValuesAndClear;
var
  i:  Integer;
begin
Lock;
try
  For i := LowIndex to HighIndex do
    begin
      ProcessDeletedValue(fValues[i],True);
      If not(Self is TMVValuesManagerGlobal) then
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

procedure TMVValuesManagerBase.SaveToStream(Stream: TStream; StreamingEvents: Boolean = False);
var
  i:          Integer;
  CanStream:  Boolean;
begin
Lock;
try
  For i := LowIndex to HighIndex do
    begin
      CanStream := True;
      If StreamingEvents then
        DoStreaming(i,CanStream);
      If CanStream then
        fValues[i].SaveToStream(Stream);
    end;
finally
  Unlock;
end;
end;

//------------------------------------------------------------------------------

procedure TMVValuesManagerBase.LoadFromStream(Stream: TStream; Init: Boolean = False; StreamingEvents: Boolean = False);
var
  i:          Integer;
  CanStream:  Boolean;
begin
Lock;
try
  For i := lowIndex to HighIndex do
    begin
      CanStream := True;
      If StreamingEvents then
        DoStreaming(i,CanStream);
      If CanStream then
        fValues[i].LoadFromStream(Stream,Init);
    end;
finally
  Unlock;
end;
end;


{===============================================================================
    Unit initialization/finalization
===============================================================================}
{$IFDEF MV_GlobalManager}
initialization
  MVGlobalManager := TMVValuesManagerGlobal.Create;

finalization
  FreeAndNil(MVGlobalManager);
{$ENDIF}

end.
