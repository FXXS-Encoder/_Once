$ws = New-Object -ComObject WScript.Shell
$s = $ws.CreateShortcut("$PSScriptRoot\UsEac3to.lnk")
$S.TargetPath = "$PSScriptRoot\..\UsEac3to\UsEac3To.exe"
$S.WorkingDirectory  = "$PSScriptRoot\..\UsEac3to\"
$S.Save()
$ws = New-Object -ComObject WScript.Shell
$s = $ws.CreateShortcut("$PSScriptRoot\BDInfo.lnk")
$S.TargetPath = "$PSScriptRoot\..\BDInfo\BDInfo.exe"
$S.WorkingDirectory  = "$PSScriptRoot\..\BDInfo\"
$S.Save()