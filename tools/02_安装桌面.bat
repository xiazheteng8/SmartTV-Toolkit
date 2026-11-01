@echo off
chcp 936 >nul
setlocal EnableDelayedExpansion

title 瞎折腾吧 - 安卓电视桌面安装工具 v2.1

color 0A


:: =====================================
:: 定位根目录
:: =====================================

cd /d "%~dp0.."

set ROOT=%cd%

set CONFIG=%ROOT%\config.ini

set ADB=%ROOT%\adb.exe

set LAUNCHER=%ROOT%\Launcher



:: =====================================
:: 检查配置
:: =====================================

if not exist "%CONFIG%" (

echo.
echo =====================================
echo.
echo          未找到 config.ini
echo.
echo       请先运行 瞎折腾TV助手
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



if "%IP%"=="" (

echo.

echo IP读取失败

pause

exit /b

)


if "%PORT%"=="" (

set PORT=5555

)



:: =====================================
:: ADB连接
:: =====================================


cls


echo =====================================
echo.
echo          瞎折腾吧
echo.
echo       桌面安装工具 v2.1
echo.
echo =====================================


echo.

echo 当前电视：

echo %IP%:%PORT%


echo.

echo 正在连接电视...



"%ADB%" disconnect >nul 2>&1

"%ADB%" connect %IP%:%PORT% >nul 2>&1

timeout /t 3 >nul



"%ADB%" devices >temp_adb.txt



findstr "%IP%:%PORT%" temp_adb.txt | findstr "device" >nul



if errorlevel 1 (

del temp_adb.txt >nul 2>&1

echo.

echo =====================================
echo.
echo          ADB连接失败
echo.
echo       本工具不支持独立使用
echo.
echo      请打开 瞎折腾TV助手
echo.
echo =====================================

pause

exit /b

)


del temp_adb.txt >nul 2>&1



echo.

echo ADB连接成功！

timeout /t 2 >nul



:: =====================================
:: 菜单
:: =====================================


:MENU


cls


echo =====================================
echo.
echo             请选择桌面
echo.
echo =====================================

echo.

echo 1. ATV Launcher

echo.

echo 2. 当贝桌面

echo.

echo 3. Emotn UI

echo.

echo 4. Projectivy Launcher

echo.

echo 5. 不安装桌面

echo.


choice /c 12345 /n /m "请选择："



if errorlevel 5 goto NO_LAUNCHER

if errorlevel 4 goto PROJECTIVY

if errorlevel 3 goto EMOTN

if errorlevel 2 goto DB

if errorlevel 1 goto ATV



:: =====================================
:: 桌面选择
:: =====================================


:ATV

set PKG=ca.dstudio.atvlauncher.free

set APK=%LAUNCHER%\ATV_Launcher.apk

goto INSTALL



:DB

set PKG=com.dangbei.tvlauncher

set APK=%LAUNCHER%\dbzm.apk

goto INSTALL



:EMOTN

set PKG=com.oversea.aslauncher

set APK=%LAUNCHER%\EmotnUI.apk

goto INSTALL



:PROJECTIVY

set PKG=com.spocky.projengmenu

set APK=%LAUNCHER%\ProjectivyLaunche.apk

goto INSTALL



:: =====================================
:: 不安装
:: =====================================


:NO_LAUNCHER


cls


echo =====================================
echo.
echo          不安装第三方桌面
echo.
echo =====================================


echo.

echo 注意：

echo.

echo 如果后续精简系统桌面

echo 可能导致无法进入系统

echo.

pause


goto EXIT




:: =====================================
:: 安装桌面
:: =====================================


:INSTALL


cls


echo =====================================
echo.

echo 正在安装：

echo.

echo %APK%

echo.

echo =====================================



if not exist "%APK%" (

echo.

echo 找不到安装文件：

echo %APK%

pause

goto MENU

)



"%ADB%" -s %IP%:%PORT% install -r "%APK%"



if errorlevel 1 (

echo.

echo 安装失败

pause

goto MENU

)



echo.

echo 安装完成！


echo.

echo 正在设置默认桌面...



"%ADB%" -s %IP%:%PORT% shell cmd package set-home-activity %PKG%



echo.

echo 当前HOME：

"%ADB%" -s %IP%:%PORT% shell cmd package resolve-activity --brief android.intent.action.MAIN android.intent.category.HOME



echo.

echo 测试启动桌面...



"%ADB%" -s %IP%:%PORT% shell monkey -p %PKG% 1



timeout /t 5 >nul



echo.

echo 桌面设置完成！

pause


goto EXIT




:: =====================================
:: 退出
:: =====================================


:EXIT


exit /b