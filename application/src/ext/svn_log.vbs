'
' Authors:
' Devin Lee, 2017
'
dim objArgs


Set objArgs = WScript.Arguments
num = objArgs.Count
if num < 1 then
    MsgBox "Usage: [CScript | WScript] svn_log.vbs url|path", vbCritical, "Invalid arguments"
    WScript.Quit 1
end if

sBaseFile = objArgs(0)

' Open TortoiseSVN  using TortoiseProc.exe

Set WshShell = WScript.CreateObject("WScript.Shell")
exitStatus = WshShell.Run("TortoiseProc.exe /command:log /path:""" + sBaseFile + """ " , 0, True)
If exitStatus > 0 Then
	' Todo: Handle error!
End If



Wscript.Quit
