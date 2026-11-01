@echo off

chcp 936 >nul

setlocal EnableDelayedExpansion


title 瞎折腾吧 - 软件安装工具 v2.1

color 0A



:: =====================================
:: 自动定位根目录
:: =====================================


set CURRENT=%~dp0


if exist "%CURRENT%apps" (

    set ROOT=%CURRENT%

) else (

    if exist "%CURRENT%..\apps" (

        set ROOT=%CURRENT%..

    ) else (

        echo.
        echo 未找到根目录
        pause
        exit /b

    )

)



set APP_DIR=%ROOT%\apps

set CONFIG=%ROOT%\config.ini

set ADB=%ROOT%\adb.exe

set AAPT=%ROOT%\tools\aapt.exe

set ICONV=%ROOT%\tools\iconv.exe




:: =====================================
:: 检查文件
:: =====================================


if not exist "%ADB%" (

    echo.

    echo 未找到 adb.exe

    pause

    exit /b

)



if not exist "%AAPT%" (

    echo.

    echo 未找到 aapt.exe

    pause

    exit /b

)



if not exist "%ICONV%" (

    echo.

    echo 未找到 iconv.exe

    pause

    exit /b

)



if not exist "%CONFIG%" (

    echo.

    echo 未找到 config.ini

    pause

    exit /b

)





:: =====================================
:: 读取IP和端口
:: =====================================


set IP=

set PORT=



for /f "tokens=1,* delims==" %%a in ('type "%CONFIG%"') do (

    if /i "%%a"=="IP" set IP=%%b

    if /i "%%a"=="PORT" set PORT=%%b

)



if not defined IP (

    echo.

    echo config.ini没有IP

    pause

    exit /b

)



if not defined PORT (

    echo.

    echo config.ini没有PORT

    pause

    exit /b

)





:: =====================================
:: 连接电视
:: =====================================


cls


echo =====================================
echo.
echo        瞎折腾吧
echo.
echo        软件安装工具 v2.1
echo.
echo =====================================


echo.

echo 当前电视：

echo %IP%:%PORT%


echo.

echo 正在连接电视...



"%ADB%" disconnect >nul 2>&1


"%ADB%" connect %IP%:%PORT%



echo.

echo 等待ADB授权...

timeout /t 5 >nul



"%ADB%" devices



echo.



"%ADB%" devices | findstr "%IP%:%PORT%" | findstr "device" >nul



if errorlevel 1 (

    echo.

    echo =====================================

    echo.

    echo ADB连接失败

    echo.

    echo 请打开 瞎折腾TV助手

    echo.

    echo 或检查电视ADB调试授权

    echo.

    echo =====================================

    pause

    exit /b

)



echo.

echo ADB连接成功


timeout /t 2 >nul


goto SCAN

:: =====================================
:: 扫描APK
:: =====================================


:SCAN


cls


echo =====================================
echo.
echo          软件安装列表
echo.
echo =====================================


echo.



set COUNT=0



for %%i in ("%APP_DIR%\*.apk") do (

if exist "%%i" (

    set /a COUNT+=1


    set APK!COUNT!=%%~fi


    set NAME!COUNT!=未知应用

    set PACKAGE!COUNT!=未知包名

    set VERSION!COUNT!=未知版本




    "%AAPT%" dump badging "%%~fi" > "%TEMP%\apk_utf8.txt" 2>nul



    if exist "%TEMP%\apk_utf8.txt" (


        "%ICONV%" -f UTF-8 -t GBK "%TEMP%\apk_utf8.txt" > "%TEMP%\apk.txt" 2>nul



        if exist "%TEMP%\apk.txt" (



            for /f "tokens=2 delims='" %%a in ('findstr "application-label:" "%TEMP%\apk.txt"') do (

                set NAME!COUNT!=%%a

            )




            for /f "tokens=2 delims='" %%a in ('findstr "package:" "%TEMP%\apk.txt"') do (

                set PACKAGE!COUNT!=%%a

            )




            for /f "tokens=6 delims='" %%a in ('findstr "package:" "%TEMP%\apk.txt"') do (

                set VERSION!COUNT!=%%a

            )



        )

    )



    del "%TEMP%\apk_utf8.txt" >nul 2>&1

    del "%TEMP%\apk.txt" >nul 2>&1



)

)



