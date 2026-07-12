{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    zig
    qt6.qtbase
    qt6.qtwayland
    erlang
    elixir
    pkg-config
    gcc
    cmake
  ];

  shellHook = ''
    export QT_PLUGIN_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"
    export QML2_IMPORT_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtQmlPrefix}"
  '';
}
