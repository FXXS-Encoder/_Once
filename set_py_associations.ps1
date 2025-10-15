$base = 'HKCU:\SOFTWARE\Classes'
$key1 = "$base\py_auto_file\shell\open\command"
$key2 = "$base\Applications\python.exe\shell\open\command"

# 如果第一个键不存在则创建
if (-not (Test-Path $key1)) {
    New-Item -Path $key1 -Force | Out-Null
}

# 获取第一个键的值
$val1 = (Get-ItemProperty -Path $key1 -ErrorAction SilentlyContinue).'(default)'

# 若无值，则设置为默认的相对路径
if (-not $val1) {
    # 获取当前脚本所在目录，组合绝对路径
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $pythonPath = Join-Path $scriptDir '..\x264_launcher\extra\VapourSynth-64\python.exe'
    $pythonPath = [System.IO.Path]::GetFullPath($pythonPath)
    $val1 = "`"$pythonPath`" `"%1`" %*"
    Set-ItemProperty -Path $key1 -Name '(default)' -Value $val1
} else {
    # 检查是否为相对路径，转为绝对路径
    if ($val1 -match '[.][.][\\\/]') {
        $matches = $val1 -match '^(.*?)python\.exe'
        $prefix = $matches[1]
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
        $pythonPath = Join-Path $scriptDir $prefix
        $pythonPath = [System.IO.Path]::GetFullPath($pythonPath)
        $val1 = $val1 -replace '^\S*python\.exe', "`"$pythonPath`""
    }
}

# 第二个键不存在则创建
if (-not (Test-Path $key2)) {
    New-Item -Path $key2 -Force | Out-Null
}

# 设置第二个路径的默认值为第一个的绝对路径
Set-ItemProperty -Path $key2 -Name '(default)' -Value $val1

Write-Host "注册表项已设置："
Write-Host "$key2 = $val1"