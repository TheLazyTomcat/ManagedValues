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

{
  MV_GlobalManager

  When defined, the implicit global manager is created and used.

  Defined by default.

  To disable/undefine this symbol in a project without changing this library,
  define project-wide symbol ManagedValues_MV_GlobalManager_Off.
}
{$DEFINE MV_GlobalManager}
{$IFDEF ManagedValues_MV_GlobalManager_Off}
  {$UNDEF MV_GlobalManager}
{$ENDIF}

// do NOT touch following --  --  --  --  --  --  --  --  --  --  --  --  --  --

{$UNDEF MV_Value_ConstParams}
{$UNDEF MV_Value_AssignIsThreadSafe}
{$UNDEF MV_Value_CaseSensitivity}
{$UNDEF MV_Value_ComplexStreamedSize}

{$UNDEF MV_ArrayItem_ConstParams}
{$UNDEF MV_ArrayItem_AssignIsThreadSafe}
{$UNDEF MV_ArrayItem_CaseSensitivity}
{$UNDEF MV_ArrayItem_ComplexStreamedSize}

{$UNDEF MV_ClassDeclaration}
{$UNDEF MV_ClassImplementation}
