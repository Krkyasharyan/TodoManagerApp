@echo off
set QT_PLUGIN_PATH=C:\Qt\6.6.1\mingw_64\plugins

cd build

make -j

windeployqt --no-compiler-runtime --no-translations --qmldir ../qml ./MyTodoListApp.exe

echo Compile completed.
