; MoviePilot-V2 Windows installer (FastAPI StaticFiles edition, no Nginx)
;
; Build invocation:
;   iscc /DMyAppVersion=<version> build.iss
;
; Required files next to this script at build time (produced by the workflow):
;   ..\..\MoviePilot\           (MoviePilot server source)
;   ..\..\MoviePilot-Frontend\  (jxxghp frontend dist)
;   ..\..\Python3.11\           (embedded Python runtime)

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0.dev"
#endif

#define MyAppName        "MoviePilot-V2"
#define MyAppPublisher   "naughtyGitCat (fork of developer-wlj)"
#define MyAppURL         "https://github.com/naughtyGitCat/Windows-MoviePilot"
#define MyAppExeName     "MoviePilot.bat"
#define MySourceRoot     "..\..\"

[Setup]
AppId={{4f3f88b6-1f79-4d2b-9a4d-mp2static}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableDirPage=no
DisableProgramGroupPage=yes
OutputDir=exe
OutputBaseFilename=MoviePilot-V2-Setup-{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
UninstallDisplayIcon={app}\MoviePilot\app.ico
SetupIconFile={#MySourceRoot}MoviePilot\app.ico
UsePreviousAppDir=yes

[Languages]
; Installer wizard: English only (避免额外依赖 ChineseSimplified.isl).
; 被安装应用本身仍为中文 UI。如需中文向导，在 build 目录放入 ChineseSimplified.isl
; 并取消下面那行注释。
Name: "english"; MessagesFile: "compiler:Default.isl"
;Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Server source — excluding user config (preserve on upgrade) and all non-runtime assets
Source: "{#MySourceRoot}MoviePilot\*"; DestDir: "{app}\MoviePilot"; \
    Excludes: "\config\*,\.git\*,\.git,\.github\*,\docker\*,\docs\*,\tests\*,\scripts\*,\skills\*,\moviepilot\*,README*.md,LICENSE,safety.policy.yml,setup.py,frozen.spec,*.pyi,*.pyc"; \
    Flags: ignoreversion recursesubdirs createallsubdirs

; Ship a default config ONLY on first install (don't overwrite user edits)
Source: "{#MySourceRoot}MoviePilot\config\*"; DestDir: "{app}\MoviePilot\config"; Flags: onlyifdoesntexist recursesubdirs createallsubdirs uninsneveruninstall

; Frontend dist — served by FastAPI StaticFiles
Source: "{#MySourceRoot}MoviePilot-Frontend\*"; DestDir: "{app}\MoviePilot-Frontend"; Flags: ignoreversion recursesubdirs createallsubdirs

; Embedded Python runtime
Source: "{#MySourceRoot}Python3.11\*"; DestDir: "{app}\Python3.11"; Flags: ignoreversion recursesubdirs createallsubdirs

; Launchers (written by this installer's [Code] section via FilesystemTextFile? No — ship as actual files)
Source: "launcher.bat"; DestDir: "{app}"; DestName: "MoviePilot.bat"; Flags: ignoreversion
Source: "restart.bat";  DestDir: "{app}"; DestName: "RebotMP.bat";   Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}";             Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\MoviePilot\app.ico"; WorkingDir: "{app}"
Name: "{group}\Uninstall {#MyAppName}";   Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}";       Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\MoviePilot\app.ico"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent shellexec

[UninstallDelete]
; Clean up logs and caches (but not config — user may reinstall)
Type: filesandordirs; Name: "{app}\MoviePilot\logs"
Type: filesandordirs; Name: "{app}\MoviePilot\cache"
Type: filesandordirs; Name: "{app}\MoviePilot\temp"
Type: filesandordirs; Name: "{app}\Python3.11\__pycache__"
