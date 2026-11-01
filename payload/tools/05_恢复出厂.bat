@echo off

chcp 936 >nul

setlocal EnableDelayedExpansion


title 瞎折腾吧 - 安卓电视恢复出厂助手 v2.1


color 0A



:: =====================================
:: 返回根目录
:: =====================================


cd /d "%~dp0.."


set ROOT=%cd%

set CONFIG=%ROOT%\config.ini

set ADB=%ROOT%\adb.exe



:: =====================================
:: 检查配置
:: =====================================


if not exist "%CONFIG%" (

echo.

echo =====================================

echo.

echo 未找到 config.ini

echo.

echo 请先运行 瞎折腾TV助手

echo.

echo =====================================

pause

exit /b

)



:: =====================================
:: 读取配置
:: =====================================


set IP=

set PORT=



for /f "tokens=1,* delims==" %%a in (%CONFIG%) do (

    if /i "%%a"=="IP" set IP=%%b

    if /i "%%a"=="PORT" set PORT=%%b

)



if "%PORT%"=="" (

set PORT=5555

)




:: =====================================
:: 标题
:: =====================================


:START


cls


echo =====================================

echo.

echo       瞎折腾吧

echo.

echo    安卓电视恢复出厂助手 v2.1

echo.

echo =====================================


echo.

echo 当前电视：

echo %IP%:%PORT%


echo.



:: =====================================
:: ADB连接
:: =====================================


echo 正在连接电视...



"%ADB%" connect %IP%:%PORT% >nul 2>&1



timeout /t 3 >nul



"%ADB%" devices >adb_check.txt



findstr "%IP%:%PORT%" adb_check.txt | findstr "unauthorized" >nul



if not errorlevel 1 (

cls

echo =====================================

echo.

echo          ADB未授权

echo.

echo =====================================


echo.

echo 请在电视点击：

echo.

echo 允许ADB调试

echo.

echo 勾选：

echo 始终允许此电脑


pause

goto START

)



findstr "%IP%:%PORT%" adb_check.txt | findstr "device" >nul



if errorlevel 1 (

cls

echo =====================================

echo.

echo          ADB连接失败

echo.

echo =====================================


echo.

echo 请检查：

echo.

echo 1.电视和电脑是否同一网络

echo.

echo 2.无线调试是否开启

echo.

echo 3.IP和端口是否正确


pause

goto START

)



del adb_check.txt >nul 2>&1



echo.

echo =====================================

echo.

echo          ADB连接成功

echo.

echo =====================================



timeout /t 2 >nul




:: =====================================
:: 获取设备信息
:: =====================================


set MODEL=

set BRAND=



for /f "delims=" %%a in ('"%ADB%" -s %IP%:%PORT% shell getprop ro.product.model') do (

set MODEL=%%a

)



for /f "delims=" %%a in ('"%ADB%" -s %IP%:%PORT% shell getprop ro.product.brand') do (

set BRAND=%%a

)



cls



echo =====================================

echo.

echo       当前设备信息

echo.

echo =====================================


echo.

echo 品牌：

echo %BRAND%


echo.

echo 型号：

echo %MODEL%



echo.



:: =====================================
:: 提示
:: =====================================


echo =====================================

echo.

echo 注意：

echo.

echo 即将进入 Recovery 模式

echo.

echo 请使用遥控器操作：

echo.

echo 1. 选择：

echo    Wipe data/factory reset

echo.

echo 2. 选择：

echo    Yes

echo.

echo 3. 选择：

echo    Reboot system now

echo.

echo =====================================



echo.



choice /c 12 /n /m "确认进入Recovery？ 1继续 2返回："



if errorlevel 2 goto EXIT




echo.

echo 正在进入 Recovery...



timeout /t 3 >nul



"%ADB%" -s %IP%:%PORT% reboot recovery



echo.

echo =====================================

echo.

echo 命令已发送

echo.

echo 请等待电视进入Recovery界面

echo.

echo =====================================



pause


goto EXIT




:EXIT


exit /b