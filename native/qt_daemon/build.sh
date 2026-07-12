#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
QT_PREFIX=$(pkg-config --variable=prefix Qt6Core)
"$QT_PREFIX/libexec/moc" main.cpp -o main.moc
g++ -std=c++17 -O2 main.cpp -o qt_daemon $(pkg-config --cflags --libs Qt6Core Qt6Widgets Qt6Gui)
echo "qt_daemon compiled successfully"
