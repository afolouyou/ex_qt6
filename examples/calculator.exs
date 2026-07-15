Application.ensure_all_started(:ex_qt6)

defmodule Calculator do
  @moduledoc "Full calculator using Qt6 grid layout, buttons, and event forwarding."

  def run do
    {:ok, app} = ExQt6.App.start_link(target: self())
    Process.sleep(500)

    {:ok, win} = ExQt6.Widget.new_window(app)
    ExQt6.Widget.set_title(win, app, "Calculator — ExQt6")
    ExQt6.Widget.resize(win, app, 320, 480)

    {:ok, root_layout} = ExQt6.Layout.vbox(app)
    ExQt6.Layout.set_layout(root_layout, app, win)

    # Display label
    {:ok, display} = ExQt6.Widget.new_label(app, "0")
    ExQt6.Widget.set_font(display, app, family: "Courier", size: 28, bold: true)
    ExQt6.Widget.set_label_align(display, app, "right")
    ExQt6.Widget.set_style(display, app, "background: #1e1e2e; color: #cdd6f4; padding: 10px;")
    ExQt6.Layout.add(root_layout, app, display)

    # Grid for buttons
    {:ok, grid} = ExQt6.Layout.grid(app)
    ExQt6.Layout.add_layout(root_layout, app, grid)

    buttons = [
      {0, 0, "C"},  {0, 1, "±"},  {0, 2, "%"},  {0, 3, "÷"},
      {1, 0, "7"},  {1, 1, "8"},  {1, 2, "9"},  {1, 3, "×"},
      {2, 0, "4"},  {2, 1, "5"},  {2, 2, "6"},  {2, 3, "−"},
      {3, 0, "1"},  {3, 1, "2"},  {3, 2, "3"},  {3, 3, "+"},
      {4, 0, "0"},  {4, 2, "."},  {4, 3, "="},
    ]

    btn_map =
      for {row, col, label} <- buttons, into: %{} do
        is_op = label in ["+", "−", "×", "÷", "="]
        bg = if is_op, do: "#f38ba8", else: "#313244"
        color = if is_op, do: "#1e1e2e", else: "#cdd6f4"

        {:ok, btn} = ExQt6.Widget.new_button(app, label)
        ExQt6.Widget.set_font(btn, app, size: 18, bold: true)
        ExQt6.Widget.set_style(btn, app, "background: #{bg}; color: #{color}; min-height: 55px;")
        cols = if row == 4 and col == 0, do: [col_span: 2], else: []
        ExQt6.Layout.grid_add_widget(grid, app, btn, row, col, cols)
        {label, btn}
      end

    ExQt6.Widget.show(win, app)
    loop(app, display, btn_map, %{current: "0", op: nil, operand: nil, fresh: true})
  end

  defp loop(app, display, btn_map, state) do
    receive do
      {:qt_event, %{"event" => "clicked", "id" => btn_id}} ->
        label = Enum.find_value(btn_map, fn {lbl, btn} -> if btn.id == btn_id, do: lbl end)
        if label do
          state = handle_input(state, label)
          ExQt6.Widget.set_text(display, app, state.current)
        end
        loop(app, display, btn_map, state)

      {:qt_event, %{"event" => "close"}} ->
        IO.puts("Calculator closed.")
        System.halt(0)

      {:qt_event, _} ->
        loop(app, display, btn_map, state)
    end
  end

  defp handle_input(state, label) do
    cond do
      label in ["0","1","2","3","4","5","6","7","8","9","."] ->
        if state.fresh do
          %{state | current: label, fresh: false}
        else
          if label == "." and String.contains?(state.current, "."),
            do: state,
            else: %{state | current: state.current <> label}
        end
      label == "C" ->
        %{current: "0", op: nil, operand: nil, fresh: true}
      label == "±" ->
        val = parse_num(state.current)
        %{state | current: format(-val), fresh: true}
      label == "%" ->
        val = parse_num(state.current)
        %{state | current: format(val / 100), fresh: true}
      label in ["+","−","×","÷"] ->
        val = parse_num(state.current)
        if state.op != nil and not state.fresh do
          result = calculate(state.operand, val, state.op)
          %{current: format(result), op: label, operand: result, fresh: true}
        else
          %{state | op: label, operand: val, fresh: true}
        end
      label == "=" ->
        if state.op do
          val = parse_num(state.current)
          result = calculate(state.operand, val, state.op)
          %{current: format(result), op: nil, operand: nil, fresh: true}
        else
          state
        end
    end
  end

  defp parse_num(s) do
    case Float.parse(s) do
      {n, _} -> n
      :error -> 0.0
    end
  end

  defp calculate(a, b, "+"), do: a + b
  defp calculate(a, b, "−"), do: a - b
  defp calculate(a, b, "×"), do: a * b
  defp calculate(a, b, "÷") do
    if b == 0, do: 0.0, else: a / b
  end

  defp format(n) do
    if n == Float.round(n) and abs(n) < 1_000_000_000 do
      Integer.to_string(trunc(n))
    else
      Float.to_string(n) |> String.trim_trailing("0") |> String.trim_trailing(".")
    end
  end
end

Calculator.run()
