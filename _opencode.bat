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
set "OPENCODE_NATIVE_CMD=%CODEBAT_DIR%\node_modules\.bin\opencode.cmd"
set "OPENCODE_CMD=%OPENCODE_NATIVE_CMD%"
set "OPENCODE_X64_DIR=%CODEBAT_DIR%\.opencode\windows-x64-runtime"
set "OPENCODE_X64_CMD=%OPENCODE_X64_DIR%\node_modules\opencode-windows-x64-baseline\bin\opencode.exe"

set "XDG_CONFIG_HOME=%CODEBAT_DIR%\.opencode\config"
set "XDG_DATA_HOME=%CODEBAT_DIR%\.opencode\data"
set "XDG_CACHE_HOME=%CODEBAT_DIR%\.opencode\cache"

where node >nul 2>&1
if errorlevel 1 goto :missing_node

where npm >nul 2>&1
if errorlevel 1 goto :missing_npm

if exist "%OPENCODE_NATIVE_CMD%" (
    call "%OPENCODE_NATIVE_CMD%" --version >nul 2>&1
    if not errorlevel 1 goto :select_runtime
)

echo OpenCode is not installed locally. Installing it now...
call npm install --save-dev --ignore-scripts opencode-ai
if errorlevel 1 goto :install_failed

echo Running OpenCode's required installation step...
call npm rebuild opencode-ai
if errorlevel 1 goto :install_failed

if not exist "%OPENCODE_NATIVE_CMD%" goto :install_failed
call "%OPENCODE_NATIVE_CMD%" --version >nul 2>&1
if errorlevel 1 goto :install_failed

:select_runtime
rem Native Windows ARM64 Bun builds cannot load OpenTUI through FFI yet.
for /f "delims=" %%A in ('node -p "process.arch" 2^>nul') do set "NODE_ARCH=%%A"
if /I not "%NODE_ARCH%"=="arm64" goto :run_opencode

node -e "const nativeVersion = require('./node_modules/opencode-ai/package.json').version; const x64Version = require('./.opencode/windows-x64-runtime/node_modules/opencode-windows-x64-baseline/package.json').version; process.exit(nativeVersion === x64Version ? 0 : 1)" >nul 2>&1
if errorlevel 1 goto :install_x64_runtime

call "%OPENCODE_X64_CMD%" --version >nul 2>&1
if errorlevel 1 goto :install_x64_runtime
set "OPENCODE_CMD=%OPENCODE_X64_CMD%"
goto :run_opencode

:install_x64_runtime
for /f "delims=" %%V in ('node -p "require('./node_modules/opencode-ai/package.json').version" 2^>nul') do set "OPENCODE_VERSION=%%V"
if not defined OPENCODE_VERSION goto :arm64_compat_failed

echo Installing OpenCode's x64 compatibility runtime for Windows ARM64...
call npm install --prefix "%OPENCODE_X64_DIR%" --no-save --ignore-scripts --force "opencode-windows-x64-baseline@%OPENCODE_VERSION%"
if errorlevel 1 goto :arm64_compat_failed

call "%OPENCODE_X64_CMD%" --version >nul 2>&1
if errorlevel 1 goto :arm64_compat_failed
set "OPENCODE_CMD=%OPENCODE_X64_CMD%"

:run_opencode
pushd "%WORKSPACE_DIR%" >nul 2>&1
if errorlevel 1 goto :workspace_failed

echo Running OpenCode in "%CD%"...
call "%OPENCODE_CMD%" %*
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

:arm64_compat_failed
echo ERROR: OpenCode's Windows ARM64 compatibility runtime could not be installed.
echo OpenCode's native Windows ARM64 TUI is currently unsupported upstream.
echo You can still run the web interface with: _opencode.bat web
goto :fail

:workspace_failed
echo ERROR: Could not open the parent workspace directory:
echo "%WORKSPACE_DIR%"

:fail
pause
popd
endlocal & exit /b 1
