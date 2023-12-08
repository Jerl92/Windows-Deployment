@echo	Apply-Image.bat
@echo	Windows instalation batch file.
@echo   If there no argument, the path of Apply-Image.bat will be used.
@echo   This script erases the selected hard drive and applies a new image.
@echo.
@echo * This script stops just after applying the image.
@echo   This gives you an opportunity to add siloed provisioning packages (SPPs)
@echo   so that you can include them in your recovery tools.
@echo.
@echo * This script now checks to see if you're in BIOS or UEFI mode.
@echo.
@if not exist X:\Windows\System32 echo ERROR: This script is built to run in Windows PE.
@if not exist X:\Windows\System32 goto END

@echo *********************************************************************
@echo Checking to see if the PC is booted in BIOS or UEFI mode.
@echo *********************************************************************
wpeutil UpdateBootInfo
for /f "tokens=2* delims=	 " %%A in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO SET Firmware=%%B
@echo            Note: delims is a TAB followed by a space.
@if x%Firmware%==x echo ERROR: Can't figure out which firmware we're on.
@if x%Firmware%==x echo        Common fix: In the command above:
@if x%Firmware%==x echo             for /f "tokens=2* delims=	 "
@if x%Firmware%==x echo        ...replace the spaces with a TAB character followed by a space.
@if x%Firmware%==x goto END
@if %Firmware%==0x1 echo The PC is booted in BIOS mode. 
@if %Firmware%==0x2 echo The PC is booted in UEFI mode. 

@echo *********************************************************************
@echo  == Show then chose the WIM file to install ==
@echo *********************************************************************
setlocal enabledelayedexpansion
set /a val = 0
for %%f in (%~dp0*.wim) do (
    set /a val = val + 1
    echo "ID: !val! - name: %%~nf"
)
@if !val!.==0. echo No WIM file have been found in the directory %~dp0
if %1.==. SET arg = 1
if %arg%.==0. (
	@set filepath=%1
)
@SET /P file=Select a WIM file? (Number only):
set /a x = 0
for %%f in (%~dp0*.wim) do (
    set /a x = x + 1
    if %file%.==!x!. (
    	echo "ID: !x! - name: %%~nf have been selected"
	set filepath=%%f
	)
)

@echo *********************************************************************
@echo  == List images that are contained in the WIM file ==
@echo *********************************************************************
Dism /Get-ImageInfo /imagefile:%filepath%
@echo  == Chose the index ==
@SET /P INDEX=Chose the index? (Number only):
set INDEX=%INDEX%

@echo *********************************************************************
@echo == Show hard drives ==
@echo *********************************************************************
if exist X:\Windows\System32\wbem\WMIC.exe (
    wmic diskdrive get index,model,serialNumber,size,mediaType
) 
if not exist X:\Windows\System32\wbem\WMIC.exe (
    echo list disk > %~dp0ShowDrives.txt
    diskpart /s %~dp0ShowDrives.txt
)

@echo *********************************************************************
@echo  == Chose the drive ==
@echo *********************************************************************
@SET /P DRIVE=Chose the drive? (Index number only):
set  DRIVE=%DRIVE%

@echo *********************************************************************
@echo  == If the instalation is Compact OS ==
@echo *********************************************************************
@SET /P COMPACTOS=Deploy as Compact OS? (Y or N):
@if %COMPACTOS%.==y. set COMPACTOS=Y

if %Firmware%==0x1 echo rem == CreatePartitions-BIOS.txt == > %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem == These commands are used with DiskPart to >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem    create three partitions >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem    for a BIOS/MBR-based computer. >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem    Adjust the partition sizes to fill the usbdrive >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem    as necessary. == >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo select disk %DRIVE% >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo clean >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem == 1. System partition ====================== >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo create partition primary size=100 >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo format quick fs=ntfs label="System" >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo assign letter="S" >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo active >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem == 2. Windows partition ===================== >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem ==    a. Create the Windows partition ======= >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo create partition primary >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo shrink minimum=1024 >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem       ** NOTE: Update this size to match the >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem                size of the recovery tools  >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem                (winre.wim)                 ** >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem ==    c. Prepare the Windows partition ======  >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo format quick fs=ntfs label="Windows" >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo assign letter="W" >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo rem == 3. Recovery partition ==================== >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo create partition primary size=1024  >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo format quick fs=ntfs label="Recovery" >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo assign letter="R" >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo set id=27 >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo list volume >> %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x1 echo exit >> %~dp0CreatePartitions-BIOS.txt

