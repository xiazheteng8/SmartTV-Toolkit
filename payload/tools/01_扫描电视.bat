@echo off

cd /d "%~dp0.."

set ROOT=%cd%

set CONFIG=%ROOT%\config.ini

setlocal EnableDelayedExpansion

chcp 936 >nul
title 瞎折腾吧 - 安卓电视扫描工具 v2.1


color 0A


if not exist scan mkdir scan
if not exist tools mkdir tools
if not exist brands mkdir brands



:START


cls


echo =====================================
echo.
echo          瞎折腾吧
echo.
echo       安卓电视扫描工具 v2.1
echo.
echo       快速扫描 + aapt深度解析
echo.
echo =====================================


echo.



if not exist config.ini (

echo.

echo 未找到 config.ini

echo.

echo 请先运行主程序完成ADB连接

pause

exit /b

)

:: =====================================
:: 读取配置
:: =====================================

set IP=
set PORT=


for /f "tokens=1,* delims==" %%a in ('type "%CONFIG%"') do (

    if /i "%%a"=="IP" set IP=%%b

    if /i "%%a"=="PORT" set PORT=%%b

)



echo 当前电视：

echo %IP%:%PORT%


echo.


echo 正在连接电视...


adb disconnect >nul 2>&1


timeout /t 1 >nul


adb connect %IP%:%PORT% >nul 2>&1


timeout /t 5 >nul


adb devices >scan\devices.txt



findstr "%IP%:%PORT%" scan\devices.txt | findstr /r "device$" >nul


if errorlevel 1 (

echo.

echo ADB连接失败

echo.

echo 当前ADB状态：

type scan\devices.txt

echo.

pause

goto START

)


cls

echo.
echo ADB连接成功！
echo.



echo 正在读取电视信息...



for /f "delims=" %%a in ('adb shell getprop ro.product.manufacturer') do set BRAND=%%a


:: 清理品牌名称，只保留第一个单词
for /f "tokens=1" %%b in ("%BRAND%") do set BRAND=%%b


for /f "delims=" %%a in ('adb shell getprop ro.product.model') do set MODEL=%%a

for /f "delims=" %%a in ('adb shell getprop ro.build.version.release') do set ANDROID=%%a



cls

echo =====================================
echo.
echo 电视信息
echo.
echo =====================================


echo 品牌：

echo %BRAND%


echo.

echo 型号：

echo %MODEL%


echo.

echo Android：

echo %ANDROID%


echo.



echo 正在快速扫描应用列表...



adb shell pm list packages -f >scan\packages.txt



set COUNT=0


for /f %%a in (scan\packages.txt) do (

set /a COUNT+=1

)



echo.

echo 快速扫描完成！

echo.

echo 共发现：

echo %COUNT% 个应用



timeout /t 3 >nul



cls


echo =====================================
echo.
echo        快速扫描完成！
echo.
echo =====================================


echo.

echo 设备：

echo %BRAND% %MODEL%


echo.

echo 共发现：

echo %COUNT% 个应用


echo.


echo =====================================

echo.

echo 深度解析说明：

echo.

echo 将读取电视中的APK文件

echo.

echo 使用aapt解析真实应用名称

echo.

echo 生成：

echo.

echo 1. 应用扫描报告

echo.

echo 2. 品牌精简配置文件

echo.

echo.

echo =====================================


echo.



choice /c 12 /n /m "1.开始深度解析  2.跳过"



if errorlevel 2 goto FINISH


if errorlevel 1 goto DEEP_SCAN

:: =====================================
:: 深度解析
:: =====================================


:DEEP_SCAN


cls


echo =====================================
echo.
echo        深度解析开始
echo.
echo =====================================


echo.



if not exist tools\aapt.exe (

echo.

echo 错误：
echo 未找到 tools\aapt.exe

echo.

echo 请放入：

echo TV_Scan\tools\aapt.exe

echo.

pause

goto FINISH

)



echo.

echo aapt检测成功！

echo.

echo 开始准备解析...

timeout /t 3 >nul




del scan\扫描结果.txt >nul 2>&1




(
echo ====================================
echo 安卓电视应用深度扫描报告
echo ====================================
echo.
echo 品牌：
echo %BRAND%
echo.
echo 型号：
echo %MODEL%
echo.
echo Android：
echo %ANDROID%
echo.
echo 应用数量：
echo %COUNT%
echo.
echo ====================================
echo.

)>scan\扫描结果.txt






set /a CURRENT=0





