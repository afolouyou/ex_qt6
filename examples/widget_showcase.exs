#!/usr/bin/env elixir

Application.ensure_all_started(:ex_qt6)
{:ok, app} = ExQt6.App.start_link(target: self())
Process.sleep(500)

# === Main Window ===
{:ok, win} = ExQt6.Widget.new_window(app)
ExQt6.Widget.set_title(win, app, "ExQt6 Widget Showcase")
ExQt6.Widget.resize(win, app, 800, 600)
ExQt6.Widget.set_style(win, app, "font-family: sans-serif; font-size: 13px;")

{:ok, main_vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(main_vbox, app, win)

{:ok, tabs} = ExQt6.Widget.new_tabwidget(app)
ExQt6.Layout.add(main_vbox, app, tabs)

# === Tab 1: SpinBox & ProgressBar sync ===
{:ok, tab1} = ExQt6.Widget.new_window(app)
{:ok, tab1_vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(tab1_vbox, app, tab1)
ExQt6.Widget.add_tab(tabs, app, tab1, "Spin & Progress")

{:ok, spin_label} = ExQt6.Widget.new_label(app, "Drag the SpinBox — progress bar follows:")
ExQt6.Layout.add(tab1_vbox, app, spin_label)

{:ok, spinbox} = ExQt6.Widget.new_spinbox(app, 0, 100, value: 50, suffix: "%", single_step: 5)
ExQt6.Layout.add(tab1_vbox, app, spinbox)

{:ok, progressbar} = ExQt6.Widget.new_progressbar(app, 0, 100, value: 50, format: "%v%")
ExQt6.Layout.add(tab1_vbox, app, progressbar)

# === Tab 2: RadioButtons & ButtonGroup ===
{:ok, tab2} = ExQt6.Widget.new_window(app)
{:ok, tab2_vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(tab2_vbox, app, tab2)
ExQt6.Widget.add_tab(tabs, app, tab2, "Radio & Group")

{:ok, rb_title} = ExQt6.Widget.new_label(app, "Choose your weapon:")
ExQt6.Layout.add(tab2_vbox, app, rb_title)

{:ok, rb1} = ExQt6.Widget.new_radiobutton(app, "Sword")
{:ok, rb2} = ExQt6.Widget.new_radiobutton(app, "Staff")
{:ok, rb3} = ExQt6.Widget.new_radiobutton(app, "Bow")
{:ok, rb4} = ExQt6.Widget.new_radiobutton(app, "Dagger")
ExQt6.Layout.add(tab2_vbox, app, rb1)
ExQt6.Layout.add(tab2_vbox, app, rb2)
ExQt6.Layout.add(tab2_vbox, app, rb3)
ExQt6.Layout.add(tab2_vbox, app, rb4)

{:ok, rb_group} = ExQt6.Widget.new_buttongroup(app)
ExQt6.Widget.add_to_buttongroup(rb_group, app, rb1)
ExQt6.Widget.add_to_buttongroup(rb_group, app, rb2)
ExQt6.Widget.add_to_buttongroup(rb_group, app, rb3)
ExQt6.Widget.add_to_buttongroup(rb_group, app, rb4)
ExQt6.Widget.set_checked(rb1, app, true)

{:ok, selection_label} = ExQt6.Widget.new_label(app, "Selected: Sword")
ExQt6.Widget.set_label_align(selection_label, app, "center")
ExQt6.Widget.set_style(selection_label, app, "font-weight: bold; color: #2196F3; font-size: 16px; padding: 8px;")
ExQt6.Layout.add(tab2_vbox, app, selection_label)

# === Tab 3: TreeWidget ===
{:ok, tab3} = ExQt6.Widget.new_window(app)
{:ok, tab3_vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(tab3_vbox, app, tab3)
ExQt6.Widget.add_tab(tabs, app, tab3, "Tree View")

{:ok, tree} = ExQt6.Widget.new_tree(app, headers: ["Name", "Type", "Size"])
ExQt6.Layout.add(tab3_vbox, app, tree)
ExQt6.Widget.add_tree_item(tree, app, text: "lib/")
ExQt6.Widget.add_tree_item(tree, app, text: "native/")
ExQt6.Widget.add_tree_item(tree, app, text: "mix.exs")
ExQt6.Widget.add_tree_item(tree, app, text: "shell.nix")
ExQt6.Widget.set_tree_item_text(tree, app, 0, 1, "folder")
ExQt6.Widget.set_tree_item_text(tree, app, 1, 1, "folder")
ExQt6.Widget.set_tree_item_text(tree, app, 2, 1, "file")
ExQt6.Widget.set_tree_item_text(tree, app, 3, 1, "file")

# === Tab 4: Form Layout ===
{:ok, tab4} = ExQt6.Widget.new_window(app)
{:ok, tab4_vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(tab4_vbox, app, tab4)
ExQt6.Widget.add_tab(tabs, app, tab4, "Form Layout")

{:ok, form} = ExQt6.Layout.form(app)
{:ok, name_le} = ExQt6.Widget.new_lineedit(app, "Enter your name...")
{:ok, age_sb} = ExQt6.Widget.new_spinbox(app, 1, 120, value: 25, suffix: " years")
{:ok, email_le} = ExQt6.Widget.new_lineedit(app, "user@example.com")
{:ok, pass_le} = ExQt6.Widget.new_lineedit(app, "Secret...")
ExQt6.Widget.set_lineedit_echo(pass_le, app, "password")
ExQt6.Layout.form_add_row(form, app, "Name:", name_le)
ExQt6.Layout.form_add_row(form, app, "Age:", age_sb)
ExQt6.Layout.form_add_row(form, app, "Email:", email_le)
ExQt6.Layout.form_add_row(form, app, "Password:", pass_le)
ExQt6.Layout.add(tab4_vbox, app, ExQt6.Widget.new_label(app, "Form Layout with labels:") |> elem(1))
ExQt6.Layout.add_layout(tab4_vbox, app, form)

{:ok, ro_le} = ExQt6.Widget.new_lineedit(app, "This field is read-only")
ExQt6.Widget.set_lineedit_readonly(ro_le, app, true)
ExQt6.Layout.add(tab4_vbox, app, ro_le)

# === Tab 5: Grid Layout + Splitter ===
{:ok, tab5} = ExQt6.Widget.new_window(app)
{:ok, tab5_vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(tab5_vbox, app, tab5)
ExQt6.Widget.add_tab(tabs, app, tab5, "Grid & Splitter")

{:ok, grid} = ExQt6.Layout.grid(app, margin: 10, spacing: 8)
{:ok, g1} = ExQt6.Widget.new_button(app, "(0,0)")
{:ok, g2} = ExQt6.Widget.new_button(app, "(0,1)")
{:ok, g3} = ExQt6.Widget.new_button(app, "(1,0) span 2")
ExQt6.Widget.set_style(g1, app, "background: #E3F2FD;")
ExQt6.Widget.set_style(g2, app, "background: #E8F5E9;")
ExQt6.Widget.set_style(g3, app, "background: #FFF3E0;")
ExQt6.Layout.grid_add_widget(grid, app, g1, 0, 0)
ExQt6.Layout.grid_add_widget(grid, app, g2, 0, 1)
ExQt6.Layout.grid_add_widget(grid, app, g3, 1, 0, col_span: 2)
ExQt6.Layout.add(tab5_vbox, app, ExQt6.Widget.new_label(app, "Grid Layout (col_span):") |> elem(1))
ExQt6.Layout.add_layout(tab5_vbox, app, grid)

{:ok, sp} = ExQt6.Widget.new_splitter(app, "horizontal")
{:ok, sp_left} = ExQt6.Widget.new_label(app, "Left pane")
ExQt6.Widget.set_style(sp_left, app, "background: #FFCDD2; padding: 20px; font-size: 14px;")
{:ok, sp_right} = ExQt6.Widget.new_button(app, "Right pane")
ExQt6.Widget.set_style(sp_right, app, "background: #C8E6C9; font-size: 14px;")
ExQt6.Widget.splitter_add(sp, app, sp_left)
ExQt6.Widget.splitter_add(sp, app, sp_right)
ExQt6.Widget.splitter_set_sizes(sp, app, [300, 300])
ExQt6.Layout.add(tab5_vbox, app, ExQt6.Widget.new_label(app, "Splitter (drag the handle):") |> elem(1))
ExQt6.Layout.add(tab5_vbox, app, sp)

# === Tab 6: Dialogs & Properties ===
{:ok, tab6} = ExQt6.Widget.new_window(app)
{:ok, tab6_vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(tab6_vbox, app, tab6)
ExQt6.Widget.add_tab(tabs, app, tab6, "Dialogs")

{:ok, info_btn} = ExQt6.Widget.new_button(app, "Show Info Dialog")
ExQt6.Widget.set_tooltip(info_btn, app, "Opens a QMessageBox with info icon")
ExQt6.Layout.add(tab6_vbox, app, info_btn)

{:ok, warn_btn} = ExQt6.Widget.new_button(app, "Show Warning Dialog")
ExQt6.Widget.set_style(warn_btn, app, "background: #FF9800; color: white; font-weight: bold;")
ExQt6.Layout.add(tab6_vbox, app, warn_btn)

{:ok, q_btn} = ExQt6.Widget.new_button(app, "Show Question Dialog")
ExQt6.Widget.set_style(q_btn, app, "background: #2196F3; color: white; font-weight: bold;")
ExQt6.Layout.add(tab6_vbox, app, q_btn)

{:ok, file_btn} = ExQt6.Widget.new_button(app, "Open File Dialog")
ExQt6.Layout.add(tab6_vbox, app, file_btn)

{:ok, dialog_result} = ExQt6.Widget.new_label(app, "Dialog result will appear here")
ExQt6.Widget.set_label_align(dialog_result, app, "center")
ExQt6.Widget.set_style(dialog_result, app, "font-style: italic; color: #666; padding: 10px;")
ExQt6.Layout.add(tab6_vbox, app, dialog_result)

# === Show ===
ExQt6.Widget.show(win, app)

IO.puts("\n=== ExQt6 Widget Showcase ===")
IO.puts("  Tab 1: SpinBox <-> ProgressBar sync")
IO.puts("  Tab 2: RadioButtons -> label update")
IO.puts("  Tab 3: TreeWidget")
IO.puts("  Tab 4: Form Layout + readonly + password")
IO.puts("  Tab 5: Grid Layout + Splitter")
IO.puts("  Tab 6: Dialogs")
IO.puts("Ctrl+C to quit.\n")

weapons = %{0 => "Sword", 1 => "Staff", 2 => "Bow", 3 => "Dagger"}

defmodule Showcase do
  def loop(app, state) do
    receive do
      {:qt_event, %{"event" => "value_changed", "id" => id, "value" => val}} when id == state.spinbox_id ->
        ExQt6.Widget.set_value(%ExQt6.Widget{id: state.progressbar_id, type: :progressbar}, app, val)
        loop(app, state)

      {:qt_event, %{"event" => "button_clicked", "button_id" => bid}} ->
        name = Map.get(state.weapons, bid, "???")
        ExQt6.Widget.set_text(%ExQt6.Widget{id: state.label_id, type: :label}, app, "Selected: #{name}")
        loop(app, state)

      {:qt_event, %{"event" => "clicked", "id" => id}} ->
        handle_click(app, id, state)
        loop(app, state)

      {:qt_event, %{"event" => "current_changed", "value" => _val}} ->
        loop(app, state)

      {:qt_event, _event} ->
        loop(app, state)

      {:app_ready, _} -> loop(app, state)
      _ -> loop(app, state)
    end
  end

  defp handle_click(app, id, state) do
    cond do
      id == state.info_btn_id ->
        ExQt6.Widget.msgbox(app, type: "info", title: "Info", text: "This is an informational message.")

      id == state.warn_btn_id ->
        ExQt6.Widget.msgbox(app, type: "warning", title: "Warning", text: "Something might be wrong!")

      id == state.q_btn_id ->
        case ExQt6.Widget.msgbox(app, type: "question", title: "Question", text: "Do you like Elixir?",
                                buttons: ["yes", "no"]) do
          {:ok, result} ->
            answer = if result == 0x00000400, do: "Yes!", else: "No!"
            ExQt6.Widget.set_text(%ExQt6.Widget{id: state.result_label_id, type: :label}, app, "Answer: #{answer}")
          _ -> :ok
        end

      id == state.file_btn_id ->
        case ExQt6.Widget.file_dialog(app, title: "Open a file", filter: "Elixir (*.ex *.exs);;All (*)") do
          {:ok, path} when path != "" ->
            ExQt6.Widget.set_text(%ExQt6.Widget{id: state.result_label_id, type: :label}, app, "Selected: #{path}")
          _ ->
            ExQt6.Widget.set_text(%ExQt6.Widget{id: state.result_label_id, type: :label}, app, "Cancelled")
        end

      true -> :ok
    end
  end
end

state = %{
  spinbox_id: spinbox.id,
  progressbar_id: progressbar.id,
  label_id: selection_label.id,
  info_btn_id: info_btn.id,
  warn_btn_id: warn_btn.id,
  q_btn_id: q_btn.id,
  file_btn_id: file_btn.id,
  result_label_id: dialog_result.id,
  weapons: weapons
}

Showcase.loop(app, state)
