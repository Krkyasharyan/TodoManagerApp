cmake_minimum_required(VERSION 3.25)

project(MyTodoListApp)

# Find the necessary Qt packages
set(Qt6_DIR "C:/Qt/6.6.1/mingw_64/lib/cmake")
find_package(Qt6 COMPONENTS Core Quick Qml Sql QuickDialogs2 REQUIRED)

# Enable automatic MOC and RCC processing
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

include_directories(include)

# Source files
set(PROJECT_SOURCES
        src/main.cpp
        src/models/MTodoListModel.cpp
        src/db/DatabaseUtils.cpp
        include/models/MTodoListModel.h
        include/structs.h
        include/db/DatabaseUtils.h
        qml.qrc
)

# Define the executable
qt_add_executable(MyTodoListApp
    ${PROJECT_SOURCES}
)

# Link the necessary libraries
target_link_libraries(MyTodoListApp PRIVATE
    Qt6::Core Qt6::Quick Qt6::Qml Qt::Sql Qt::QuickDialogs2
)

# Specify C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
