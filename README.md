# ExQt6

Qt6 UI toolkit for Elixir. Build desktop GUI applications using Qt6 through a lightweight C++ daemon process communicating via JSON over stdin/stdout.

## Features

- **16 widget types**: Window, Button, Label, LineEdit, ComboBox, CheckBox, RadioButton, Slider, SpinBox, ProgressBar, TabWidget, GroupBox, TextEdit, Tree, ButtonGroup, Splitter
- **4 layout types**: VBox, HBox, Grid (with row/col span), Form
- **Dialogs**: MessageBox, FileDialog
- **Properties**: enable/disable, visible/hidden, tooltip, CSS styling, geometry, size constraints
- **Events**: click, value_changed, text_changed, toggled, key press, mouse, timer tick, and more
- **OTP integration**: Supervised GenServer, auto-restart on daemon crash
- **Timer support**: Periodic events via QTimer

## Requirements

- Elixir ~> 1.18
- Erlang/OTP 26+
- Qt6 (Core, Widgets, GUI)
- C++17 compiler (g++ or clang++)
- pkg-config

### NixOS

The project includes a `shell.nix` that provides all dependencies:

```bash
nix-shell
```

### Other Linux

Install Qt6 dev packages and build tools via your package manager.

## Building the Daemon

The Qt daemon is a separate C++ binary that must be compiled before use:

```bash
cd native/qt_daemon
bash build.sh
```

Or from the project root with Nix:

```bash
nix-shell --run "cd native/qt_daemon && bash build.sh"
```

## Quick Start

```elixir
# Start the application (auto-started via OTP supervisor)
{:ok, app} = ExQt6.App.start_link(target: self())

# Wait for daemon to be ready
receive do
  {:app_ready, daemon} -> :ok
end

# Create a window with a button
{:ok, win} = ExQt6.Widget.new_window(app)
ExQt6.Widget.set_title(win, app, "Hello ExQt6")
ExQt6.Widget.resize(win, app, 400, 300)

{:ok, layout} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(layout, app, win)

{:ok, label} = ExQt6.Widget.new_label(app, "Click the button!")
ExQt6.Layout.add(layout, app, label)

{:ok, btn} = ExQt6.Widget.new_button(app, "Click me!")
ExQt6.Layout.add(layout, app, btn)

ExQt6.Widget.show(win, app)

# Handle events
receive do
  {:qt_event, %{"event" => "clicked"}} ->
    ExQt6.Widget.set_text(label, app, "Button clicked!")
end
```

## Examples

Run the included examples:

```bash
# Widget showcase (6 tabs with all features)
mix run --no-compile examples/widget_showcase.exs

# Task manager + Pomodoro dashboard
mix run --no-compile examples/task_manager.exs

# Auto-incrementing counter with start/stop/reset
mix run --no-compile examples/auto_counter.exs
```

## Architecture

```
Elixir Process (your code)
    |
    v
ExQt6.App (GenServer - manages daemon lifecycle)
    |
    v
ExQt6.DaemonReceiver (GenServer - owns the Port)
    |  (JSON over stdin/stdout)
    v
qt_daemon (C++17 Qt6 binary)
    |  (Qt event loop)
    v
Qt6 Widgets
```

All widget creation and manipulation happens through the daemon. Events flow back through the same channel.

## API Overview

### Widgets

| Function | Widget |
|----------|--------|
| `Widget.new_window/2` | QWidget (window) |
| `Widget.new_button/3` | QPushButton |
| `Widget.new_label/3` | QLabel |
| `Widget.new_lineedit/3` | QLineEdit |
| `Widget.new_combobox/3` | QComboBox |
| `Widget.new_checkbox/3` | QCheckBox |
| `Widget.new_radiobutton/3` | QRadioButton |
| `Widget.new_slider/3` | QSlider |
| `Widget.new_spinbox/5` | QSpinBox |
| `Widget.new_progressbar/4` | QProgressBar |
| `Widget.new_tabwidget/2` | QTabWidget |
| `Widget.new_groupbox/3` | QGroupBox |
| `Widget.new_textedit/3` | QPlainTextEdit |
| `Widget.new_tree/3` | QTreeWidget |
| `Widget.new_buttongroup/2` | QButtonGroup |
| `Widget.new_splitter/3` | QSplitter |

### Layouts

| Function | Layout |
|----------|--------|
| `Layout.vbox/2` | QVBoxLayout |
| `Layout.hbox/2` | QHBoxLayout |
| `Layout.grid/3` | QGridLayout |
| `Layout.form/2` | QFormLayout |

### Properties

```elixir
Widget.set_enabled(widget, app, false)     # disable
Widget.set_tooltip(widget, app, "tip")     # tooltip
Widget.set_style(widget, app, "background: red;")  # CSS
Widget.hide(widget, app)                   # hide
Widget.set_visible(widget, app, true)      # show
Widget.set_label_align(label, app, "center")
Widget.set_lineedit_echo(lineedit, app, "password")
Widget.set_fixed_size(widget, app, 200, 100)
```

### Dialogs

```elixir
Widget.msgbox(app, type: "warning", title: "Hey", text: "Careful!", buttons: ["ok"])
Widget.file_dialog(app, mode: "open", title: "Pick a file", filter: "All (*)")
```

### Timer

```elixir
{:ok, timer} = Timer.new(app, 1000)  # 1 second
Timer.start(timer, app)

receive do
  {:qt_event, %{"event" => "timer_tick", "id" => id}} ->
    IO.puts("tick!")
end
```

## License

MIT
