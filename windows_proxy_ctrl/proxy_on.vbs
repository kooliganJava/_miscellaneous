Const HKCU=&H80000001 'HKEY_CURRENT_USER
Const HKLM=&H80000002 'HKEY_LOCAL_MACHINE

Const REG_SZ=1
Const REG_EXPAND_SZ=2
Const REG_BINARY=3
Const REG_DWORD=4
Const REG_MULTI_SZ=7

Const HKCU_IE_PROXY = "Software\Microsoft\Windows\CurrentVersion\Internet Settings"

Set oReg=GetObject("winmgmts:!root/default:StdRegProv")

Main

Sub Main()


strProxyServer = "10.12.132.250:8080"
strProxyOveride = "10.*;ncci.com;ncci.com;uwscnare.cna.com;*.us.cnare.com;cnanet.cna.com;*.reporting.cna.com;reporting.cna.com;*.passage.cna.com;passage.cna.com;*.ra.cna.com;ra.cna.com;*.vc.cna.com;vc.cna.com"

CreateValue HKCU,HKCU_IE_PROXY,"ProxyServer",strProxyServer,REG_SZ
CreateValue HKCU,HKCU_IE_PROXY,"ProxyEnable",1,REG_DWORD
CreateValue HKCU,HKCU_IE_PROXY,"ProxyOverride",strProxyOveride,REG_SZ
wscript.echo "Proxy Enabled" & vbcrlf & "(" & strProxyServer & ")"

End Sub

Function CreateValue(Key,SubKey,ValueName,Value,KeyType)
Select Case KeyType
Case REG_SZ
CreateValue = oReg.SetStringValue(Key,SubKey,ValueName,Value)
Case REG_EXPAND_SZ
CreateValue = oReg.SetExpandedStringValue(Key,SubKey,ValueName,Value)
Case REG_BINARY
CreateValue = oReg.SetBinaryValue(Key,SubKey,ValueName,Value)
Case REG_DWORD
CreateValue = oReg.SetDWORDValue(Key,SubKey,ValueName,Value)
Case REG_MULTI_SZ
CreateValue = oReg.SetMultiStringValue(Key,SubKey,ValueName,Value)
End Select
End Function

Function DeleteValue(Key, SubKey, ValueName)
DeleteValue = oReg.DeleteValue(Key,SubKey,ValueName)
End Function

Function GetValue(Key, SubKey, ValueName, KeyType)

Dim Ret

Select Case KeyType
Case REG_SZ
oReg.GetStringValue Key, SubKey, ValueName, Value
Ret = Value
Case REG_EXPAND_SZ
oReg.GetExpandedStringValue Key, SubKey, ValueName, Value
Ret = Value
Case REG_BINARY
oReg.GetBinaryValue Key, SubKey, ValueName, Value
Ret = Value
Case REG_DWORD
oReg.GetDWORDValue Key, SubKey, ValueName, Value
Ret = Value
Case REG_MULTI_SZ
oReg.GetMultiStringValue Key, SubKey, ValueName, Value
Ret = Value
End Select

GetValue = Ret
End Function

