#!/bin/bash

# Define the build directory name
BUILD_DIR=build

# Check if the build directory exists, and if so, remove it
if [ -d "$BUILD_DIR" ]; then
    echo "Removing existing build directory..."
    rm -rf $BUILD_DIR
fi

# Create a new build directory
echo "Creating new build directory..."
mkdir $BUILD_DIR

# Navigate into the build directory
cd $BUILD_DIR

# Run CMake to configure the project
echo "Configuring project with CMake..."
cmake ..

# Compile the project with make using the number of available cores
echo "Building project..."
make -j$(nproc)

echo "Build finished."