Application.ensure_all_started(:ex_qt6)

defmodule Notepad do
  @moduledoc "Full notepad using QMainWindow, menus, toolbar, statusbar, QPlainTextEdit, file dialogs."

  def run do
    {:ok, app} = ExQt6.App.start_link(target: self())
    Process.sleep(500)

    {:ok, mw} = ExQt6.Widget.new_mainwindow(app)
    ExQt6.Widget.set_title(mw, app, "Notepad — ExQt6")
    ExQt6.Widget.resize(mw, app, 900, 650)

    # Central widget + editor
    {:ok, central} = ExQt6.Widget.new_window(app)
    {:ok, editor_layout} = ExQt6.Layout.vbox(app)
    ExQt6.Layout.set_layout(editor_layout, app, central)
    {:ok, editor} = ExQt6.Widget.new_textedit(app)
    ExQt6.Widget.set_font(editor, app, family: "Monospace", size: 12)
    ExQt6.Layout.add(editor_layout, app, editor)
    ExQt6.Widget.set_main_widget(mw, app, central)

    # Menu bar
    {:ok, menubar} = ExQt6.Widget.new_menu_bar(mw, app)

    {:ok, file_menu_id} = ExQt6.Widget.menu_bar_add_menu(menubar, app, "File")
    {:ok, new_id} = ExQt6.Widget.menu_add_action(file_menu_id, app, "New          Ctrl+N")
    {:ok, open_id} = ExQt6.Widget.menu_add_action(file_menu_id, app, "Open...      Ctrl+O")
    {:ok, save_id} = ExQt6.Widget.menu_add_action(file_menu_id, app, "Save         Ctrl+S")
    {:ok, saveas_id} = ExQt6.Widget.menu_add_action(file_menu_id, app, "Save As...")
    ExQt6.Widget.menu_add_separator(file_menu_id, app)
    {:ok, exit_id} = ExQt6.Widget.menu_add_action(file_menu_id, app, "Exit")

    {:ok, edit_menu_id} = ExQt6.Widget.menu_bar_add_menu(menubar, app, "Edit")
    {:ok, undo_id} = ExQt6.Widget.menu_add_action(edit_menu_id, app, "Undo         Ctrl+Z")
    {:ok, redo_id} = ExQt6.Widget.menu_add_action(edit_menu_id, app, "Redo         Ctrl+Y")
    ExQt6.Widget.menu_add_separator(edit_menu_id, app)
    {:ok, cut_id} = ExQt6.Widget.menu_add_action(edit_menu_id, app, "Cut          Ctrl+X")
    {:ok, copy_id} = ExQt6.Widget.menu_add_action(edit_menu_id, app, "Copy         Ctrl+C")
    {:ok, paste_id} = ExQt6.Widget.menu_add_action(edit_menu_id, app, "Paste        Ctrl+V")
    {:ok, selectall_id} = ExQt6.Widget.menu_add_action(edit_menu_id, app, "Select All   Ctrl+A")

    {:ok, help_menu_id} = ExQt6.Widget.menu_bar_add_menu(menubar, app, "Help")
    {:ok, about_id} = ExQt6.Widget.menu_add_action(help_menu_id, app, "About")

    # Toolbar
    {:ok, toolbar} = ExQt6.Widget.new_toolbar(mw, app, "Toolbar")
    {:ok, tb_new} = ExQt6.Widget.toolbar_add_button(toolbar, app, "New")
    {:ok, tb_open} = ExQt6.Widget.toolbar_add_button(toolbar, app, "Open")
    {:ok, tb_save} = ExQt6.Widget.toolbar_add_button(toolbar, app, "Save")
    ExQt6.Widget.toolbar_add_separator(toolbar, app)
    {:ok, tb_undo} = ExQt6.Widget.toolbar_add_button(toolbar, app, "Undo")
    {:ok, tb_redo} = ExQt6.Widget.toolbar_add_button(toolbar, app, "Redo")

    # Statusbar
    {:ok, statusbar} = ExQt6.Widget.new_statusbar(mw, app)
    ExQt6.Widget.statusbar_set_text(statusbar, app, "Ready — New document")

    # Close event
    ExQt6.Widget.enable_close_event(mw, app, true)

    ExQt6.Widget.show(mw, app)

    # State: track which action buttons map to which action labels
    action_map = %{
      new_id => "new", tb_new => "new",
      open_id => "open", tb_open => "open",
      save_id => "save", tb_save => "save",
      saveas_id => "saveas",
      exit_id => "exit",
      undo_id => "undo", tb_undo => "undo",
      redo_id => "redo", tb_redo => "redo",
      cut_id => "cut", copy_id => "copy",
      paste_id => "paste", selectall_id => "selectall",
      about_id => "about"
    }

    state = %{editor: editor, menubar: menubar, statusbar: statusbar,
              file: nil, dirty: false, action_map: action_map}
    loop(app, state)
  end

  defp loop(app, state) do
    receive do
      {:qt_event, %{"event" => "clicked", "id" => id}} ->
        action = Map.get(state.action_map, id)
        state = if action, do: handle_action(app, state, action), else: state
        loop(app, state)

      {:qt_event, %{"event" => "action_triggered", "id" => id}} ->
        action = Map.get(state.action_map, id)
        state = if action, do: handle_action(app, state, action), else: state
        loop(app, state)

      {:qt_event, %{"event" => "text_changed", "id" => editor_id}} ->
        if editor_id == state.editor.id do
          ExQt6.Widget.statusbar_set_text(state.statusbar, app, "Modified — #{state.file || "Untitled"}")
          loop(app, %{state | dirty: true})
        else
          loop(app, state)
        end

      {:qt_event, %{"event" => "close"}} ->
        ExQt6.Widget.statusbar_set_text(state.statusbar, app, "Closing...")
        if state.dirty do
          ExQt6.Widget.msgbox(app, "warning", "Unsaved Changes", "Document has unsaved changes. File not saved.")
        end
        System.halt(0)

      {:qt_event, %{"event" => "file_dialog_result", "id" => _fid, "files" => files}} ->
        if length(files) > 0 do
          path = List.first(files)
          content = case File.read(path) do
            {:ok, c} -> c
            _ -> ""
          end
          ExQt6.Widget.set_plaintext(state.editor, app, content)
          ExQt6.Widget.set_title(Map.get(state, :mw, nil) || state.editor, app, "Notepad — #{Path.basename(path)}")
          ExQt6.Widget.statusbar_set_text(state.statusbar, app, "Opened: #{path}")
          loop(app, %{state | file: path, dirty: false})
        else
          loop(app, state)
        end

      {:qt_event, _} ->
        loop(app, state)
    end
  end

  defp handle_action(app, state, action) do
    case action do
      "new" ->
        ExQt6.Widget.set_plaintext(state.editor, app, "")
        ExQt6.Widget.statusbar_set_text(state.statusbar, app, "New document")
        %{state | file: nil, dirty: false}

      "open" ->
        {:ok, _fid} = ExQt6.Widget.file_dialog(app, "open", "Open File", "", "Text Files (*.txt);;All Files (*)")
        state

      "save" ->
        if state.file do
          content = ExQt6.Widget.get_plaintext(state.editor, app)
          File.write(state.file, content)
          ExQt6.Widget.statusbar_set_text(state.statusbar, app, "Saved: #{state.file}")
          %{state | dirty: false}
        else
          handle_action(app, state, "saveas")
        end

      "saveas" ->
        {:ok, _fid} = ExQt6.Widget.file_dialog(app, "save", "Save As", "untitled.txt", "Text Files (*.txt);;All Files (*)")
        state

      "exit" ->
        System.halt(0)

      "undo" ->
        ExQt6.Widget.plaintext_undo(state.editor, app)
        state

      "redo" ->
        ExQt6.Widget.plaintext_redo(state.editor, app)
        state

      "cut" ->
        ExQt6.Widget.plaintext_cut(state.editor, app)
        state

      "copy" ->
        ExQt6.Widget.plaintext_copy(state.editor, app)
        state

      "paste" ->
        ExQt6.Widget.plaintext_paste(state.editor, app)
        state

      "selectall" ->
        ExQt6.Widget.plaintext_selectall(state.editor, app)
        state

      "about" ->
        ExQt6.Widget.msgbox(app, "info", "About Notepad",
          "Notepad — ExQt6\n\nA simple notepad built with Elixir + Qt6.\n\nFeatures: menus, toolbar, file open/save, undo/redo, clipboard.")
        state

      _ -> state
    end
  end
end

Notepad.run()
