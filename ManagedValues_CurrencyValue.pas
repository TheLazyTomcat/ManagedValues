unit ManagedValues_CurrencyValue;

{$INCLUDE './ManagedValues_defs.inc'}

interface

uses
  Classes,
  AuxTypes,
  ManagedValues_Base;

{===============================================================================
--------------------------------------------------------------------------------
                                 TCurrencyValue
--------------------------------------------------------------------------------
===============================================================================}
type
  TMVValueBaseType = Currency;

{$UNDEF MV_ConstParams}
{$DEFINE MV_AssignIsThreadSafe}
{$UNDEF MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{===============================================================================
    TCurrencyValue - class declaration
===============================================================================}
type
  TMVCurrencyValue = class(TRealManagedValue)
  {$DEFINE MV_ClassDeclaration}
    {$INCLUDE './ManagedValues.inc'}
  {$UNDEF MV_ClassDeclaration}
  end;

type
  TMVValueClass = TMVCurrencyValue;

implementation

uses
  SysUtils,
  BinaryStreaming; 

{$IFDEF FPC_DisableWarns}
  {$DEFINE FPCDWM}
  {$DEFINE W5024:={$WARN 5024 OFF}} // Parameter "$1" not used
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                 TCurrencyValue
--------------------------------------------------------------------------------
===============================================================================}
const
  MV_LOCAL_DEFAULT_VALUE = 0.0;

{===============================================================================
    TCurrencyValue - class implementation
===============================================================================}

{$DEFINE MV_ClassImplementation}
  {$INCLUDE './ManagedValues.inc'}
{$UNDEF MV_ClassImplementation}

//------------------------------------------------------------------------------

class Function TMVValueClass.GetValueType: TManagedValueType;
begin
Result := mvtCurrency;
end;

//------------------------------------------------------------------------------

{$IFNDEF MV_StringLikeType}{$IFDEF FPCDWM}{$PUSH}W5024{$ENDIF}{$ENDIF}
Function TMVValueClass.CompareBaseValues(const A,B; Arg: Boolean): Integer;
begin
If Currency(A) > Currency(B) then
  Result := +1
else If Currency(A) < Currency(B) then
  Result := -1
else
  Result := 0;
end;  
{$IFNDEF MV_StringLikeType}{$IFDEF FPCDWM}{$POP}{$ENDIF}{$ENDIF}

//------------------------------------------------------------------------------

procedure TMVValueClass.SaveToStream(Stream: TStream);
begin
Stream_WriteCurrency(Stream,fCurrentValue);
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.LoadFromStream(Stream: TStream; Init: Boolean = False);
begin
If Init then
  Initialize(Stream_ReadCurrency(Stream),False)
else
  SetCurrentValue(Stream_ReadCurrency(Stream));
end;

//------------------------------------------------------------------------------

Function TMVValueClass.AsString: String;
begin
Result := CurrToStr(fCurrentValue,fFormatSettings);
inherited AsString;
end;

//------------------------------------------------------------------------------

procedure TMVValueClass.FromString(const Str: String);
begin
SetCurrentValue(StrToCurr(Str,fFormatSettings));
inherited;
end;

end.
