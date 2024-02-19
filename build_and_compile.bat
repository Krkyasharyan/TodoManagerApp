@echo off
set QT_PLUGIN_PATH=C:\Qt\6.6.1\mingw_64\plugins

if exist build rmdir /s /q build

cmake -G "MinGW Makefiles" -S . -B build -DCMAKE_BUILD_TYPE=Release

cd build

make -j

windeployqt --no-compiler-runtime --no-translations --qmldir ../qml ./MyTodoListApp.exe

echo Build and compile completed.
