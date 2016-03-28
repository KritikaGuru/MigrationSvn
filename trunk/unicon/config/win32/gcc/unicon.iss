; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=Windows Unicon
AppVerName=Windows Unicon Version 12.3
AppPublisher=Unicon Project
AppPublisherURL=http://unicon.sourceforge.net
AppSupportURL=http://unicon.sourceforge.net
AppUpdatesURL=http://unicon.sourceforge.net
DefaultDirName=C:\Unicon
DefaultGroupName=Unicon
AllowNoIcons=yes
OutputBaseFilename=setup-unicon_12.3.0_threads(32-bit)_rev4234
Compression=lzma
SolidCompression=true
Uninstallable=yes
SetupIconFile=setup.ico
WizardImageFile=setupbig.bmp
WizardSmallImageFile=setupsmall.bmp

; uncomment the following line if you want your installation to run on NT 3.51 too.
; MinVersion=4,3.51

; This eliminates the need for restart for the new PATH to be effective
ChangesEnvironment=yes


[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4

[Files]
Source: "\unicon\config\win32\gcc\uninstall.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "\unicon\config\win32\gcc\internet.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "\unicon\bin\*.exe"; DestDir: "{app}\bin"; Flags: ignoreversion
;Source: "\unicon\bin\*.dll"; DestDir: "{app}\bin"; Flags: ignoreversion
;Source: "\unicon\bin\*.h"; DestDir: "{app}\bin"; Flags: ignoreversion
Source: "\unicon\dat\fonts\*"; DestDir: "{app}\dat\fonts"; Flags: ignoreversion

; Documentation
Source: "\unicon\doc\*.gif"; DestDir: "{app}\doc"; Flags: ignoreversion
Source: "\unicon\doc\icon\*.*"; DestDir: "{app}\doc\icon"; Flags: ignoreversion
Source: "\unicon\doc\icon\faq_files\*.*"; DestDir: "{app}\doc\icon\fag_files"; Flags: ignoreversion

Source: "\unicon\doc\utr\*.*"; DestDir: "{app}\doc\utr"; Flags: ignoreversion
Source: "\unicon\doc\utr\utr7\*.*"; DestDir: "{app}\doc\utr\utr7"; Flags: ignoreversion

Source: "\unicon\doc\unicon\*.*"; DestDir: "{app}\doc\unicon"; Flags: ignoreversion
Source: "\unicon\doc\unicon\utr1\*.*"; DestDir: "{app}\doc\unicon\utr1"; Flags: ignoreversion
Source: "\unicon\doc\unicon\utr6\*.*"; DestDir: "{app}\doc\unicon\utr6"; Flags: ignoreversion

Source: "\unicon\doc\udb\*.html"; DestDir: "{app}\doc\udb"; Flags: ignoreversion
Source: "\unicon\doc\udb\*.pdf"; DestDir: "{app}\doc\udb"; Flags: ignoreversion

;IPL
Source: "\unicon\ipl\cfuncs\*.*"; DestDir: "{app}\ipl\cfuncs"; Flags: ignoreversion
Source: "\unicon\ipl\packs\*.*"; DestDir: "{app}\ipl\packs"; Flags: ignoreversion
Source: "\unicon\ipl\procs\*.*"; DestDir: "{app}\ipl\procs"; Flags: ignoreversion
Source: "\unicon\ipl\progs\*.*"; DestDir: "{app}\ipl\progs"; Flags: ignoreversion
Source: "\unicon\ipl\incl\*.*"; DestDir: "{app}\ipl\incl"; Flags: ignoreversion
Source: "\unicon\ipl\data\*.*"; DestDir: "{app}\ipl\data"; Flags: ignoreversion
Source: "\unicon\ipl\docs\*.*"; DestDir: "{app}\ipl\docs"; Flags: ignoreversion
Source: "\unicon\ipl\gpacks\*.*"; DestDir: "{app}\ipl\gpacks"; Flags: ignoreversion
Source: "\unicon\ipl\gprocs\*.*"; DestDir: "{app}\ipl\gprocs"; Flags: ignoreversion
Source: "\unicon\ipl\gprogs\*.*"; DestDir: "{app}\ipl\gprogs"; Flags: ignoreversion
Source: "\unicon\ipl\gincl\*.*"; DestDir: "{app}\ipl\gincl"; Flags: ignoreversion
Source: "\unicon\ipl\gdata\*.*"; DestDir: "{app}\ipl\gdata"; Flags: ignoreversion
Source: "\unicon\ipl\gdocs\*.*"; DestDir: "{app}\ipl\gdocs"; Flags: ignoreversion
Source: "\unicon\ipl\mpacks\*.*"; DestDir: "{app}\ipl\mpacks"; Flags: ignoreversion
Source: "\unicon\ipl\mprocs\*.*"; DestDir: "{app}\ipl\mprocs"; Flags: ignoreversion
Source: "\unicon\ipl\mprogs\*.*"; DestDir: "{app}\ipl\mprogs"; Flags: ignoreversion
Source: "\unicon\ipl\mincl\*.*"; DestDir: "{app}\ipl\mincl"; Flags: ignoreversion
Source: "\unicon\ipl\mdata\*.*"; DestDir: "{app}\ipl\mdata"; Flags: ignoreversion
Source: "\unicon\ipl\mdocs\*.*"; DestDir: "{app}\ipl\mdocs"; Flags: ignoreversion
Source: "\unicon\ipl\lib\*.*"; DestDir: "{app}\ipl\lib"; Flags: ignoreversion

; uni misc
Source: "\unicon\uni\makedefs"; DestDir: "{app}\uni\"; Flags: ignoreversion
Source: "\unicon\uni\lib\*.*"; DestDir: "{app}\uni\lib"; Flags: ignoreversion
Source: "\unicon\uni\util\*.*"; DestDir: "{app}\uni\util"; Flags: ignoreversion
Source: "\unicon\uni\xml\*.*"; DestDir: "{app}\uni\xml"; Flags: ignoreversion
Source: "\unicon\uni\progs\makefile"; DestDir: "{app}\uni\progs"; Flags: ignoreversion
Source: "\unicon\uni\progs\*.icn"; DestDir: "{app}\uni\progs"; Flags: ignoreversion

; GUI library
Source: "\unicon\uni\gui\*.icn"; DestDir: "{app}\uni\gui"; Flags: ignoreversion
Source: "\unicon\uni\gui\*.u"; DestDir: "{app}\uni\gui"; Flags: ignoreversion
Source: "\unicon\uni\gui\uniclass.*"; DestDir: "{app}\uni\gui"; Flags: ignoreversion
Source: "\unicon\uni\gui\makefile"; DestDir: "{app}\uni\gui"; Flags: ignoreversion

Source: "\unicon\uni\gui\guidemos\*.icn"; DestDir: "{app}\uni\gui\guidemos"; Flags: ignoreversion
Source: "\unicon\uni\gui\guidemos\makefile"; DestDir: "{app}\uni\gui\guidemos"; Flags: ignoreversion

; IVIB
Source: "\unicon\uni\gui\ivib\*.icn"; DestDir: "{app}\uni\gui\ivib"; Flags: ignoreversion
Source: "\unicon\uni\gui\ivib\makefile"; DestDir: "{app}\uni\gui\ivib"; Flags: ignoreversion
Source: "\unicon\uni\gui\ivib\icon\*.icon"; DestDir: "{app}\uni\gui\ivib\icon"; Flags: ignoreversion
Source: "\unicon\uni\gui\ivib\icon\*.xpm"; DestDir: "{app}\uni\gui\ivib\icon"; Flags: ignoreversion
Source: "\unicon\uni\gui\ivib\icon\icon.gif"; DestDir: "{app}\uni\gui\ivib\icon"; Flags: ignoreversion
Source: "\unicon\uni\gui\ivib\icon\xpmtoims.icn"; DestDir: "{app}\uni\gui\ivib\icon"; Flags: ignoreversion

; The old IVIB 
; NOTE: The old ivib was dropped from sources in early 2014.
Source: "\unicon\uni\ivib\README"; DestDir: "{app}\uni\ivib"; Flags: ignoreversion
;Source: "\unicon\uni\ivib\*.icn"; DestDir: "{app}\uni\ivib"; Flags: ignoreversion
;Source: "\unicon\uni\ivib\makefile"; DestDir: "{app}\uni\ivib"; Flags: ignoreversion
;Source: "\unicon\uni\ivib\icon\*.ico"; DestDir: "{app}\uni\ivib\icon"; Flags: ignoreversion
;Source: "\unicon\uni\ivib\icon\*.xpm"; DestDir: "{app}\uni\ivib\icon"; Flags: ignoreversion
;Source: "\unicon\uni\ivib\icon\xpmtoims.icn"; DestDir: "{app}\uni\ivib\icon"; Flags: ignoreversion

; IDE
Source: "\unicon\uni\ide\*.icn"; DestDir: "{app}\uni\ide"; Flags: ignoreversion
Source: "\unicon\uni\ide\makefile"; DestDir: "{app}\uni\ide"; Flags: ignoreversion

; UDB
Source: "\unicon\uni\udb\*.icn"; DestDir: "{app}\uni\udb"; Flags: ignoreversion
Source: "\unicon\uni\udb\auto.y"; DestDir: "{app}\uni\udb"; Flags: ignoreversion
Source: "\unicon\uni\udb\Makefile"; DestDir: "{app}\uni\udb"; Flags: ignoreversion
Source: "\unicon\uni\udb\dta\*.icn"; DestDir: "{app}\uni\udb\dta"; Flags: ignoreversion
Source: "\unicon\uni\udb\dta\Makefile"; DestDir: "{app}\uni\udb\dta"; Flags: ignoreversion
Source: "\unicon\uni\udb\lib\*.icn"; DestDir: "{app}\uni\udb\lib"; Flags: ignoreversion
Source: "\unicon\uni\udb\lib\Makefile"; DestDir: "{app}\uni\udb\lib"; Flags: ignoreversion

; Unicon!
Source: "\unicon\uni\unicon\*.icn"; DestDir: "{app}\uni\unicon"; Flags: ignoreversion
Source: "\unicon\uni\unicon\idol.u"; DestDir: "{app}\uni\unicon"; Flags: ignoreversion
Source: "\unicon\uni\unicon\unigram.u"; DestDir: "{app}\uni\unicon"; Flags: ignoreversion
Source: "\unicon\uni\unicon\makefile"; DestDir: "{app}\uni\unicon"; Flags: ignoreversion

; 3D Library
Source: "\unicon\uni\3d\*.icn"; DestDir: "{app}\uni\3d"; Flags: ignoreversion
Source: "\unicon\uni\3d\*.u"; DestDir: "{app}\uni\3d"; Flags: ignoreversion
Source: "\unicon\uni\3d\uniclass.*"; DestDir: "{app}\uni\3d"; Flags: ignoreversion
Source: "\unicon\uni\3d\viewer\*.icn"; DestDir: "{app}\uni\3d\viewer"; Flags: ignoreversion
Source: "\unicon\uni\3d\viewer\makefile"; DestDir: "{app}\uni\3d\viewer"; Flags: ignoreversion
Source: "\unicon\uni\3d\models\*.*"; DestDir: "{app}\uni\3d\models"; Flags: ignoreversion

; Thread tests
Source: "\unicon\tests\thread\*.icn"; DestDir: "{app}\tests\thread"; Flags: ignoreversion
Source: "\unicon\tests\thread\*.std"; DestDir: "{app}\tests\thread"; Flags: ignoreversion
Source: "\unicon\tests\thread\README"; DestDir: "{app}\tests\thread"; Flags: ignoreversion
Source: "\unicon\tests\thread\makefile"; DestDir: "{app}\tests\thread"; Flags: ignoreversion

; Bench
Source: "\unicon\tests\bench\*.icn"; DestDir: "{app}\tests\bench"; Flags: ignoreversion
Source: "\unicon\tests\bench\*.dat"; DestDir: "{app}\tests\bench"; Flags: ignoreversion
Source: "\unicon\tests\bench\*.c"; DestDir: "{app}\tests\bench"; Flags: ignoreversion
Source: "\unicon\tests\bench\*.test"; DestDir: "{app}\tests\bench"; Flags: ignoreversion
Source: "\unicon\tests\bench\README"; DestDir: "{app}\tests\bench"; Flags: ignoreversion
Source: "\unicon\tests\bench\makefile"; DestDir: "{app}\tests\bench"; Flags: ignoreversion
Source: "\unicon\tests\bench\icon\*.*"; DestDir: "{app}\tests\bench\icon"; Flags: ignoreversion


[INI]
Filename: "{app}\WU.url"; Section: "InternetShortcut"; Key: "URL"; String: "http://unicon.sourceforge.net"

[Icons]
Name: {group}\{cm:UninstallProgram,Windows Unicon}; Filename: {uninstallexe};IconFilename: "{app}\uninstall.ico"
Name: "{group}\Windows Unicon on the Web"; Filename: "{app}\WU.url" ;IconFilename: "{app}\internet.ico"
Name: "{group}\Windows Unicon"; Filename: "{app}\bin\UI.EXE"
Name: "{userdesktop}\Windows Unicon"; Filename: "{app}\bin\UI.EXE"; MinVersion: 4,4; Tasks: desktopicon


[Run]
Filename: "{app}\bin\UI.EXE"; Description: "Launch Windows Unicon"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\WU.url"

[Registry]
; Add unicon\bin to the path (current user only)
;Root: HKCU; Subkey: "Environment"; ValueName: "Path"; ValueType: "string"; ValueData: "{app}\bin;{olddata}";  Flags: preservestringtype;

; Add unicon\bin to the path (all users)
Root: HKLM; Subkey: "SYSTEM\ControlSet001\Control\Session Manager\Environment"; ValueName: "Path"; ValueType: "string"; ValueData: "{app}\bin;{olddata}"; Check: NotOnAllUsersPathAlready(); Flags: preservestringtype;


[Code]
function NotOnPathAlready(): Boolean;
var
  BinDir, Path: String;
begin
  Log('Checking if unicon\bin dir is already on the %PATH%');
  if RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', 'Path', Path) then
  begin // Successfully read the value
    Log('HKCU\Environment\PATH = ' + Path);
    BinDir := ExpandConstant('{app}\bin');
    Log('Looking for unicon\bin dir in %PATH%: ' + BinDir + ' in ' + Path);
    if Pos(LowerCase(BinDir), Lowercase(Path)) = 0 then
    begin
      Log('Did not find unicon\bin dir in %PATH% so will add it');
      Result := True;
    end
    else
    begin
      Log('Found unicon\bin dir in %PATH% so will not add it again');
      Result := False;
    end
  end
  else // The key probably doesn't exist
  begin
    Log('Could not access HKCU\Environment\PATH so assume it is ok to add it');
    Result := True;
  end;
end;

function NotOnAllUsersPathAlready(): Boolean;
var
  BinDir, Path: String;
begin
  Log('Checking if unicon\bin dir is already on the %PATH%');
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Control\Session Manager\Environment', 'Path', Path) then
  begin // Successfully read the value
    Log('HKLM\SYSTEM\ControlSet001\Control\Session Manager\Environment\PATH = ' + Path);
    BinDir := ExpandConstant('{app}\bin');
    Log('Looking for unicon\bin dir in %PATH%: ' + BinDir + ' in ' + Path);
    if Pos(LowerCase(BinDir), Lowercase(Path)) = 0 then
    begin
      Log('Did not find unicon\bin dir in %PATH% so will add it');
      Result := True;
    end
    else
    begin
      Log('Found unicon\bin dir in %PATH% so will not add it again');
      Result := False;
    end
  end
  else // The key probably doesn't exist
  begin
    Log('Could not access HKLM\SYSTEM\ControlSet001\Control\Session Manager\Environment\PATH so assume it is ok to add it');
    Result := True;
  end;
end;



