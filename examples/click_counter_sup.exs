Process.register(self(), :click_counter)

# Wait for App to be ready
receive do
  {:app_ready, _daemon} -> :ok
after
  5000 -> IO.puts("WARN: app not ready")
end

IO.puts("Building UI...")

app = :erlang.whereis(ExQt6.App)

{:ok, win} = ExQt6.Widget.new_window(app)
ExQt6.Widget.set_title(win, app, "Click Counter")
ExQt6.Widget.resize(win, app, 300, 150)

{:ok, layout} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(layout, app, win)

{:ok, label} = ExQt6.Widget.new_label(app, "Clicks: 0")
{:ok, button} = ExQt6.Widget.new_button(app, "Click me!")

ExQt6.Layout.add(layout, app, label)
ExQt6.Layout.add(layout, app, button)

ExQt6.Widget.show(win, app)

IO.puts("Running! Click the button. Quit in 30s.")

defmodule ClickLoop do
  def loop(state) do
    receive do
      {:qt_event, %{"event" => "clicked", "id" => _id}} ->
        count = state.count + 1
        ExQt6.Widget.set_text(state.label, state.app, "Clicks: #{count}")
        loop(%{state | count: count})
      {:qt_event, _} ->
        loop(state)
    after
      30_000 ->
        IO.puts("Timeout")
        ExQt6.App.cmd(state.app, %{name: "quit"})
    end
  end
end

ClickLoop.loop(%{count: 0, label: label, app: app})
