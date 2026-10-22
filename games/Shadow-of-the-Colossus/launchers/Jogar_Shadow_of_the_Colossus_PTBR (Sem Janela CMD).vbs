Set WshShell = CreateObject("WScript.Shell")
rootFolder = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
targetDir = rootFolder & "\SOTC_PC_PTBR\sotc-v1.0.0-ptbr-windows-x64"
WshShell.CurrentDirectory = targetDir
WshShell.Run """" & targetDir & "\sotc.exe""", 0, False
