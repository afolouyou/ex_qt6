defmodule TestDrive do
  def run do
    IO.puts("Iniciando ExQt6 Test Drive...")

    {:ok, app} = ExQt6.App.start_link(target: self())

    receive do
      {:app_ready, _daemon} -> IO.puts("Daemon pronto!")
    after
      5000 -> raise "Timeout esperando daemon"
    end

    {:ok, win} = ExQt6.Widget.new_window(app)
    ExQt6.Widget.set_title(win, app, "ExQt6 Test Drive")
    ExQt6.Widget.resize(win, app, 800, 600)

    {:ok, main_layout} = ExQt6.Layout.vbox(app)
    ExQt6.Layout.set_layout(main_layout, app, win)

    {:ok, header} = ExQt6.Widget.new_label(app, "ExQt6 Feature Test")
    ExQt6.Widget.set_style(header, app, "font-size: 18px; font-weight: bold; padding: 10px;")
    ExQt6.Layout.add(main_layout, app, header)

    {:ok, group} = ExQt6.Widget.new_groupbox(app, "Controles")
    ExQt6.Layout.add(main_layout, app, group)

    {:ok, group_layout} = ExQt6.Layout.form(app)
    ExQt6.Layout.set_layout(group_layout, app, group)

    {:ok, lineedit} = ExQt6.Widget.new_lineedit(app, "")
    ExQt6.Widget.set_tooltip(lineedit, app, "Digite para ver text_changed")
    ExQt6.Layout.form_add_row(group_layout, app, "Digite algo:", lineedit)

    {:ok, combo_label} = ExQt6.Widget.new_label(app, "Linguagem:")
    {:ok, combo} = ExQt6.Widget.new_combobox(app, ["Elixir", "Rust", "C++", "Nix"])
    ExQt6.Layout.form_add_row_widget(group_layout, app, combo_label, combo)

    {:ok, checkbox} = ExQt6.Widget.new_checkbox(app, "Modo Escuro")
    ExQt6.Layout.form_add_row(group_layout, app, checkbox)

    {:ok, slider} = ExQt6.Widget.new_slider(app, min: 0, max: 100, value: 50)
    {:ok, progress} = ExQt6.Widget.new_progressbar(app, 0, 100, value: 50)

    {:ok, slider_hbox} = ExQt6.Layout.hbox(app)
    ExQt6.Layout.add(slider_hbox, app, slider)
    ExQt6.Layout.add(slider_hbox, app, progress)

    ExQt6.Layout.add_layout(group_layout, app, slider_hbox)

    {:ok, btn_layout} = ExQt6.Layout.hbox(app)
    ExQt6.Layout.add_layout(main_layout, app, btn_layout)

    {:ok, btn_test} = ExQt6.Widget.new_button(app, "Testar")
    {:ok, btn_msg} = ExQt6.Widget.new_button(app, "MessageBox")
    {:ok, btn_file} = ExQt6.Widget.new_button(app, "Arquivo")
    {:ok, btn_color} = ExQt6.Widget.new_button(app, "Cor")
    {:ok, btn_exit} = ExQt6.Widget.new_button(app, "Sair")

    ExQt6.Layout.add(btn_layout, app, btn_test)
    ExQt6.Layout.add(btn_layout, app, btn_msg)
    ExQt6.Layout.add(btn_layout, app, btn_file)
    ExQt6.Layout.add(btn_layout, app, btn_color)
    ExQt6.Layout.add(btn_layout, app, btn_exit)

    {:ok, status} = ExQt6.Widget.new_label(app, "Status: Aguardando acoes...")
    ExQt6.Widget.set_style(status, app, "color: blue; padding: 5px;")
    ExQt6.Layout.add(main_layout, app, status)

    ExQt6.Widget.show(win, app)
    IO.puts("Janela criada! Interaja com a UI...")

    loop(app, %{
      lineedit: lineedit, combo: combo, checkbox: checkbox,
      slider: slider, progress: progress,
      btn_test: btn_test, btn_msg: btn_msg, btn_file: btn_file,
      btn_color: btn_color, btn_exit: btn_exit, status: status
    })
  end

  defp loop(app, widgets) do
    receive do
      {:qt_event, %{"id" => id, "event" => event} = data} ->
        handle(app, widgets, id, event, data)
        loop(app, widgets)
      {:app_ready, _} ->
        loop(app, widgets)
      other ->
        IO.inspect(other, label: "outro")
        loop(app, widgets)
    after
      120_000 ->
        IO.puts("Timeout de inatividade (2 min)")
    end
  end

  defp handle(app, w, id, event, data) do
    cond do
      id == w.lineedit.id and event == "text_changed" ->
        text = Map.get(data, "text", "")
        status(app, w.status, "LineEdit: '#{text}'")

      id == w.combo.id and event == "value_changed" ->
        idx = Map.get(data, "value", -1)
        status(app, w.status, "Combo: indice #{idx}")

      id == w.checkbox.id and event == "check_changed" ->
        checked = Map.get(data, "checked", false)
        if checked, do: status(app, w.status, "Modo Escuro ATIVADO"),
          else: status(app, w.status, "Modo Escuro DESATIVADO")

      id == w.slider.id and event == "value_changed" ->
        value = Map.get(data, "value", 0)
        ExQt6.Widget.set_value(w.progress, app, value)
        status(app, w.status, "Slider: #{value}%")

      id == w.btn_test.id and event == "clicked" ->
        status(app, w.status, "Botao TESTAR clicado!")

      id == w.btn_msg.id and event == "clicked" ->
        ExQt6.Widget.msgbox(app, type: "warning", title: "Alerta", text: "Isso e um teste!", buttons: ["OK"])
        status(app, w.status, "MessageBox exibido")

      id == w.btn_file.id and event == "clicked" ->
        result = ExQt6.Widget.file_dialog(app, mode: "open", title: "Selecione um arquivo")
        status(app, w.status, "Arquivo: #{inspect(result)}")

      id == w.btn_color.id and event == "clicked" ->
        result = ExQt6.Widget.color_dialog(app, title: "Escolha uma cor")
        status(app, w.status, "Cor: #{inspect(result)}")

      id == w.btn_exit.id and event == "clicked" ->
        IO.puts("Saindo...")
        System.halt(0)

      true ->
        IO.inspect(%{id: id, event: event, data: data}, label: "evento")
    end
  end

  defp status(app, widget, message) do
    ExQt6.Widget.set_text(widget, app, "Status: #{message}")
    IO.puts(message)
  end
end

TestDrive.run()