if %COUNT%==0 (

    echo.

    echo apps没有APK

    pause

    exit /b

)



echo.

echo 发现应用：

echo.



for /l %%i in (1,1,%COUNT%) do (

    echo %%i. !NAME%%i!

    echo    包名：!PACKAGE%%i!

    echo    版本：!VERSION%%i!

    echo.

)



set /a ALL=%COUNT%+1



echo %ALL%. 安装全部

echo.

echo 0. 返回


echo.



set /p CHOICE=请选择：



if "%CHOICE%"=="0" exit /b


if "%CHOICE%"=="%ALL%" goto INSTALL_ALL


if defined APK%CHOICE% goto INSTALL_ONE


goto SCAN

:: =====================================
:: 安装前处理
:: =====================================


:INSTALL_PREP


echo.

echo 正在检查安装权限...



"%ADB%" -s %IP%:%PORT% shell settings put secure install_non_market_apps 1 >nul 2>&1


"%ADB%" -s %IP%:%PORT% shell settings put global verifier_verify_adb_installs 0 >nul 2>&1



goto :eof







:: =====================================
:: 单个安装
:: =====================================


:INSTALL_ONE


cls


echo =====================================
echo.
echo 正在安装：
echo.
echo !NAME%CHOICE%!
echo.
echo 包名：
echo !PACKAGE%CHOICE%!
echo.
echo 版本：
echo !VERSION%CHOICE%!
echo.
echo =====================================


echo.


call :INSTALL_PREP


echo.

echo 正在安装，请稍候...



"%ADB%" -s %IP%:%PORT% install -r "!APK%CHOICE%!" >install_result.txt 2>&1



findstr /i "Success" install_result.txt >nul



if not errorlevel 1 (

    echo.

    echo =====================================

    echo.

    echo 安装完成！

    echo.

    echo =====================================


) else (


    echo.

    echo =====================================

    echo.

    echo 安装失败！

    echo.

    echo 错误信息：

    echo.

    type install_result.txt

    echo.

    echo =====================================


)



del install_result.txt >nul 2>&1



pause


goto SCAN







:: =====================================
:: 全部安装
:: =====================================


:INSTALL_ALL


cls


echo =====================================
echo.
echo       开始安装全部软件
echo.
echo =====================================



call :INSTALL_PREP



for /l %%i in (1,1,%COUNT%) do (



echo.

echo -------------------------------------

echo 软件：

echo !NAME%%i!


echo.

echo 包名：

echo !PACKAGE%%i!


echo.

echo 版本：

echo !VERSION%%i!


echo -------------------------------------



echo.

echo 正在安装：

echo !NAME%%i!



"%ADB%" -s %IP%:%PORT% install -r "!APK%%i!" >install_result.txt 2>&1



findstr /i "Success" install_result.txt >nul



if not errorlevel 1 (

    echo.

    echo 安装完成！

) else (

    echo.

    echo 安装失败！

    echo.

    type install_result.txt

)



del install_result.txt >nul 2>&1



)



echo.

echo =====================================

echo.

echo 全部安装完成

echo.

echo =====================================



pause


goto SCAN







:: =====================================
:: 错误
:: =====================================


:ERROR


echo.

echo =====================================

echo.

echo          程序启动失败

echo.

echo 请检查：

echo.

echo 1. config.ini 是否存在

echo.

echo 2. adb.exe 是否存在

echo.

echo 3. tools工具是否完整

echo.

echo =====================================


pause

exit /b