# Windows-Deployment
ApplyImage.bat</br>
WindowsPE batch file to format and apply windows installation.</br>

<img style="max-width: 100%;" src="https://i.ibb.co/D4GDZ1B/maxresdefault.jpg" />

## How to use it
1. Make a bootable WindowsPE drive.</br>
  https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-usb-bootable-drive</br>
2. Copy Windows-Deployment folder on the USB drive.</br>
2. Copy **install.wim** file from Windows installation media in the sources folder and copy it to Windows-Deployment folder on the USB drive. Rename it, if needed.</br>
  Windows 10 - https://www.microsoft.com/en-ca/software-download/windows10</br>
  Windows 11 - https://www.microsoft.com/en-ca/software-download/windows11</br>
  Convert ESD to WIM - https://www.poweriso.com/tutorials/convert-esd-to-wim.htm</br>
3. Boot on the WindowsPE environment.</br>
3. Find the drive letter of the USB key and start ApplyImage.bat</br>
4. Chose the **.wim** file you want.</br>
6. Chose index (Windows edition).</br>
7. Select disk to formate and apply windows installation.</br>
8. CompactOS (Yes or No) - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/compact-os</br>
9. Erase all data and continue? (Yes or No)</br>
10. 15 second timeout then reboot.</br>

## Getting ready
You must use the Sysprep /generalize command to generalize a complete Windows installation before you can use the installation for deployment to a new computer, whether you use imaging, hard disk duplication, or another method. Moving or copying a Windows image to a different computer without running the Sysprep /generalize command is not supported.

<b>Moving or copying a Windows image to a different PC without generalizing the PC is not supported.</b></br>
<b>If the hardware is not identical, severe system problems may result.</b>

The hardware must be connected to identical locations and must use the same drivers, and the drivers must have a consistent, unique naming scheme.</br>
https://en.wikipedia.org/wiki/Naming_convention_(programming)

Types of problems that can occur with a hardware-configuration change
Even seemingly minor changes to the hardware or hardware configuration can cause severe or easily-overlooked problems, such as the following:

- System instability.

- Inability to use some of the basic or extended functionality of a device.

- Extended boot times and extended installation times.

- Misnamed devices in the Devices and Printers folder, Device Manager, and other device-related user interfaces.

- Severe system problems that leave the computer in a non-bootable state. For more information about which devices Windows Setup relies upon to boot, see the Hardware-configuration changes that can cause the system to fail to boot section of this whitepaper

https://docs.microsoft.com/fr-ca/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview

https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/maintain-driver-configurations-when-capturing-a-windows-image

## Compact OS
Windows 10 and Windows 11 have tools and features that help you save disk space and optimize your image.

https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/compact-os

## BIOS/UEFI
Choose UEFI or legacy BIOS modes when booting into Windows PE (WinPE) or Windows Setup. After Windows is installed, if you need to switch firmware modes, you may be able to use the MBR2GPT tool.

In general, install Windows using the newer UEFI mode, as it includes more security features than the legacy BIOS mode. If you're booting from a network that only supports BIOS, you'll need to boot to legacy BIOS mode.

After Windows is installed, the device boots automatically using the same mode it was installed with.

https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/boot-to-uefi-mode-or-legacy-bios-mode

## Secure boot
Secure boot is a security standard developed by members of the PC industry to help make sure that a device boots using only software that is trusted by the Original Equipment Manufacturer (OEM). When the PC starts, the firmware checks the signature of each piece of boot software, including UEFI firmware drivers (also known as Option ROMs), EFI applications, and the operating system. If the signatures are valid, the PC boots, and the firmware gives control to the operating system.

https://docs.microsoft.com/fr-ca/windows-hardware/design/device-experiences/oem-secure-boot

https://docs.microsoft.com/fr-ca/windows/threat-protection/secure-the-windows-10-boot-process

## Disk partition requirement for using Windows RE tools on a UEFI-based computer
The disk partition for Windows RE tools must be at least 300 MB. Typically, between 250-300 MB is allocated for the Windows RE tools image (Winre.wim), depending on base language and added customizations.

The allocation for Windows RE must also include sufficient free space for backup utilities to capture the partition. Follow these guidelines to create the partition:</br>
If the partition is smaller than 500 MB, it must have at least 50 MB of free space.</br>
If the partition is 500 MB or larger, it must have at least 320 MB of free space.</br>
If the partition is larger than 1 GB, it must have at least 1 GB free of free space.</br>
This partition must use the following Type ID: DE94BBA4-06D1-4D40-A16A-BFD50179D6AC</br>

The Windows RE tools should be in a partition that's separate from the Windows partition. This separation supports automatic failover and the startup of partitions that are encrypted by using Windows BitLocker Drive Encryption.

https://docs.microsoft.com/en-us/troubleshoot/windows-client/windows-security/disk-partition-requirement-use-windows-re-tool

## WinPE: Mount and Customize
By adding those following commande to the WinPE Startup Scripts(startnet.cmd), when the USB key will boot on the WinPE environement the command will search for the folder 'Windows-Deployment', and will start ApplyImage.bat in the Windows-Deployment folder on the USB key.

```
for %%p in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist %%p:\Windows-Deployment set drive=%%p
echo The USB drive is on letter %drive%
call %drive%:\Windows-Deployment\ApplyImage.bat
```

https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-mount-and-customize?view=windows-10

https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeinit-and-startnetcmd-using-winpe-startup-scripts?view=windows-10

## WinPE Optional Components (OC) Reference
WinPE optional components are included in the the WinPE add-ons for the Windows Assessment and Deployment kit (ADK).

Optional components are available in Amd64 and Arm64 architectures. The OCs you add to your WinPE image must be from the same ADK build and have the same architecture as your WinPE image. You can find WinPE optional components in the following locations after you install the Windows PE add-ons for the ADK:

Amd64 C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\
Arm64 C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\arm64\WinPE_OCs\

https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-add-packages--optional-components-reference?view=windows-11

## OEM Deployment of Windows 10 for desktop editions</br>
https://docs.microsoft.com/fr-ca/windows-hardware/manufacture/desktop/oem-deployment-of-windows-10-for-desktop-editions

- Add drivers to your Windows image</br>
https://docs.microsoft.com/fr-ca/windows-hardware/manufacture/desktop/oem-deployment-of-windows-10-for-desktop-editions#add-drivers-to-your-windows-image

- Add a license agreement and info file</br>
https://docs.microsoft.com/fr-ca/windows-hardware/manufacture/desktop/oem-deployment-of-windows-10-for-desktop-editions#add-drivers-to-your-windows-image

- Customize Windows with an answer file</br>
https://docs.microsoft.com/fr-ca/windows-hardware/manufacture/desktop/oem-deployment-of-windows-10-for-desktop-editions#customize-windows-with-an-answer-file
