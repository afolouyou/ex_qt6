defmodule ExQt6Test do
  use ExUnit.Case
  doctest ExQt6

  test "module exists" do
    assert {:module, ExQt6} = Code.ensure_loaded(ExQt6)
  end
end

defmodule ExQt6.AppTest do
  use ExUnit.Case

  test "App.start_link creates a supervised process" do
    {:ok, pid} = ExQt6.App.start_link(target: self())
    assert is_pid(pid)
    assert Process.alive?(pid)
    Process.sleep(600)

    assert_receive {:app_ready, %ExQt6.Daemon{}}, 3000
  end
end

defmodule ExQt6.WidgetTest do
  use ExUnit.Case

  setup do
    {:ok, app} = ExQt6.App.start_link(target: self())
    Process.sleep(600)
    assert_receive {:app_ready, _}, 3000
    %{app: app}
  end

  test "creates a window", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :window}} = ExQt6.Widget.new_window(app)
  end

  test "creates a button", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :button}} = ExQt6.Widget.new_button(app, "OK")
  end

  test "creates a label", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :label}} = ExQt6.Widget.new_label(app, "Hello")
  end

  test "creates a lineedit", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :lineedit}} = ExQt6.Widget.new_lineedit(app, "placeholder")
  end

  test "creates a combobox", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :combobox}} = ExQt6.Widget.new_combobox(app, ["a", "b"])
  end

  test "creates a checkbox", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :checkbox}} = ExQt6.Widget.new_checkbox(app, "Check me")
  end

  test "creates a radiobutton", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :radiobutton}} = ExQt6.Widget.new_radiobutton(app, "Option")
  end

  test "creates a slider", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :slider}} = ExQt6.Widget.new_slider(app, min: 0, max: 100)
  end

  test "creates a spinbox", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :spinbox}} = ExQt6.Widget.new_spinbox(app, 0, 100, value: 50)
  end

  test "creates a progressbar", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :progressbar}} = ExQt6.Widget.new_progressbar(app, 0, 100, value: 50)
  end

  test "creates a tabwidget", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :tabwidget}} = ExQt6.Widget.new_tabwidget(app)
  end

  test "creates a groupbox", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :groupbox}} = ExQt6.Widget.new_groupbox(app, "Group")
  end

  test "creates a textedit", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :textedit}} = ExQt6.Widget.new_textedit(app)
  end

  test "creates a tree", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :tree}} = ExQt6.Widget.new_tree(app, headers: ["A", "B"])
  end

  test "creates a splitter", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :splitter}} = ExQt6.Widget.new_splitter(app)
  end

  test "creates a buttongroup", %{app: app} do
    assert {:ok, %ExQt6.Widget{type: :buttongroup}} = ExQt6.Widget.new_buttongroup(app)
  end

  test "set_text and get_text on lineedit", %{app: app} do
    {:ok, le} = ExQt6.Widget.new_lineedit(app)
    ExQt6.Widget.set_text(le, app, "hello")
    assert {:ok, "hello"} = ExQt6.Widget.get_text(le, app)
  end

  test "set_value and get_value on spinbox", %{app: app} do
    {:ok, sb} = ExQt6.Widget.new_spinbox(app, 0, 100, value: 10)
    ExQt6.Widget.set_value(sb, app, 77)
    assert {:ok, 77} = ExQt6.Widget.get_value(sb, app)
  end

  test "set_checked and get_checked on checkbox", %{app: app} do
    {:ok, cb} = ExQt6.Widget.new_checkbox(app, "test")
    ExQt6.Widget.set_checked(cb, app, true)
    assert {:ok, true} = ExQt6.Widget.get_checked(cb, app)
    ExQt6.Widget.set_checked(cb, app, false)
    assert {:ok, false} = ExQt6.Widget.get_checked(cb, app)
  end

  test "widget properties: enable, tooltip, style", %{app: app} do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_enabled(btn, app, false)
    ExQt6.Widget.set_enabled(btn, app, true)
    ExQt6.Widget.set_tooltip(btn, app, "tip")
    ExQt6.Widget.set_style(btn, app, "background: red;")
    ExQt6.Widget.hide(btn, app)
    ExQt6.Widget.set_visible(btn, app, true)
  end
end

defmodule ExQt6.LayoutTest do
  use ExUnit.Case

  setup do
    {:ok, app} = ExQt6.App.start_link(target: self())
    Process.sleep(600)
    assert_receive {:app_ready, _}, 3000
    %{app: app}
  end

  test "creates vbox", %{app: app} do
    assert {:ok, %ExQt6.Layout{}} = ExQt6.Layout.vbox(app)
  end

  test "creates hbox", %{app: app} do
    assert {:ok, %ExQt6.Layout{}} = ExQt6.Layout.hbox(app)
  end

  test "creates grid", %{app: app} do
    assert {:ok, %ExQt6.Layout{}} = ExQt6.Layout.grid(app)
  end

  test "creates form", %{app: app} do
    assert {:ok, %ExQt6.Layout{}} = ExQt6.Layout.form(app)
  end

  test "set_layout + add widget", %{app: app} do
    {:ok, win} = ExQt6.Widget.new_window(app)
    {:ok, layout} = ExQt6.Layout.vbox(app)
    {:ok, btn} = ExQt6.Widget.new_button(app, "OK")
    ExQt6.Layout.set_layout(layout, app, win)
    ExQt6.Layout.add(layout, app, btn)
  end

  test "grid_add_widget with span", %{app: app} do
    {:ok, grid} = ExQt6.Layout.grid(app)
    {:ok, btn1} = ExQt6.Widget.new_button(app, "A")
    {:ok, btn2} = ExQt6.Widget.new_button(app, "B")
    ExQt6.Layout.grid_add_widget(grid, app, btn1, 0, 0)
    ExQt6.Layout.grid_add_widget(grid, app, btn2, 1, 0, col_span: 2)
  end

  test "form_add_row", %{app: app} do
    {:ok, form} = ExQt6.Layout.form(app)
    {:ok, le} = ExQt6.Widget.new_lineedit(app)
    ExQt6.Layout.form_add_row(form, app, "Name:", le)
  end
end

defmodule ExQt6.TimerTest do
  use ExUnit.Case

  setup do
    {:ok, app} = ExQt6.App.start_link(target: self())
    Process.sleep(600)
    assert_receive {:app_ready, _}, 3000
    %{app: app}
  end

  test "creates and starts timer", %{app: app} do
    {:ok, timer} = ExQt6.Timer.new(app, 100)
    ExQt6.Timer.start(timer, app)
    assert_receive {:qt_event, %{"event" => "timer_tick"}}, 500
    ExQt6.Timer.stop(timer, app)
  end
end
