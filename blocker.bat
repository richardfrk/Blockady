::
:: Skype Ad Blocker 0.1.0.0
::
:: 
:: © 2015 Dalthow Game Studios
::

@ECHO off

:menu
:: A place where the user can specify which action he wants to take.

CLS

ECHO Menu.
ECHO.
ECHO 1. Block Skype ad's.
ECHO 2. Configuration.
ECHO 3. Reboot Skype.
ECHO 4. Exit.
ECHO.
SET /P option=Option: 
IF /I "%option%" EQU "1" GOTO :checkPrivileges
IF /I "%option%" EQU "2" GOTO :config
IF /I "%option%" EQU "3" GOTO :rebootSkype
IF /I "%option%" EQU "4" EXIT
GOTO :menu


:config
:: The configuration menu.

CLS

ECHO Configuration.
ECHO.
ECHO 1. Specify the installation directory.
ECHO 2. Add redirecting.
ECHO 3. Exit.
ECHO.
SET /P option=Option: 
IF /I "%option%" EQU "1" GOTO :installationDirectory
IF /I "%option%" EQU "2" GOTO :redirectingAds
IF /I "%option%" EQU "3" GOTO :menu
GOTO :menu


:checkPrivileges
:: Checking if the user has administrator rights or not.

CLS

ECHO Checking privileges...
ECHO.
NET FILE 1>NUL 2>NUL
IF '%errorlevel%' == '0' (GOTO confirm) ELSE (GOTO getPrivileges)


:getPrivileges
:: If the user doesn't have administrator rights, then prompt for it.

CLS

IF '%1'=='ELEV' (SHIFT & GOTO confirm & ECHO Access granted.)
SETLOCAL DisableDelayedExpansion
SET "batchPath=%~0"
SETLOCAL EnableDelayedExpansion
ECHO SET UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
EXIT /B


:confirm
:: Asking the user if he really wanted to do this.

CLS

ECHO Warning.
ECHO.
ECHO This script modifies your hosts file. It does not mess with Skype itself.
ECHO Therefore we don't breach Skype's terms and conditions or user agreement.
ECHO.
SET /P confirm=Are you sure you want to continue [Y/N]? 
IF /I "%confirm%" EQU "Y" GOTO :writeHost
IF /I "%confirm%" EQU "N" GOTO :menu
GOTO :confirm


:redirectingAds
:: Asking the user what domain the ad's should be redirected to.

CLS

ECHO Do you want to redirect ad's to a specific adress on your local machine?
ECHO.
SET /P ip=Domain: 
GOTO :config


:installationDirectory
:: If the user installed Skype in a different directory he can change it here.

CLS

SETLOCAL enabledelayedexpansion

SET chooser=%temp%\fchooser.exe
IF exist !chooser! DEL !chooser!

>"%temp%\c.cs" ECHO using System;using System.Windows.Forms;
>>"%temp%\c.cs" ECHO class dummy{[STAThread]
>>"%temp%\c.cs" ECHO public static void Main^(^){
>>"%temp%\c.cs" ECHO FolderBrowserDialog f=new FolderBrowserDialog^(^);
>>"%temp%\c.cs" ECHO f.SelectedPath=System.Environment.CurrentDirectory;
>>"%temp%\c.cs" ECHO f.Description="Please select the folder Skype is installed in.";
>>"%temp%\c.cs" ECHO f.ShowNewFolderButton=true;
>>"%temp%\c.cs" ECHO if^(f.ShowDialog^(^)==DialogResult.OK^){Console.Write^(f.SelectedPath^);}}}
    
FOR /F "delims=" %%i IN ('DIR /B /S "%windir%\microsoft.net\*csc.exe"') DO (
   IF NOT EXIST "!chooser!" "%%i" /nologo /out:"!chooser!" "%temp%\c.cs" 2>NUL
)

DEL "%temp%\c.cs"

IF NOT EXIST "!chooser!" (
   ECHO Please install .NET 2.0 or newer!
   ECHO.
   SET /P =Press enter to return to the menu...
   START http://www.microsoft.com/net
)

FOR /F "delims=" %%i IN ('%chooser%') DO SET "installDir=%%i"

DEL "%temp%\fchooser.exe" 2>NUL

GOTO :config


:writeHost
:: Writing the changes to the host file so ad domains are blocked.

IF /I "%ip%" EQU "" SET ip=127.0.0.1

CLS

ECHO Writing ad domains to host file...
ECHO.
PUSHD "%~dp0"
FOR /F "tokens=* delims=" %%x IN (domains.txt) DO >NUL FIND "%ip% %%x" "C:\Windows\System32\drivers\etc\hosts" && (ECHO '%ip% %%x' already in hosts file, skipping . . .) || (ECHO %ip% %%x >> "C:\Windows\System32\drivers\etc\hosts")

GOTO rebootSkype


:rebootSkype
:: Restarting Skype for the changes to take effect.

IF /I "%installDir%" EQU "" SET installDir=C:\Program Files (x86)\Skype\

CLS

ECHO Shutting down Skype, BitTorrent, Spotify...
TASKKILL /F /IM Skype.exe >NUL 2>&1
TASKKILL /F /IM BitTorrent.exe >NUL 2>&1
TASKKILL /F /IM Spotify.exe >NUL 2>&1
ECHO.

ECHO Starting Skype, BitTorrent, Spotify...
START "" "%installDir%\Phone\Skype.exe"
START "" "%APPDATA%\BitTorrent\BitTorrent.exe"
START "" "%APPDATA%\Spotify\Spotify.exe"

GOTO :menu
