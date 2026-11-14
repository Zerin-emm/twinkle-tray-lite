; ============================================================================================
;  Twinkle Tray Lite Inno Setup 安装脚本 —— x64 版
;  编译： "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" resources\installer.iss
;  前置： npx electron-builder --dir（产物在 dist\win-unpacked）
;  产物： resources\Output\TwinkleTrayLite-Setup-1.0.0-x64.exe
;  卸载： 程序目录 / 快捷方式 / 开机自启项一并清理；数据目录由用户选择是否删除（默认保留）
; ============================================================================================

#define MyAppName "Twinkle Tray"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Zerin-emm"
#define MyAppUrl "https://github.com/Zerin-emm/twinkle-tray-lite"
#define MyAppExeName "Twinkle Tray.exe"
#define BuildDir "..\dist\win-unpacked"
#define AppDataDir "{userappdata}\twinkle-tray"

[Setup]
AppId={{8F3C2A1E-5B7D-4E9A-9C21-7D4B6A2F1E30}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppUrl}
AppSupportURL={#MyAppUrl}
AppUpdatesURL={#MyAppUrl}/releases
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.22000
OutputDir=Output
OutputBaseFilename=TwinkleTrayLite-Setup-{#MyAppVersion}-x64
SetupIconFile=..\src\assets\logo.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern dynamic windows11
CloseApplications=yes
CloseApplicationsFilter={#MyAppExeName}
RestartApplications=no

[Languages]
Name: "chinese"; MessagesFile: "compiler:Languages\Chinese.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加任务："; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.xml,*.recipe,*.tlog,*.iobj,*.ipdb,*.obj,*.lib,*.exp,*.ilk"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "立即运行 {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
const
  StartupRunKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
  StartupRunValueName = 'electron.app.Twinkle Tray';

var
  DeleteUserData: Boolean;
  DataDirPath: String;
  AskUserDataAnswered: Boolean;

procedure RemoveStartupEntry();
var
  ExistingValue: String;
begin
  if not RegQueryStringValue(HKCU, StartupRunKey, StartupRunValueName, ExistingValue) then
  begin
    Log('未找到自启动项，无需删除');
    Exit;
  end;
  if RegDeleteValue(HKCU, StartupRunKey, StartupRunValueName) then
    Log('已删除自启动项（原值：' + ExistingValue + '）')
  else
    Log('无法删除自启动项（原值：' + ExistingValue + '）');
end;

procedure AskAboutUserData();
begin
  if AskUserDataAnswered then Exit;
  AskUserDataAnswered := True;

  if not DirExists(DataDirPath) then
  begin
    DeleteUserData := False;
    Exit;
  end;

  DeleteUserData :=
    MsgBox('是否同时删除程序数据（设置与日志）？' + #13#10 + #13#10 +
           '数据目录：' + #13#10 + DataDirPath,
           mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES;
end;

procedure RemoveUserData();
begin
  if not DeleteUserData then Exit;
  if not DirExists(DataDirPath) then Exit;
  if not DelTree(DataDirPath, True, True, True) then
    SuppressibleMsgBox('未能删除数据目录：' + #13#10 + DataDirPath + #13#10 + #13#10 +
                       '请手动删除该文件夹。', mbError, MB_OK, IDOK);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    DataDirPath := ExpandConstant('{#AppDataDir}');
    AskAboutUserData();
    RemoveStartupEntry();
  end
  else if CurUninstallStep = usPostUninstall then
  begin
    RemoveUserData();
  end;
end;
