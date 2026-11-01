@echo off
chcp 936 >nul
setlocal EnableDelayedExpansion


title 瞎折腾吧 - 安卓电视精简工具 v2.1

color 0A


:: ===============================
:: 返回根目录
:: ===============================


cd /d "%~dp0.."


set ROOT=%cd%


set BRAND_DIR=%ROOT%\brands

set CONFIG=%ROOT%\config.ini



:: ===============================
:: 检查配置
:: ===============================


if not exist "%CONFIG%" (

echo.
echo 未找到 config.ini
echo 请先运行主程序输入电视IP
pause
goto BACK

)



:: ===============================
:: 读取IP
:: ===============================


for /f "tokens=1,* delims==" %%a in (config.ini) do (

if /i "%%a"=="IP" set IP=%%b

)



:: ===============================
:: ADB连接
:: ===============================


cls


echo =====================================
echo.
echo        瞎折腾吧
echo.
echo        安卓电视精简工具 v2.1
echo.
echo =====================================


echo.

echo 当前电视：

echo %IP%


echo.

echo 正在连接电视...



adb connect %IP%:5555 >nul



timeout /t 3 >nul



adb devices >temp_adb.txt



findstr "%IP%" temp_adb.txt | findstr "device" >nul



if errorlevel 1 (

echo.

echo ADB连接失败

echo 请检查：
echo 1. IP是否正确
echo 2. 电视是否开启ADB
echo 3. 是否允许授权

pause

goto BACK

)



del temp_adb.txt >nul 2>&1



echo.

echo ADB连接成功！

timeout /t 2 >nul




:: ===============================
:: 读取品牌
:: ===============================


if not exist "%BRAND_DIR%\current_brand.txt" (

echo.

echo 未找到：

echo brands\current_brand.txt

pause

goto BACK

)



set /p BRAND=<"%BRAND_DIR%\current_brand.txt"



echo.

echo 当前品牌：

echo %BRAND%


timeout /t 2 >nul




:: ===============================
:: 加载列表
:: ===============================


set NORMAL_FILE=%BRAND_DIR%\%BRAND%_normal.txt

set DEEP_FILE=%BRAND_DIR%\%BRAND%_deep.txt

set DESKTOP_FILE=%BRAND_DIR%\%BRAND%_desktop.txt


goto MAIN_MENU

:: ===============================
:: 主菜单
:: ===============================


:MAIN_MENU


cls


echo =====================================
echo.
echo          %BRAND% 精简工具
echo.
echo =====================================


echo.

echo 1. 开始精简

echo.

echo 2. 查看当前品牌

echo.

echo 3. 返回主菜单

echo.


choice /c 123 /n /m "请选择："



if errorlevel 3 goto BACK

if errorlevel 2 goto SHOW_BRAND

if errorlevel 1 goto NORMAL_START






:: ===============================
:: 显示品牌
:: ===============================


:SHOW_BRAND


cls

echo.

echo 当前品牌：

echo %BRAND%

echo.

pause

goto MAIN_MENU






:: ===============================
:: 普通精简
:: ===============================


:NORMAL_START


cls


echo =====================================
echo.
echo        普通精简
echo.
echo =====================================


echo.

echo 将执行：

echo %NORMAL_FILE%


echo.

echo 普通精简主要删除：

echo - 广告组件

echo - 推荐服务

echo - 无用预装软件

echo.

echo 风险等级：低

echo.



choice /c 12 /n /m "是否开始？ 1开始 2返回："



if errorlevel 2 goto MAIN_MENU



call :CLEAN "%NORMAL_FILE%"



cls


echo.

echo 普通精简完成！

echo.



choice /c 12 /n /m "是否继续深度精简？ 1继续 2返回："



if errorlevel 2 goto MAIN_MENU



goto DEEP_START








:: ===============================
:: 深度精简
:: ===============================


:DEEP_START


cls


echo =====================================
echo.
echo        深度精简
echo.
echo =====================================


echo.


echo 将执行：

echo %DEEP_FILE%


echo.


echo 注意：

echo.

echo 深度精简会删除更多系统服务

echo 可能影响：

echo - 系统功能

echo - 部分遥控功能

echo - OTA更新

echo.

echo 建议确认已经备份

echo.



choice /c 12 /n /m "确认继续？ 1继续 2返回："



if errorlevel 2 goto MAIN_MENU



call :CLEAN "%DEEP_FILE%"




cls


echo.

echo 深度精简完成！

echo.



choice /c 12 /n /m "是否继续桌面精简？ 1继续 2返回："



if errorlevel 2 goto MAIN_MENU



goto DESKTOP_START








:: ===============================
:: 桌面精简
:: ===============================


:DESKTOP_START


cls


echo =====================================
echo.
echo        桌面精简
echo.
echo =====================================



echo.


echo 将执行：

echo %DESKTOP_FILE%


echo.


echo 注意：

echo.

echo 桌面精简会处理系统桌面

echo.

echo 请确认：

echo 1. 已安装第三方桌面

