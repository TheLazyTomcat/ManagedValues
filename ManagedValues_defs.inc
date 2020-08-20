{$IF Defined(WINDOWS) or Defined(MSWINDOWS)}
  {$DEFINE Windows}
{$ELSEIF Defined(LINUX) and Defined(FPC)}
  {$DEFINE Linux}
{$ELSE}
  {$MESSAGE FATAL 'Unsupported operating system.'}
{$IFEND}

{$IFDEF FPC}
  {$MODE ObjFPC}
  {$MODESWITCH CLASSICPROCVARS+}
  {$MODESWITCH DUPLICATELOCALS+}
  {$INLINE ON}
  {$DEFINE CanInline}
  {$DEFINE FPC_DisableWarns}
  {$MACRO ON}
{$ELSE}
  {$IF CompilerVersion >= 17 then}  // Delphi 2005+
    {$DEFINE CanInline}
  {$ELSE}
    {$UNDEF CanInline}
  {$IFEND}
{$ENDIF}
{$H+}

{$UNDEF MV_ConstParams}
{$UNDEF MV_AssignIsThreadSafe}
{$UNDEF MV_StringLikeType}
{$UNDEF MV_ComplexStreaming}

{$UNDEF MV_ItemConstParams}
{$UNDEF MV_ItemAssignIsThreadSafe}
{$UNDEF MV_ItemStringLikeType}


{$UNDEF MV_ClassDeclaration}
{$UNDEF MV_ClassImplementation}

{$DEFINE MV_GlobalManager}
