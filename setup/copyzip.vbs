Set fso = CreateObject("Scripting.FileSystemObject")
If NOT fso.FolderExists("D:\bkit.pt\scripts\client\3rd-party\shadowspawn") Then
fso.CreateFolder("D:\bkit.pt\scripts\client\3rd-party\shadowspawn")
End If
set objShell = CreateObject("Shell.Application")
set FilesInZip=objShell.NameSpace("D:\bkit.pt\scripts\client\setup\shadowspawn\ShadowSpawn-0.2.2-x64.zip").items
objShell.NameSpace("D:\bkit.pt\scripts\client\3rd-party\shadowspawn").CopyHere FilesInZip, 16
Set fso = Nothing
Set objShell = Nothing
