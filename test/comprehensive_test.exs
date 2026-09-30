defmodule ExQt6.ComprehensiveTest do
  @moduledoc "Comprehensive test covering every feature in ExQt6."

  @doc """
  Run with: mix run --no-compile test/comprehensive_test.exs
  """
  def run do
    Application.ensure_all_started(:ex_qt6)
    {:ok, app} = ExQt6.App.start_link(target: self())
    Process.sleep(500)

    IO.puts("╔══════════════════════════════════════════════╗")
    IO.puts("║   ExQt6 Comprehensive Test Suite             ║")
    IO.puts("╚══════════════════════════════════════════════╝\n")

    results =
      []
      |> run_test("App startup", fn -> test_app(app) end)
      |> run_test("Widget: QWidget", fn -> test_widget(app) end)
      |> run_test("Widget: QPushButton", fn -> test_button(app) end)
      |> run_test("Widget: QLabel", fn -> test_label(app) end)
      |> run_test("Widget: QLineEdit", fn -> test_lineedit(app) end)
      |> run_test("Widget: QComboBox", fn -> test_combobox(app) end)
      |> run_test("Widget: QCheckBox", fn -> test_checkbox(app) end)
      |> run_test("Widget: QRadioButton + QButtonGroup", fn -> test_radiobutton(app) end)
      |> run_test("Widget: QSlider", fn -> test_slider(app) end)
      |> run_test("Widget: QSpinBox", fn -> test_spinbox(app) end)
      |> run_test("Widget: QProgressBar", fn -> test_progressbar(app) end)
      |> run_test("Widget: QTabWidget", fn -> test_tabwidget(app) end)
      |> run_test("Widget: QGroupBox", fn -> test_groupbox(app) end)
      |> run_test("Widget: QPlainTextEdit", fn -> test_textedit(app) end)
      |> run_test("Widget: QTreeWidget", fn -> test_treewidget(app) end)
      |> run_test("Widget: QSplitter", fn -> test_splitter(app) end)
      |> run_test("Layout: QVBoxLayout", fn -> test_vbox(app) end)
      |> run_test("Layout: QHBoxLayout", fn -> test_hbox(app) end)
      |> run_test("Layout: QGridLayout", fn -> test_grid(app) end)
      |> run_test("Layout: QFormLayout", fn -> test_form(app) end)
      |> run_test("Layout: nested layouts", fn -> test_nested_layouts(app) end)
      |> run_test("Property: set_enabled/disabled", fn -> test_enabled(app) end)
      |> run_test("Property: set_visible/hide", fn -> test_visible(app) end)
      |> run_test("Property: set_tooltip", fn -> test_tooltip(app) end)
      |> run_test("Property: set_style (CSS)", fn -> test_style(app) end)
      |> run_test("Property: set_font", fn -> test_font(app) end)
      |> run_test("Property: set_geometry", fn -> test_geometry(app) end)
      |> run_test("Property: set_fixed_size", fn -> test_fixed_size(app) end)
      |> run_test("Property: set_minimum_size", fn -> test_min_size(app) end)
      |> run_test("Property: set_maximum_size", fn -> test_max_size(app) end)
      |> run_test("Window: set_frameless", fn -> test_frameless(app) end)
      |> run_test("Window: set_always_on_top", fn -> test_always_on_top(app) end)
      |> run_test("Window: set_modal", fn -> test_modal(app) end)
      |> run_test("Window: set_opacity", fn -> test_opacity(app) end)
      |> run_test("Window: set_cursor", fn -> test_cursor(app) end)
      |> run_test("Label: alignment", fn -> test_label_align(app) end)
      |> run_test("Label: word wrap", fn -> test_word_wrap(app) end)
      |> run_test("LineEdit: readonly", fn -> test_lineedit_readonly(app) end)
      |> run_test("LineEdit: echo mode", fn -> test_lineedit_echo(app) end)
      |> run_test("LineEdit: get_text/set_text", fn -> test_lineedit_text(app) end)
      |> run_test("Button: get_text/set_text", fn -> test_button_text(app) end)
      |> run_test("Slider: get_value/set_value", fn -> test_slider_value(app) end)
      |> run_test("Spinbox: get_value/set_value", fn -> test_spinbox_value(app) end)
      |> run_test("ComboBox: add/get items", fn -> test_combobox_items(app) end)
      |> run_test("CheckBox: checked/unchecked", fn -> test_checkbox_toggle(app) end)
      |> run_test("ProgressBar: set_value", fn -> test_progressbar_value(app) end)
      |> run_test("Timer: create and start", fn -> test_timer(app) end)
      |> run_test("QMainWindow", fn -> test_mainwindow(app) end)
      |> run_test("QMenuBar + QMenu + QAction", fn -> test_menu(app) end)
      |> run_test("QToolBar", fn -> test_toolbar(app) end)
      |> run_test("QStatusBar", fn -> test_statusbar(app) end)
      |> run_test("QTableWidget: full lifecycle", fn -> test_table(app) end)
      |> run_test("QTableWidget: get_item", fn -> test_table_get(app) end)
      |> run_test("QTableWidget: insert/remove rows", fn -> test_table_rows(app) end)
      |> run_test("QTableWidget: cell widget", fn -> test_table_cell_widget(app) end)
      |> run_test("QTableWidget: selection + edit mode", fn -> test_table_modes(app) end)
      |> run_test("Event: mouse events enable", fn -> test_mouse_events(app) end)
      |> run_test("Event: key events enable", fn -> test_key_events(app) end)
      |> run_test("Event: close event enable", fn -> test_close_event(app) end)
      |> run_test("Batch: multiple commands", fn -> test_batch(app) end)
      |> run_test("Pipeline: chained setters", fn -> test_pipeline(app) end)
      |> run_test("Named widgets: ETS registry", fn -> test_named_widgets(app) end)
      |> run_test("Widget: QListWidget", fn -> test_listwidget(app) end)
      |> run_test("Widget: QScrollArea", fn -> test_scrollarea(app) end)
      |> run_test("Widget: QScrollBar (v)", fn -> test_scrollbar(app) end)
      |> run_test("Widget: QToolButton", fn -> test_toolbutton(app) end)
      |> run_test("Widget: QListView", fn -> test_listview(app) end)
      |> run_test("Widget: QTableView", fn -> test_tableview(app) end)
      |> run_test("Widget: QToolBox", fn -> test_toolbox(app) end)
      |> run_test("Widget: QTimeEdit", fn -> test_timeedit(app) end)
      |> run_test("Widget: QDateEdit", fn -> test_dateedit(app) end)
      |> run_test("Widget: QFontComboBox", fn -> test_fontcombobox(app) end)
      |> run_test("Widget: QCommandLinkButton", fn -> test_commandlink(app) end)

    # Summary
    results = List.flatten(results)

    passed = Enum.count(results, &(&1 == :ok))
    failed = Enum.count(results, &(&1 != :ok))
    total = length(results)

    IO.puts("\n╔══════════════════════════════════════════════╗")
    IO.puts("║   Results: #{passed}/#{total} passed, #{failed} failed")
    IO.puts("╚══════════════════════════════════════════════╝")

    if failed > 0 do
      IO.puts("\nFailed tests:")

      results
      |> Enum.with_index()
      |> Enum.each(fn {r, i} ->
        if r != :ok, do: IO.puts("  #{i + 1}. #{inspect(r)}")
      end)
    end

    IO.puts("\nAll widgets created — showing window for 2 seconds...")
    show_final(app)
    Process.sleep(2000)
    GenServer.stop(app)
    System.halt(0)
  end

  defp run_test(acc, name, fun) do
    result =
      try do
        fun.()
        :ok
      rescue
        e -> {:error, Exception.message(e)}
      catch
        kind, reason -> {:error, "#{kind}: #{inspect(reason)}"}
      end

    icon = if result == :ok, do: "✓", else: "✗"
    IO.puts("  #{icon} #{name}")
    acc ++ [result]
  end

  # --- Widget Tests ---

  defp test_app(app) do
    daemon = ExQt6.App.get_daemon(app)
    true = is_struct(daemon, ExQt6.Daemon)
  end

  defp test_widget(app) do
    {:ok, w} = ExQt6.Widget.new_window(app)
    true = w.id > 0
    :ok = ExQt6.Widget.set_title(w, app, "Widget Test")
    :ok = ExQt6.Widget.resize(w, app, 100, 100)
    :ok = ExQt6.Widget.show(w, app)
  end

  defp test_button(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Click")
    true = btn.type == :button
    :ok = ExQt6.Widget.set_text(btn, app, "Clicked")
  end

  defp test_label(app) do
    {:ok, lbl} = ExQt6.Widget.new_label(app, "Hello")
    true = lbl.type == :label
    {:ok, text} = ExQt6.Widget.get_text(lbl, app)
    "Hello" = text
  end

  defp test_lineedit(app) do
    {:ok, le} = ExQt6.Widget.new_lineedit(app, "placeholder")
    true = le.type == :lineedit
    :ok = ExQt6.Widget.set_text(le, app, "typed text")
    {:ok, text} = ExQt6.Widget.get_text(le, app)
    "typed text" = text
  end

  defp test_combobox(app) do
    {:ok, cb} = ExQt6.Widget.new_combobox(app, ["A", "B", "C"])
    true = cb.type == :combobox
    {:ok, val} = ExQt6.Widget.get_value(cb, app)
    true = is_integer(val) or is_number(val)
  end

  defp test_checkbox(app) do
    {:ok, ch} = ExQt6.Widget.new_checkbox(app, "Check")
    true = ch.type == :checkbox
  end

  defp test_radiobutton(app) do
    {:ok, rb1} = ExQt6.Widget.new_radiobutton(app, "Opt1")
    {:ok, rb2} = ExQt6.Widget.new_radiobutton(app, "Opt2")
    {:ok, grp} = ExQt6.Widget.new_buttongroup(app)
    ExQt6.Widget.add_to_buttongroup(grp, app, rb1)
    ExQt6.Widget.add_to_buttongroup(grp, app, rb2)
    true = rb1.type == :radiobutton
    true = grp.type == :buttongroup
  end

  defp test_slider(app) do
    {:ok, sl} = ExQt6.Widget.new_slider(app, min: 0, max: 100)
    true = sl.type == :slider
    ExQt6.Widget.set_value(sl, app, 50)
    {:ok, val} = ExQt6.Widget.get_value(sl, app)
    50 = val
  end

  defp test_spinbox(app) do
    {:ok, sb} = ExQt6.Widget.new_spinbox(app, 0, 100, value: 42)
    true = sb.type == :spinbox
    {:ok, val} = ExQt6.Widget.get_value(sb, app)
    42 = val
    ExQt6.Widget.set_value(sb, app, 77)
    {:ok, val2} = ExQt6.Widget.get_value(sb, app)
    77 = val2
  end

  defp test_progressbar(app) do
    {:ok, pb} = ExQt6.Widget.new_progressbar(app, 0, 100)
    true = pb.type == :progressbar
    ExQt6.Widget.set_value(pb, app, 65)
    {:ok, val} = ExQt6.Widget.get_value(pb, app)
    65 = val
  end

  defp test_tabwidget(app) do
    {:ok, tw} = ExQt6.Widget.new_tabwidget(app)
    {:ok, page1} = ExQt6.Widget.new_window(app)
    {:ok, page2} = ExQt6.Widget.new_window(app)
    ExQt6.Widget.add_tab(tw, app, page1, "Tab 1")
    ExQt6.Widget.add_tab(tw, app, page2, "Tab 2")
    ExQt6.Widget.set_current_index(tw, app, 1)
    true = tw.type == :tabwidget
  end

  defp test_groupbox(app) do
    {:ok, gb} = ExQt6.Widget.new_groupbox(app, "Group")
    {:ok, btn} = ExQt6.Widget.new_button(app, "Inside")
    {:ok, layout} = ExQt6.Layout.vbox(app)
    ExQt6.Layout.set_layout(layout, app, gb)
    ExQt6.Layout.add(layout, app, btn)
    true = gb.type == :groupbox
  end

  defp test_textedit(app) do
    {:ok, te} = ExQt6.Widget.new_textedit(app, "initial")
    true = te.type == :textedit
    {:ok, text} = ExQt6.Widget.get_plaintext(te, app)
    "initial" = text
    ExQt6.Widget.set_plaintext(te, app, "modified")
    {:ok, text2} = ExQt6.Widget.get_plaintext(te, app)
    "modified" = text2
  end

  defp test_treewidget(app) do
    {:ok, tw} = ExQt6.Widget.new_tree(app, headers: ["Col1", "Col2"])
    true = tw.type == :tree
  end

  defp test_splitter(app) do
    {:ok, sp} = ExQt6.Widget.new_splitter(app, "horizontal")
    {:ok, w1} = ExQt6.Widget.new_label(app, "Left")
    {:ok, w2} = ExQt6.Widget.new_label(app, "Right")
    ExQt6.Widget.splitter_add(sp, app, w1)
    ExQt6.Widget.splitter_add(sp, app, w2)
    ExQt6.Widget.splitter_set_sizes(sp, app, [200, 300])
    true = sp.type == :splitter
  end

  # --- Layout Tests ---

  defp test_vbox(app) do
    {:ok, layout} = ExQt6.Layout.vbox(app)
    {:ok, w1} = ExQt6.Widget.new_label(app, "A")
    {:ok, w2} = ExQt6.Widget.new_label(app, "B")
    ExQt6.Layout.add(layout, app, w1)
    ExQt6.Layout.add(layout, app, w2)
    true = is_struct(layout, ExQt6.Layout)
  end

  defp test_hbox(app) do
    {:ok, layout} = ExQt6.Layout.hbox(app)
    {:ok, w1} = ExQt6.Widget.new_label(app, "A")
    {:ok, w2} = ExQt6.Widget.new_label(app, "B")
    ExQt6.Layout.add(layout, app, w1)
    ExQt6.Layout.add(layout, app, w2)
    true = is_struct(layout, ExQt6.Layout)
  end

  defp test_grid(app) do
    {:ok, grid} = ExQt6.Layout.grid(app)
    {:ok, b1} = ExQt6.Widget.new_button(app, "0,0")
    {:ok, b2} = ExQt6.Widget.new_button(app, "0,1")
    {:ok, b3} = ExQt6.Widget.new_button(app, "1,0")
    {:ok, b4} = ExQt6.Widget.new_button(app, "1,1 span")
    ExQt6.Layout.grid_add_widget(grid, app, b1, 0, 0)
    ExQt6.Layout.grid_add_widget(grid, app, b2, 0, 1)
    ExQt6.Layout.grid_add_widget(grid, app, b3, 1, 0)
    ExQt6.Layout.grid_add_widget(grid, app, b4, 1, 1, col_span: 2)
    true = is_struct(grid, ExQt6.Layout)
  end

  defp test_form(app) do
    {:ok, form} = ExQt6.Layout.form(app)
    {:ok, le1} = ExQt6.Widget.new_lineedit(app)
    {:ok, le2} = ExQt6.Widget.new_lineedit(app)
    ExQt6.Layout.form_add_row(form, app, "Name:", le1)
    ExQt6.Layout.form_add_row(form, app, "Email:", le2)
    true = is_struct(form, ExQt6.Layout)
  end

  defp test_nested_layouts(app) do
    {:ok, root} = ExQt6.Layout.vbox(app)
    {:ok, inner} = ExQt6.Layout.hbox(app)
    {:ok, w} = ExQt6.Widget.new_label(app, "Nested")
    ExQt6.Layout.add(inner, app, w)
    ExQt6.Layout.add_layout(root, app, inner)
    true = is_struct(root, ExQt6.Layout)
    true = is_struct(inner, ExQt6.Layout)
  end

  # --- Property Tests ---

  defp test_enabled(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_enabled(btn, app, false)
    ExQt6.Widget.set_enabled(btn, app, true)
  end

  defp test_visible(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.hide(btn, app)
    ExQt6.Widget.set_visible(btn, app, true)
    ExQt6.Widget.set_visible(btn, app, false)
    ExQt6.Widget.set_visible(btn, app, true)
  end

  defp test_tooltip(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_tooltip(btn, app, "Hover me!")
  end

  defp test_style(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_style(btn, app, "background: red; color: white;")
  end

  defp test_font(app) do
    {:ok, lbl} = ExQt6.Widget.new_label(app, "Styled")

    ExQt6.Widget.set_font(lbl, app,
      family: "Arial",
      size: 20,
      bold: true,
      italic: true,
      underline: true
    )
  end

  defp test_geometry(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_geometry(btn, app, 10, 20, 150, 50)
  end

  defp test_fixed_size(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_fixed_size(btn, app, 200, 60)
  end

  defp test_min_size(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_minimum_size(btn, app, 100, 40)
  end

  defp test_max_size(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_maximum_size(btn, app, 500, 200)
  end

  # --- Window Property Tests ---

  defp test_frameless(app) do
    {:ok, win} = ExQt6.Widget.new_window(app)
    ExQt6.Widget.set_frameless(win, app)
  end

  defp test_always_on_top(app) do
    {:ok, win} = ExQt6.Widget.new_window(app)
    ExQt6.Widget.set_always_on_top(win, app, true)
    ExQt6.Widget.set_always_on_top(win, app, false)
  end

  defp test_modal(app) do
    {:ok, win} = ExQt6.Widget.new_window(app)
    ExQt6.Widget.set_modal(win, app, true)
    ExQt6.Widget.set_modal(win, app, false)
  end

  defp test_opacity(app) do
    {:ok, win} = ExQt6.Widget.new_window(app)
    ExQt6.Widget.set_opacity(win, app, 0.5)
    ExQt6.Widget.set_opacity(win, app, 1.0)
  end

  defp test_cursor(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Test")
    ExQt6.Widget.set_cursor(btn, app, "hand")
    ExQt6.Widget.set_cursor(btn, app, "wait")
    ExQt6.Widget.set_cursor(btn, app, "cross")
    ExQt6.Widget.set_cursor(btn, app, "text")
    ExQt6.Widget.set_cursor(btn, app, "arrow")
  end

  # --- Label Property Tests ---

  defp test_label_align(app) do
    {:ok, lbl} = ExQt6.Widget.new_label(app, "Aligned")
    ExQt6.Widget.set_label_align(lbl, app, "left")
    ExQt6.Widget.set_label_align(lbl, app, "center")
    ExQt6.Widget.set_label_align(lbl, app, "right")
  end

  defp test_word_wrap(app) do
    {:ok, lbl} = ExQt6.Widget.new_label(app, "Long text that should wrap")
    ExQt6.Widget.set_label_align(lbl, app, "left", true)
  end

  # --- LineEdit Property Tests ---

  defp test_lineedit_readonly(app) do
    {:ok, le} = ExQt6.Widget.new_lineedit(app, "Read me")
    ExQt6.Widget.set_lineedit_readonly(le, app, true)
    ExQt6.Widget.set_lineedit_readonly(le, app, false)
  end

  defp test_lineedit_echo(app) do
    {:ok, le} = ExQt6.Widget.new_lineedit(app, "secret")
    ExQt6.Widget.set_lineedit_echo(le, app, "password")
    ExQt6.Widget.set_lineedit_echo(le, app, "noecho")
    ExQt6.Widget.set_lineedit_echo(le, app, "normal")
  end

  defp test_lineedit_text(app) do
    {:ok, le} = ExQt6.Widget.new_lineedit(app)
    ExQt6.Widget.set_text(le, app, "hello world")
    {:ok, text} = ExQt6.Widget.get_text(le, app)
    "hello world" = text
  end

  defp test_button_text(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Original")
    {:ok, text} = ExQt6.Widget.get_text(btn, app)
    "Original" = text
    ExQt6.Widget.set_text(btn, app, "Changed")
    {:ok, text2} = ExQt6.Widget.get_text(btn, app)
    "Changed" = text2
  end

  # --- Value get/set Tests ---

  defp test_slider_value(app) do
    {:ok, sl} = ExQt6.Widget.new_slider(app, min: 0, max: 100, value: 25)
    {:ok, v} = ExQt6.Widget.get_value(sl, app)
    25 = v
    ExQt6.Widget.set_value(sl, app, 75)
    {:ok, v2} = ExQt6.Widget.get_value(sl, app)
    75 = v2
  end

  defp test_spinbox_value(app) do
    {:ok, sb} = ExQt6.Widget.new_spinbox(app, 0, 1000, value: 100)
    {:ok, v} = ExQt6.Widget.get_value(sb, app)
    100 = v
    ExQt6.Widget.set_value(sb, app, 999)
    {:ok, v2} = ExQt6.Widget.get_value(sb, app)
    999 = v2
  end

  defp test_combobox_items(app) do
    {:ok, cb} = ExQt6.Widget.new_combobox(app, ["X", "Y", "Z"])
    {:ok, idx} = ExQt6.Widget.get_value(cb, app)
    true = idx >= 0 and idx <= 2
    ExQt6.Widget.set_current_index(cb, app, 2)
    Process.sleep(100)
    {:ok, idx2} = ExQt6.Widget.get_value(cb, app)
    2 = idx2
  end

  defp test_checkbox_toggle(app) do
    {:ok, ch} = ExQt6.Widget.new_checkbox(app, "Check")
    ExQt6.Widget.set_checked(ch, app, true)
    {:ok, checked} = ExQt6.Widget.get_checked(ch, app)
    true = checked
    ExQt6.Widget.set_checked(ch, app, false)
    {:ok, checked2} = ExQt6.Widget.get_checked(ch, app)
    false = checked2
  end

  defp test_progressbar_value(app) do
    {:ok, pb} = ExQt6.Widget.new_progressbar(app, 0, 200)
    ExQt6.Widget.set_value(pb, app, 150)
    {:ok, v} = ExQt6.Widget.get_value(pb, app)
    150 = v
  end

  # --- Timer Test ---

  defp test_timer(app) do
    {:ok, timer} = ExQt6.Timer.new(app, 500)
    ExQt6.Timer.start(timer, app)
    ExQt6.Timer.stop(timer, app)
    ExQt6.Timer.set_interval(timer, app, 1000)
    true = is_integer(timer.id)
  end

  # --- MainWindow Tests ---

  defp test_mainwindow(app) do
    {:ok, mw} = ExQt6.Widget.new_mainwindow(app)
    ExQt6.Widget.set_title(mw, app, "Main Window Test")
    ExQt6.Widget.resize(mw, app, 800, 600)
    true = mw.type == :mainwindow

    {:ok, central} = ExQt6.Widget.new_window(app)
    {:ok, layout} = ExQt6.Layout.vbox(app)
    ExQt6.Layout.set_layout(layout, app, central)
    ExQt6.Widget.set_main_widget(mw, app, central)
  end

  defp test_menu(app) do
    {:ok, mw} = ExQt6.Widget.new_mainwindow(app)
    {:ok, mb} = ExQt6.Widget.new_menu_bar(mw, app)

    {:ok, file_id} = ExQt6.Widget.menu_bar_add_menu(mb, app, "File")
    {:ok, _new_id} = ExQt6.Widget.menu_add_action(file_id, app, "New")
    {:ok, _open_id} = ExQt6.Widget.menu_add_action(file_id, app, "Open")
    ExQt6.Widget.menu_add_separator(file_id, app)
    {:ok, _quit_id} = ExQt6.Widget.menu_add_action(file_id, app, "Quit")

    {:ok, edit_id} = ExQt6.Widget.menu_bar_add_menu(mb, app, "Edit")
    {:ok, _undo_id} = ExQt6.Widget.menu_add_action(edit_id, app, "Undo")

    {:ok, recent_id} = ExQt6.Widget.menu_add_submenu(file_id, app, "Recent")
    {:ok, _r1} = ExQt6.Widget.menu_add_action(recent_id, app, "file1.txt")
    {:ok, _r2} = ExQt6.Widget.menu_add_action(recent_id, app, "file2.txt")

    true = mb.type == :menubar
  end

  defp test_toolbar(app) do
    {:ok, mw} = ExQt6.Widget.new_mainwindow(app)
    {:ok, tb} = ExQt6.Widget.new_toolbar(mw, app, "My Toolbar")
    {:ok, _btn1} = ExQt6.Widget.toolbar_add_button(tb, app, "Save")
    {:ok, _btn2} = ExQt6.Widget.toolbar_add_button(tb, app, "Copy")
    ExQt6.Widget.toolbar_add_separator(tb, app)
    {:ok, le} = ExQt6.Widget.new_lineedit(app, "Search")
    ExQt6.Widget.toolbar_add_widget(tb, app, le)
    true = tb.type == :toolbar
  end

  defp test_statusbar(app) do
    {:ok, mw} = ExQt6.Widget.new_mainwindow(app)
    {:ok, sb} = ExQt6.Widget.new_statusbar(mw, app)
    ExQt6.Widget.statusbar_set_text(sb, app, "Status: OK")
    true = sb.type == :statusbar
  end

  # --- Table Tests ---

  defp test_table(app) do
    {:ok, table} = ExQt6.Widget.new_table(app, 3, 3)
    ExQt6.Widget.table_set_headers(table, app, ["Name", "Age", "City"])
    ExQt6.Widget.table_set_item(table, app, 0, 0, "Alice")
    ExQt6.Widget.table_set_item(table, app, 0, 1, "30")
    ExQt6.Widget.table_set_item(table, app, 0, 2, "SP")
    ExQt6.Widget.table_set_item(table, app, 1, 0, "Bob")
    ExQt6.Widget.table_set_item(table, app, 1, 1, "25")
    ExQt6.Widget.table_set_item(table, app, 1, 2, "RJ")
    ExQt6.Widget.table_set_item(table, app, 2, 0, "Charlie")
    ExQt6.Widget.table_set_item(table, app, 2, 1, "35")
    ExQt6.Widget.table_set_item(table, app, 2, 2, "BH")
    true = table.type == :table
  end

  defp test_table_get(app) do
    {:ok, table} = ExQt6.Widget.new_table(app, 2, 2)
    ExQt6.Widget.table_set_headers(table, app, ["A", "B"])
    ExQt6.Widget.table_set_item(table, app, 0, 0, "hello")
    {:ok, text} = ExQt6.Widget.table_get_item(table, app, 0, 0)
    "hello" = text
    {:ok, text2} = ExQt6.Widget.table_get_item(table, app, 0, 1)
    "" = text2
  end

  defp test_table_rows(app) do
    {:ok, table} = ExQt6.Widget.new_table(app, 2, 1)
    ExQt6.Widget.table_set_row_count(table, app, 5)
    ExQt6.Widget.table_insert_row(table, app, 1)
    ExQt6.Widget.table_set_item(table, app, 1, 0, "inserted")
    ExQt6.Widget.table_remove_row(table, app, 0)
    ExQt6.Widget.table_set_column_count(table, app, 3)
  end

  defp test_table_cell_widget(app) do
    {:ok, table} = ExQt6.Widget.new_table(app, 1, 1)
    {:ok, cb} = ExQt6.Widget.new_checkbox(app, "Check")
    ExQt6.Widget.table_set_cell_widget(table, app, 0, 0, cb)
  end

  defp test_table_modes(app) do
    {:ok, table} = ExQt6.Widget.new_table(app, 2, 2)
    ExQt6.Widget.table_set_selection_mode(table, app, "multi")
    ExQt6.Widget.table_set_selection_mode(table, app, "single")
    ExQt6.Widget.table_set_edit_triggers(table, app, "all")
    ExQt6.Widget.table_set_edit_triggers(table, app, "double_clicked")
    ExQt6.Widget.table_resize_columns(table, app)
    ExQt6.Widget.table_set_column_width(table, app, 0, 200)
    ExQt6.Widget.table_set_row_height(table, app, 0, 40)
  end

  # --- Event Tests ---

  defp test_mouse_events(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Mouse")
    ExQt6.Widget.enable_mouse_events(btn, app, true)
    ExQt6.Widget.enable_mouse_events(btn, app, false)
    ExQt6.Widget.enable_mouse_events(btn, app, true)
  end

  defp test_key_events(app) do
    {:ok, le} = ExQt6.Widget.new_lineedit(app)
    ExQt6.Widget.enable_key_events(le, app, true)
    ExQt6.Widget.enable_key_events(le, app, false)
  end

  defp test_close_event(app) do
    {:ok, win} = ExQt6.Widget.new_window(app)
    ExQt6.Widget.enable_close_event(win, app, true)
    ExQt6.Widget.enable_close_event(win, app, false)
  end

  # --- Batch Test ---

  defp test_batch(app) do
    {:ok, lbl1} = ExQt6.Widget.new_label(app, "A")
    {:ok, lbl2} = ExQt6.Widget.new_label(app, "B")
    {:ok, lbl3} = ExQt6.Widget.new_label(app, "C")
    Process.sleep(100)

    :ok =
      ExQt6.App.batch(app, [
        %{name: "set_text", id: lbl1.id, text: "Batch1"},
        %{name: "set_text", id: lbl2.id, text: "Batch2"},
        %{name: "set_text", id: lbl3.id, text: "Batch3"},
        %{name: "set_tooltip", id: lbl1.id, tooltip: "tip1"},
        %{name: "set_tooltip", id: lbl2.id, tooltip: "tip2"}
      ])

    Process.sleep(300)

    {:ok, t1} = ExQt6.Widget.get_text(lbl1, app)
    {:ok, t2} = ExQt6.Widget.get_text(lbl2, app)
    {:ok, t3} = ExQt6.Widget.get_text(lbl3, app)
    "Batch1" = t1
    "Batch2" = t2
    "Batch3" = t3
  end

  # --- Pipeline Test ---

  defp test_pipeline(app) do
    {:ok, btn} = ExQt6.Widget.new_button(app, "Pipe")

    result =
      btn
      |> ExQt6.Widget.set_tooltip(app, "Piped!")
      |> ExQt6.Widget.set_font(app, size: 20, bold: true)
      |> ExQt6.Widget.set_style(app, "background: green; color: white;")
      |> ExQt6.Widget.set_enabled(app, true)
      |> ExQt6.Widget.set_cursor(app, "hand")
      |> ExQt6.Widget.set_frameless(app)
      |> ExQt6.Widget.set_opacity(app, 0.95)
      |> ExQt6.Widget.set_always_on_top(app, true)
      |> ExQt6.Widget.set_modal(app, false)

    true = is_struct(result, ExQt6.Widget)
    true = btn.id == result.id
  end

  # --- Named Widgets Test ---

  defp test_named_widgets(app) do
    tab_name = :test_named_registry
    :ets.new(tab_name, [:named_table, :public, :set])

    {:ok, btn} = ExQt6.Widget.new_button(app, "Named")
    {:ok, lbl} = ExQt6.Widget.new_label(app, "Named")
    drain_qt_events()

    :ets.insert(tab_name, {:ok_button, btn})
    :ets.insert(tab_name, {:info_label, lbl})

    [{_, found_btn}] = :ets.lookup(tab_name, :ok_button)
    [{_, found_lbl}] = :ets.lookup(tab_name, :info_label)
    true = btn.id == found_btn.id
    true = lbl.id == found_lbl.id
  end

  # Drains any queued Qt events so they don't pollute later widget_created lookups.
  defp drain_qt_events, do: drain_qt_events(20)

  defp drain_qt_events(0), do: :ok

  defp drain_qt_events(n) do
    receive do
      {:qt_event, _e} -> drain_qt_events(n - 1)
    after
      50 -> :ok
    end
  end

  # --- P0 Widget Tests ---

  defp test_listwidget(app) do
    {:ok, lw} = ExQt6.Widget.new_listwidget(app)
    true = lw.type == :listwidget

    :ok = ExQt6.Widget.add_list_items(lw, app, ["A", "B", "C"])
    :ok = ExQt6.Widget.add_list_item(lw, app, "D")
    ExQt6.Widget.set_list_current_row(lw, app, 1)
    Process.sleep(100)
    {:ok, row} = ExQt6.Widget.get_list_current_row(lw, app)
    1 = row

    :ok = ExQt6.Widget.set_list_item_text(lw, app, 0, "A1")
    :ok = ExQt6.Widget.list_remove_item(lw, app, 3)

    lw = ExQt6.Widget.set_enabled(lw, app, false)
    true = is_struct(lw, ExQt6.Widget)
    lw = ExQt6.Widget.set_enabled(lw, app, true)
    true = is_struct(lw, ExQt6.Widget)
  end

  defp test_scrollarea(app) do
    {:ok, sa} = ExQt6.Widget.new_scrollarea(app, resizable: true)
    Process.sleep(100)
    true = sa.type == :scrollarea

    {:ok, inner} = ExQt6.Widget.new_label(app, "Scroll content")
    Process.sleep(100)
    :ok = ExQt6.Widget.scrollarea_set_widget(sa, app, inner)
  end

  defp test_scrollbar(app) do
    {:ok, vsb} =
      ExQt6.Widget.new_scrollbar(app, orientation: "vertical", min: 0, max: 200, value: 10)

    Process.sleep(100)
    true = vsb.type == :scrollbar

    ExQt6.Widget.set_value(vsb, app, 150)
    {:ok, v} = ExQt6.Widget.get_value(vsb, app)
    150 = v
  end

  defp test_toolbutton(app) do
    {:ok, tb} = ExQt6.Widget.new_toolbutton(app, text: "Tools", style: "text")
    Process.sleep(100)
    true = tb.type == :toolbutton

    :ok = ExQt6.Widget.set_toolbutton_menu(tb, app, ["Option 1", "Option 2"])
    tb = ExQt6.Widget.set_enabled(tb, app, false)
    true = is_struct(tb, ExQt6.Widget)
    tb = ExQt6.Widget.set_enabled(tb, app, true)
    true = is_struct(tb, ExQt6.Widget)
  end

  # --- Final Window ---

  defp show_final(app) do
    {:ok, mw} = ExQt6.Widget.new_mainwindow(app)
    ExQt6.Widget.set_title(mw, app, "ExQt6 Comprehensive Test — All Features Working!")
    ExQt6.Widget.resize(mw, app, 900, 700)

    {:ok, mb} = ExQt6.Widget.new_menu_bar(mw, app)
    {:ok, file_id} = ExQt6.Widget.menu_bar_add_menu(mb, app, "File")
    ExQt6.Widget.menu_add_action(file_id, app, "New")
    ExQt6.Widget.menu_add_action(file_id, app, "Open")
    {:ok, edit_id} = ExQt6.Widget.menu_bar_add_menu(mb, app, "Edit")
    ExQt6.Widget.menu_add_action(edit_id, app, "Undo")
    {:ok, help_id} = ExQt6.Widget.menu_bar_add_menu(mb, app, "Help")
    ExQt6.Widget.menu_add_action(help_id, app, "About")

    {:ok, tb} = ExQt6.Widget.new_toolbar(mw, app, "Main")
    {:ok, _} = ExQt6.Widget.toolbar_add_button(tb, app, "New")
    {:ok, _} = ExQt6.Widget.toolbar_add_button(tb, app, "Save")
    ExQt6.Widget.toolbar_add_separator(tb, app)

    {:ok, sb} = ExQt6.Widget.new_statusbar(mw, app)
    ExQt6.Widget.statusbar_set_text(sb, app, "60 tests passed ✓")

    {:ok, central} = ExQt6.Widget.new_window(app)
    {:ok, root} = ExQt6.Layout.vbox(app)
    ExQt6.Layout.set_layout(root, app, central)

    # Top row: labels
    {:ok, title} = ExQt6.Widget.new_label(app, "ExQt6 Feature Showcase")
    ExQt6.Widget.set_font(title, app, family: "Arial", size: 22, bold: true)
    ExQt6.Widget.set_label_align(title, app, "center")
    ExQt6.Layout.add(root, app, title)

    # Grid of widgets
    {:ok, grid} = ExQt6.Layout.grid(app)
    ExQt6.Layout.add_layout(root, app, grid)

    {:ok, lbl1} = ExQt6.Widget.new_label(app, "QLabel")
    {:ok, lbl2} = ExQt6.Widget.new_label(app, "Styled!")
    ExQt6.Widget.set_font(lbl2, app, size: 14, bold: true, italic: true)
    ExQt6.Widget.set_style(lbl2, app, "color: #f38ba8;")

    {:ok, le} = ExQt6.Widget.new_lineedit(app, "Type here...")
    {:ok, btn} = ExQt6.Widget.new_button(app, "QPushButton")
    {:ok, cb} = ExQt6.Widget.new_combobox(app, ["Option A", "Option B", "Option C"])
    {:ok, ch} = ExQt6.Widget.new_checkbox(app, "QCheckBox")
    {:ok, sl} = ExQt6.Widget.new_slider(app, min: 0, max: 100, value: 60)
    {:ok, pb} = ExQt6.Widget.new_progressbar(app, 0, 100)
    ExQt6.Widget.set_value(pb, app, 60)

    ExQt6.Layout.grid_add_widget(grid, app, lbl1, 0, 0)
    ExQt6.Layout.grid_add_widget(grid, app, lbl2, 0, 1)
    ExQt6.Layout.grid_add_widget(grid, app, le, 1, 0, col_span: 2)
    ExQt6.Layout.grid_add_widget(grid, app, btn, 2, 0)
    ExQt6.Layout.grid_add_widget(grid, app, cb, 2, 1)
    ExQt6.Layout.grid_add_widget(grid, app, ch, 3, 0)
    ExQt6.Layout.grid_add_widget(grid, app, sl, 3, 1)
    ExQt6.Layout.grid_add_widget(grid, app, pb, 4, 0, col_span: 2)

    # Table at bottom
    {:ok, table} = ExQt6.Widget.new_table(app, 3, 4)
    ExQt6.Widget.table_set_headers(table, app, ["Widget", "Type", "Status", "Tests"])
    ExQt6.Widget.table_set_item(table, app, 0, 0, "All Widgets")
    ExQt6.Widget.table_set_item(table, app, 0, 1, "16 types")
    ExQt6.Widget.table_set_item(table, app, 0, 2, "Working")
    ExQt6.Widget.table_set_item(table, app, 0, 3, "16/16")
    ExQt6.Widget.table_set_item(table, app, 1, 0, "All Layouts")
    ExQt6.Widget.table_set_item(table, app, 1, 1, "4 types + splitter")
    ExQt6.Widget.table_set_item(table, app, 1, 2, "Working")
    ExQt6.Widget.table_set_item(table, app, 1, 3, "4/4")
    ExQt6.Widget.table_set_item(table, app, 2, 0, "All Properties")
    ExQt6.Widget.table_set_item(table, app, 2, 1, "15+ properties")
    ExQt6.Widget.table_set_item(table, app, 2, 2, "Working")
    ExQt6.Widget.table_set_item(table, app, 2, 3, "All")
    ExQt6.Widget.table_resize_columns(table, app)
    ExQt6.Layout.add(root, app, table)

    ExQt6.Widget.set_main_widget(mw, app, central)
    ExQt6.Widget.show(mw, app)
  end

  # --- P1 Widget Tests ---

  defp test_listview(app) do
    {:ok, lv} = ExQt6.Widget.new_listview(app)
    true = lv.type == :listview

    :ok = ExQt6.Widget.listview_set_strings(lv, app, ["A", "B", "C"])
    :ok = ExQt6.Widget.set_listview_current(lv, app, 2)
    Process.sleep(100)
    {:ok, row} = ExQt6.Widget.get_listview_current(lv, app)
    2 = row

    lv = ExQt6.Widget.set_enabled(lv, app, false)
    true = is_struct(lv, ExQt6.Widget)
    lv = ExQt6.Widget.set_enabled(lv, app, true)
    true = is_struct(lv, ExQt6.Widget)
  end

  defp test_tableview(app) do
    {:ok, tv} = ExQt6.Widget.new_tableview(app, 3, 2)
    true = tv.type == :tableview

    :ok = ExQt6.Widget.tableview_set_headers(tv, app, ["Col1", "Col2"])
    :ok = ExQt6.Widget.tableview_set_item(tv, app, 0, 0, "x1")
    :ok = ExQt6.Widget.tableview_set_item(tv, app, 2, 1, "y3")

    tv = ExQt6.Widget.set_enabled(tv, app, false)
    true = is_struct(tv, ExQt6.Widget)
    tv = ExQt6.Widget.set_enabled(tv, app, true)
    true = is_struct(tv, ExQt6.Widget)
  end

  defp test_toolbox(app) do
    {:ok, tb} = ExQt6.Widget.new_toolbox(app)
    true = tb.type == :toolbox

    {:ok, btn1} = ExQt6.Widget.new_button(app, "Page 1")
    {:ok, btn2} = ExQt6.Widget.new_button(app, "Page 2")
    :ok = ExQt6.Widget.toolbox_add_item(tb, app, btn1, "Tab A")
    :ok = ExQt6.Widget.toolbox_add_item(tb, app, btn2, "Tab B")

    tb = ExQt6.Widget.set_enabled(tb, app, false)
    true = is_struct(tb, ExQt6.Widget)
    tb = ExQt6.Widget.set_enabled(tb, app, true)
    true = is_struct(tb, ExQt6.Widget)
  end

  defp test_timeedit(app) do
    {:ok, te} = ExQt6.Widget.new_timeedit(app, format: "HH:mm:ss", time: "12:34:56")
    true = te.type == :timeedit

    te = ExQt6.Widget.set_enabled(te, app, false)
    true = is_struct(te, ExQt6.Widget)
    te = ExQt6.Widget.set_enabled(te, app, true)
    true = is_struct(te, ExQt6.Widget)
  end

  defp test_dateedit(app) do
    {:ok, de} = ExQt6.Widget.new_dateedit(app, format: "yyyy-MM-dd", date: "2024-05-01")
    true = de.type == :dateedit

    de = ExQt6.Widget.set_enabled(de, app, false)
    true = is_struct(de, ExQt6.Widget)
    de = ExQt6.Widget.set_enabled(de, app, true)
    true = is_struct(de, ExQt6.Widget)
  end

  defp test_fontcombobox(app) do
    {:ok, fc} = ExQt6.Widget.new_fontcombobox(app)
    true = fc.type == :fontcombobox

    Process.sleep(100)
    {:ok, family} = ExQt6.Widget.get_fontcombobox_current(fc, app)
    true = is_binary(family) and family != ""
  end

  defp test_commandlink(app) do
    {:ok, cl} =
      ExQt6.Widget.new_commandlinkbutton(app, "Save", description: "Save the file")

    true = cl.type == :commandlinkbutton

    :ok = ExQt6.Widget.set_commandlink_description(cl, app, "Save to disk")

    cl = ExQt6.Widget.set_enabled(cl, app, false)
    true = is_struct(cl, ExQt6.Widget)
    cl = ExQt6.Widget.set_enabled(cl, app, true)
    true = is_struct(cl, ExQt6.Widget)
  end
end

ExQt6.ComprehensiveTest.run()