echo 默认桌面验证仅供参考，不限制卸载

echo.


echo 风险等级：高


echo.



choice /c 12 /n /m "确认继续？ 1继续 2返回："



if errorlevel 2 goto MAIN_MENU



call :CLEAN "%DESKTOP_FILE%"



cls


echo.

echo =====================================

echo.

echo 全部精简完成！

echo.

echo =====================================


pause


goto BACK

:: ===============================
:: 执行精简
:: ===============================


:CLEAN


set CLEAN_FILE=%~1


:: ===============================
:: 获取当前电视软件列表
:: ===============================

echo.

echo 正在读取电视软件列表...

adb shell pm list packages > "%ROOT%\installed_packages.txt"

echo 软件列表读取完成

echo.


if not exist "%CLEAN_FILE%" (

echo.

echo 找不到：

echo %CLEAN_FILE%

pause

exit /b

)



set LOG_DIR=%ROOT%\logs


if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"



set USER_FILE=%LOG_DIR%\user_uninstall.txt

set DISABLE_FILE=%LOG_DIR%\disable.txt

set SYSTEM_FILE=%LOG_DIR%\system_uninstall.txt

set FAIL_FILE=%LOG_DIR%\failed.txt



del "%USER_FILE%" >nul 2>&1

del "%DISABLE_FILE%" >nul 2>&1

del "%SYSTEM_FILE%" >nul 2>&1

del "%FAIL_FILE%" >nul 2>&1




cls


echo =====================================

echo.

echo 正在执行：

echo %CLEAN_FILE%

echo.

echo =====================================



for /f "usebackq delims=" %%a in ("%CLEAN_FILE%") do (

call :PROCESS "%%a"

)



exit /b








:: ===============================
:: 单个软件处理
:: ===============================


:PROCESS


set PKG=%~1



if "%PKG%"=="" exit /b



:: 去除空格

for /f "tokens=* delims= " %%b in ("%PKG%") do (

set PKG=%%b

)




:: 跳过注释


echo %PKG% | findstr "^#" >nul


if not errorlevel 1 exit /b





echo.

echo -------------------------------------

echo 正在处理：

echo %PKG%

echo -------------------------------------






:: ===============================
:: 检测软件是否存在
:: ===============================


findstr /i /x "package:%PKG%" "%ROOT%\installed_packages.txt" >nul



if errorlevel 1 (

echo.

echo [跳过]

echo %PKG%

echo 软件不存在

exit /b

)






:: ===============================
:: 第一层
:: 用户卸载
:: ===============================


echo.

echo 尝试用户层面卸载...



adb shell pm uninstall --user 0 %PKG% >result.txt 2>&1



findstr /i "success" result.txt >nul



if not errorlevel 1 (


echo.

echo [成功卸载]

echo %PKG%


echo %PKG%>>"%USER_FILE%"


exit /b

)







:: ===============================
:: 第二层
:: 禁用
:: ===============================


echo.

echo 用户卸载失败

echo 尝试禁用...



adb shell pm disable-user --user 0 %PKG% >result.txt 2>&1



findstr /i "disabled" result.txt >nul



if not errorlevel 1 (


echo.

echo [成功禁用]

echo %PKG%


echo %PKG%>>"%DISABLE_FILE%"


exit /b

)







:: ===============================
:: 第三层
:: 系统卸载
:: ===============================


echo.

echo 禁用失败

echo 尝试系统卸载...



adb shell pm uninstall %PKG% >result.txt 2>&1



findstr /i "success" result.txt >nul



if not errorlevel 1 (


echo.

echo [系统卸载成功]

echo %PKG%


echo %PKG%>>"%SYSTEM_FILE%"


exit /b

)








:: ===============================
:: 失败
:: ===============================


echo.

echo [失败]

echo %PKG%



echo %PKG%>>"%FAIL_FILE%"



type result.txt



exit /b

:: ===============================
:: 返回结果显示
:: ===============================


:RESULT


cls


echo =====================================

echo.

echo          精简完成

echo.

echo =====================================



echo.

echo 成功卸载：

echo -------------------------------------


if exist "%USER_FILE%" (

type "%USER_FILE%"

) else (

echo 无

)



echo.



echo 成功禁用：

echo -------------------------------------


if exist "%DISABLE_FILE%" (

type "%DISABLE_FILE%"

) else (

echo 无

)




echo.



echo 系统卸载：

echo -------------------------------------


if exist "%SYSTEM_FILE%" (

type "%SYSTEM_FILE%"

) else (

echo 无

)





echo.



echo 失败：

echo -------------------------------------


if exist "%FAIL_FILE%" (

type "%FAIL_FILE%"

) else (

echo 无

)




echo.


echo =====================================

echo.

echo 已完成

echo.

echo 按任意键返回主菜单

echo.

echo =====================================



pause >nul



goto BACK







:: ===============================
:: 返回主程序
:: ===============================


:BACK


del result.txt >nul 2>&1

del "%ROOT%\installed_packages.txt" >nul 2>&1


exit /b