$RelativeFoldersToAdd = @(
    "bin"
    "bin/av1",
    "bin/DEE",
    "bin/ffmpeg/bin",
    "sc",
    "x264_launcher\extra\VapourSynth-64",
    "x264_launcher\toolset\x64" 
    # 示例：一个包含子目录的路径
    # "another\folder\structure" # 可以继续添加更多
)

# 获取脚本所在的目录
$ScriptPath = $PSScriptRoot
if (-not $ScriptPath) {
    # 如果 $PSScriptRoot 为空 (例如在ISE中直接运行选择的代码块)，尝试使用 $MyInvocation
    $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
# 获取脚本所在目录的上一级目录
try {
    $ParentPath = (Get-Item -LiteralPath $ScriptPath).Parent.FullName
}
catch {
    Write-Error "错误：无法确定脚本 '$ScriptPath' 的上层目录。"
    Read-Host "按 Enter 键退出"
    exit 1
}
Write-Host "脚本位置: $ScriptPath"
Write-Host "定位的上层路径 (Base Path): $ParentPath"
# 获取当前用户的Path环境变量
try {
    $CurrentUserPathString = [System.Environment]::GetEnvironmentVariable("Path", "User")
}
catch {
    Write-Error "错误：无法读取用户Path环境变量。错误信息: $($_.Exception.Message)"
    Read-Host "按 Enter 键退出"
    exit 1
}

# 将Path字符串分割成数组，以便检查，并去除空条目和首尾空格
$CurrentPathArray = @(
    $CurrentUserPathString -split ';'
    | ForEach-Object { $_.Trim() }
    | Where-Object { $_ -ne "" }
)

Write-Host "test'$CurrentPathArray'"
$PathsActuallyAdded = [System.Collections.Generic.List[string]]::new()
$PathsAlreadyExist = [System.Collections.Generic.List[string]]::new()
$PathsNotFound = [System.Collections.Generic.List[string]]::new()

# 遍历要添加的文件夹列表
foreach ($RelativeFolder in $RelativeFoldersToAdd) {
    $FullFolderPathToAdd = Join-Path -Path $ParentPath -ChildPath $RelativeFolder
    Write-Host "准备处理: $FullFolderPathToAdd (相对路径: $RelativeFolder)"

    # 1. 检查文件夹是否存在
    if (-not (Test-Path -LiteralPath $FullFolderPathToAdd -PathType Container)) {
        Write-Warning "  警告: 文件夹 '$FullFolderPathToAdd' 不存在，将跳过。"
        $PathsNotFound.Add($FullFolderPathToAdd)
        continue
    }

    # 2. 检查路径是否已存在于Path中 (不区分大小写)
    $AlreadyInPath = $false
    foreach($ExistingPath in $CurrentPathArray){
        if($ExistingPath -eq $FullFolderPathToAdd){ # PowerShell -eq 默认不区分大小写
            $AlreadyInPath = $true
            break
        }
    }

    if ($AlreadyInPath) {
        Write-Host "  信息: 路径 '$FullFolderPathToAdd' 已经存在于用户Path环境变量中。"
        $PathsAlreadyExist.Add($FullFolderPathToAdd)
    } else {
        Write-Host "  操作: 准备将 '$FullFolderPathToAdd' 添加到用户Path。"
        $PathsActuallyAdded.Add($FullFolderPathToAdd)
    }
}

Write-Host "--------------------------------------------------"

# 如果有新的路径需要添加
if ($PathsActuallyAdded.Count -gt 0) {
    Write-Host "正在将以下新路径添加到用户Path环境变量:"
    $PathsActuallyAdded | ForEach-Object { Write-Host "  - $_" }

    # 构建新的Path字符串
    # 将现有路径和新路径合并，并确保没有重复 (虽然前面检查了，但多一层保险，并处理顺序)
    $NewPathArray = $CurrentPathArray + $PathsActuallyAdded | Select-Object -Unique
    $NewUserPathString = $NewPathArray -join ';'

    try {
        # 设置新的用户Path环境变量
        [System.Environment]::SetEnvironmentVariable("Path", $NewUserPathString, "User")
        Write-Host -ForegroundColor Green "成功更新用户Path环境变量！"
        Write-Host "请注意：你需要关闭并重新打开任何命令提示符或PowerShell窗口，"
    }
    catch {
        Write-Error "错误：添加到用户Path环境变量失败。错误信息: $($_.Exception.Message)"
    }
} else {
    Write-Host "没有新的路径需要添加到用户Path环境变量。"
}

# 报告其他情况
if ($PathsAlreadyExist.Count -gt 0) {
    Write-Host -ForegroundColor Yellow "以下路径已存在于Path中，未作更改:"
    $PathsAlreadyExist | ForEach-Object { Write-Host "  - $_" }
}
if ($PathsNotFound.Count -gt 0) {
    Write-Host -ForegroundColor Red "以下配置的路径未找到，已被跳过:"
    $PathsNotFound | ForEach-Object { Write-Host "  - $_" }
}

Write-Host "--------------------------------------------------"
Read-Host "脚本执行完毕。按 Enter 键退出"