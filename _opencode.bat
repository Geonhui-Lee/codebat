@echo off
setlocal

pushd "%~dp0" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not open the Codebat directory.
    pause
    exit /b 1
)

set "CODEBAT_DIR=%CD%"
for %%I in ("%CODEBAT_DIR%\..") do set "WORKSPACE_DIR=%%~fI"
set "OPENCODE_CMD=%CODEBAT_DIR%\node_modules\.bin\opencode.cmd"

set "XDG_CONFIG_HOME=%CODEBAT_DIR%\.opencode\config"
set "XDG_DATA_HOME=%CODEBAT_DIR%\.opencode\data"
set "XDG_CACHE_HOME=%CODEBAT_DIR%\.opencode\cache"

where node >nul 2>&1
if errorlevel 1 goto :missing_node

where npm >nul 2>&1
if errorlevel 1 goto :missing_npm

if exist "%OPENCODE_CMD%" (
    call "%OPENCODE_CMD%" --version >nul 2>&1
    if not errorlevel 1 goto :run_opencode
)

echo OpenCode is not installed locally. Installing it now...
call npm install --save-dev opencode-ai
if errorlevel 1 goto :install_failed

if not exist "%OPENCODE_CMD%" goto :install_failed
call "%OPENCODE_CMD%" --version >nul 2>&1
if errorlevel 1 goto :install_failed

:run_opencode
pushd "%WORKSPACE_DIR%" >nul 2>&1
if errorlevel 1 goto :workspace_failed

echo Running OpenCode in "%CD%"...
call "%OPENCODE_CMD%"
set "exitCode=%errorlevel%"

popd
popd
endlocal & exit /b %exitCode%

:missing_node
echo ERROR: Node.js is not installed or is not available on PATH.
echo Install Node.js, then try again.
goto :fail

:missing_npm
echo ERROR: npm is not installed or is not available on PATH.
echo Install npm, then try again.
goto :fail

:install_failed
echo ERROR: OpenCode could not be installed with npm.
goto :fail

:workspace_failed
echo ERROR: Could not open the parent workspace directory:
echo "%WORKSPACE_DIR%"

:fail
pause
popd
endlocal & exit /b 1
