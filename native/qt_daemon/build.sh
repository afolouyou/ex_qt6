#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
QT_PREFIX=$(pkg-config --variable=prefix Qt6Core)
if [ -x "$QT_PREFIX/libexec/moc" ]; then
    MOC="$QT_PREFIX/libexec/moc"
elif [ -x "$QT_PREFIX/lib/qt6/moc" ]; then
    MOC="$QT_PREFIX/lib/qt6/moc"
else
    MOC="$(command -v moc)"
fi
"$MOC" main.cpp -o main.moc
g++ -std=c++17 -O2 -fPIC main.cpp -o qt_daemon -Wl,-z,notext $(pkg-config --cflags --libs Qt6Core Qt6Widgets Qt6Gui)
echo "qt_daemon compiled successfully"
