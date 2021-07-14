#!/bin/sh -e

# 创建临时文件夹
if [ ! -d build ]
then
    mkdir build
fi

if [ ! -d build/zip ]
then
    mkdir build/zip
fi

if [ ! -d build/framework ]
then
    mkdir build/framework
fi

if [ ! -d build/log ]
then
    mkdir build/log
fi