if %Firmware%==0x2 echo rem == CreatePartitions-UEFI.txt == > %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem == These commands are used with DiskPart to >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem    create four partitions >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem    for a UEFI/GPT-based PC. >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem    Adjust the partition sizes to fill the drive >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem    as necessary. == >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo select disk %DRIVE% >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo clean >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo convert gpt >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem == 1. System partition ========================= >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo create partition efi size=100 >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem    ** NOTE: For Advanced Format 4Kn drives, >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem               change this value to size = 260 **  >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo format quick fs=fat32 label="System" >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo assign letter="S" >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem == 2. Windows partition ======================== >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem ==    a. Create the Windows partition ========== >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo create partition primary >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo shrink minimum=1024 >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem       ** NOTE: Update this size to match the >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem                size of the recovery tools  >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem                (winre.wim)                    ** >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem ==    c. Prepare the Windows partition =========  >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo format quick fs=ntfs label="Windows" >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo assign letter="W" >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo rem === 3. Recovery partition ====================== >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo create partition primary size=1024 >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo format quick fs=ntfs label="Recovery" >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo assign letter="R" >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo set id="DE94BBA4-06D1-4D40-A16A-BFD50179D6AC" >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo gpt attributes=0x8000000000000001 >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo list volume >> %~dp0CreatePartitions-UEFI.txt
if %Firmware%==0x2 echo exit >> %~dp0CreatePartitions-UEFI.txt

@echo *********************************************************************
@echo Formatting the primary disk...
@echo *********************************************************************
@if %Firmware%==0x1 echo    ...using BIOS (MBR) format and partitions.
@if %Firmware%==0x2 echo    ...using UEFI (GPT) format and partitions. 
@echo CAUTION: All the data on the disk will be DELETED.
@SET /P READY=Erase all data and continue? (Y or N):
@if %READY%.==y. set READY=Y
@if not %READY%.==Y. goto END
if %Firmware%==0x1 diskpart /s %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x2 diskpart /s %~dp0CreatePartitions-UEFI.txt

@echo *********************************************************************
@echo  == Set high-performance power scheme to speed deployment ==
@echo *********************************************************************
call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

@echo *********************************************************************
@echo  == Apply the image to the Windows partition ==
@echo *********************************************************************
if %COMPACTOS%.==Y.     dism /Apply-Image /ImageFile:%filepath% /Index:%INDEX% /ApplyDir:W:\ /Compact
if not %COMPACTOS%.==Y. dism /Apply-Image /ImageFile:%filepath% /Index:%INDEX% /ApplyDir:W:\

@echo *********************************************************************
@echo == Copy boot files to the System partition ==
@echo *********************************************************************
W:\Windows\System32\bcdboot W:\Windows /s S:

@echo *********************************************************************
@echo  == Copy the Windows RE image to the Windows RE Tools partition ==
@echo *********************************************************************
md R:\Recovery\WindowsRE
xcopy /h W:\Windows\System32\Recovery\Winre.wim R:\Recovery\WindowsRE\

@echo  *********************************************************************
@echo  == Register the location of the recovery tools ==
@echo *********************************************************************
W:\Windows\System32\Reagentc /Setreimage /Path R:\Recovery\WindowsRE /Target W:\Windows

