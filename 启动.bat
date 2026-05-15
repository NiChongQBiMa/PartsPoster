@echo off
:: 零部件电子海报 — 启动器
:: 在 Processing IDE 中打开草图（按 Ctrl+R 或点击运行按钮即可启动）
:: 如果 Processing 安装在其他位置，请修改下方路径

set "PROCESSING=C:\Program Files\Processing\Processing.exe"

if exist "%PROCESSING%" (
    start "" "%PROCESSING%" "%~dp0zzx_.pde"
) else (
    echo 未找到 Processing，请检查安装路径。
    pause
)