for /f "tokens=1,2 delims==" %%a in (scan\packages.txt) do (


set /a CURRENT+=1



set APKPATH=%%a

set PKG=%%b



set APKPATH=!APKPATH:package:=!





cls



echo =====================================

echo.

echo       正在解析应用

echo.

echo =====================================



echo.

echo 当前包名：

echo !PKG!



echo.

echo 当前进度：

echo !CURRENT! / %COUNT%



echo.



set TEMPAPK=scan\temp.apk



del "!TEMPAPK!" >nul 2>&1




echo 正在读取APK...




adb pull "!APKPATH!" "!TEMPAPK!" >nul 2>&1





set APPNAME=解析失败




if exist "!TEMPAPK!" (



tools\aapt.exe dump badging "!TEMPAPK!" > scan\aapt_utf8.txt



tools\iconv.exe -f UTF-8 -t GBK scan\aapt_utf8.txt > scan\aapt.txt 2>nul





for /f "tokens=2 delims='" %%c in ('findstr "application-label-zh-CN" scan\aapt.txt') do (

set APPNAME=%%c

)





if "!APPNAME!"=="解析失败" (

for /f "tokens=2 delims='" %%c in ('findstr "application-label-zh:" scan\aapt.txt') do (

set APPNAME=%%c

)

)






if "!APPNAME!"=="解析失败" (

for /f "tokens=2 delims='" %%c in ('findstr "application-label:" scan\aapt.txt') do (

set APPNAME=%%c

)

)



)



(
echo ------------------------------------
echo 应用名称：
echo !APPNAME!

echo.

echo 包名：
echo !PKG!

echo.

echo APK路径：
echo !APKPATH!

echo.

)>>scan\扫描结果.txt




)



:: =====================================
:: 生成四分类精简文件
:: =====================================


call :MAKE_CLEAN_LIST



goto FINISH

:: =====================================
:: 自动生成四分类文件
:: =====================================


:MAKE_CLEAN_LIST


echo.
echo 正在生成分类文件...
echo.



set NORMAL=brands\%BRAND%_normal.txt

set DEEP=brands\%BRAND%_deep.txt

set DESKTOP=brands\%BRAND%_desktop.txt

set SAFE=brands\%BRAND%_safe.txt

echo %BRAND%>brands\current_brand.txt


del "%NORMAL%" >nul 2>&1

del "%DEEP%" >nul 2>&1

del "%DESKTOP%" >nul 2>&1

del "%SAFE%" >nul 2>&1





type nul > "%NORMAL%"

type nul > "%DEEP%"

type nul > "%DESKTOP%"

type nul > "%SAFE%"




for /f "tokens=1,2 delims==" %%a in (scan\packages.txt) do (

set PKG=%%b


call :CHECK_PACKAGE


)





echo.

echo 分类文件生成完成

echo.

echo 普通精简：

echo %NORMAL%

echo.

echo 深度精简：

echo %DEEP%

echo.

echo 桌面：

echo %DESKTOP%

echo.

echo 保护：

echo %SAFE%

echo.



exit /b

:: =====================================
:: 分类判断
:: =====================================


:CHECK_PACKAGE



if "!PKG!"=="" exit /b






:: =====================================
:: 1. 系统组件
:: 生成 safe 文件
:: =====================================



echo !PKG! | findstr /i "android google com.google framework systemui settings packageinstaller permissioncontroller providers documentsui inputmethod keyboard ime contacts phone bluetooth nfc network connectivity telephony shell webview" >nul



if not errorlevel 1 (


echo !PKG!>>"%SAFE%"


exit /b

)






:: =====================================
:: 2. 系统桌面
:: =====================================



echo !PKG! | findstr /i "launcher home tvhome mitv.tvhome leanback" >nul



if not errorlevel 1 (


echo !PKG!>>"%DESKTOP%"


exit /b

)







:: =====================================
:: 3. 深度精简
:: =====================================



echo !PKG! | findstr /i "game gamecenter recorder screenrecord screen music video player voice airkan miplay upnp smartshare smarthome lockscreen gallery karaoke cloudcontrol handbook calendar alarm" >nul



if not errorlevel 1 (


echo !PKG!>>"%DEEP%"


exit /b

)







:: =====================================
:: 4. 普通精简
:: 剩余全部进入普通列表
:: =====================================



echo !PKG!>>"%NORMAL%"




exit /b


:: =====================================
:: 扫描完成
:: =====================================


:FINISH


cls


echo =====================================
echo.
echo          扫描完成！
echo.
echo =====================================


echo.

echo 已生成分类文件：

echo.

echo 系统组件：
echo brands\%BRAND%_safe.txt

echo.

echo 普通精简：
echo brands\%BRAND%_normal.txt

echo.

echo 深度精简：
echo brands\%BRAND%_deep.txt

echo.

echo 系统桌面：
echo brands\%BRAND%_desktop.txt


echo.


pause


goto EXIT





:: =====================================
:: 退出
:: =====================================


:EXIT


del scan\temp.apk >nul 2>&1
del scan\aapt.txt >nul 2>&1
del scan\aapt_utf8.txt >nul 2>&1


echo.

echo 已退出


pause


exit /b