if %Firmware%==0x1 echo rem === HideRecoveryPartitions-BIOS.txt === > %~dp0HideRecoveryPartitions-BIOS.txt
if %Firmware%==0x1 echo select disk %DRIVE% >> %~dp0HideRecoveryPartitions-BIOS.txt
if %Firmware%==0x1 echo select partition 3 >> %~dp0HideRecoveryPartitions-BIOS.txt
if %Firmware%==0x1 echo set id=27 >> %~dp0HideRecoveryPartitions-BIOS.txt
if %Firmware%==0x1 echo remove >> %~dp0HideRecoveryPartitions-BIOS.txt
if %Firmware%==0x1 echo list volume >> %~dp0HideRecoveryPartitions-BIOS.txt
if %Firmware%==0x1 echo exit >> %~dp0HideRecoveryPartitions-BIOS.txt

if %Firmware%==0x2 echo rem === HideRecoveryPartitions-UEFI.txt === > %~dp0HideRecoveryPartitions-UEFI.txt
if %Firmware%==0x2 echo select disk %DRIVE% >> %~dp0HideRecoveryPartitions-UEFI.txt
if %Firmware%==0x2 echo select partition 3 >> %~dp0HideRecoveryPartitions-UEFI.txt
if %Firmware%==0x2 echo set id=DE94BBA4-06D1-4D40-A16A-BFD50179D6AC >> %~dp0HideRecoveryPartitions-UEFI.txt
if %Firmware%==0x2 echo gpt attributes=0x8000000000000001 >> %~dp0HideRecoveryPartitions-UEFI.txt
if %Firmware%==0x2 echo remove >> %~dp0HideRecoveryPartitions-UEFI.txt
if %Firmware%==0x2 echo list volume >> %~dp0HideRecoveryPartitions-UEFI.txt
if %Firmware%==0x2 echo exit >> %~dp0HideRecoveryPartitions-UEFI.txt

@echo  *********************************************************************
@echo == Hiding the recovery tools partition ==
@echo *********************************************************************
if %Firmware%==0x1 diskpart /s %~dp0HideRecoveryPartitions-BIOS.txt
if %Firmware%==0x2 diskpart /s %~dp0HideRecoveryPartitions-UEFI.txt

@echo *********************************************************************
@echo == Log system hardware. ==
@echo *********************************************************************
if exist X:\Windows\System32\wbem\WMIC.exe (
    echo == Motherboard information == > %~dp0SystemHardware.txt
    wmic baseboard get product,Manufacturer,SerialNumber,Status,Version >> %~dp0SystemHardware.txt
    wmic baseboard get product,Manufacturer,SerialNumber,Status,Version

    echo == CPU information == >> %~dp0SystemHardware.txt
    wmic cpu get caption, name, deviceid, numberofcores, maxclockspeed, status >> %~dp0SystemHardware.txt
    wmic cpu get caption, name, deviceid, numberofcores, maxclockspeed, status

    echo == Memory information == >> %~dp0SystemHardware.txt
    wmic MemoryChip get BankLabel, Capacity, MemoryType, TypeDetail, Speed >> %~dp0SystemHardware.txt
    wmic MemoryChip get BankLabel, Capacity, MemoryType, TypeDetail, Speed

    echo == Video information == >> %~dp0SystemHardware.txt
    wmic path win32_VideoController get DeviceID,MaxRefreshRate,Status,StatusInfo,VideoMemoryType,PNPDeviceID,VideoProcessor,AdapterRAM >> %~dp0SystemHardware.txt
    wmic path win32_VideoController get DeviceID,MaxRefreshRate,Status,StatusInfo,VideoMemoryType,PNPDeviceID,VideoProcessor,AdapterRAM
)

@echo *********************************************************************
@echo == Verify the configuration status of the images. ==
@echo *********************************************************************
W:\Windows\System32\Reagentc /Info /Target W:\Windows

@echo *********************************************************************
@echo      All done!
@echo *********************************************************************
@echo      Disconnect the USB drive from the device.
@echo      The device will reboot automatically in 15 second.
@echo
echo wsh.sleep 15000>sleep.vbs
cscript //nologo sleep.vbs
del sleep.vbs
wpeutil reboot
:EXIT
