{:ok, app} = ExQt6.App.start_link(target: self())

receive do
  {:app_ready, _daemon} -> IO.puts("App ready!")
after
  5000 -> IO.puts("WARN: app not ready"); exit(:timeout)
end

IO.puts("Building auto-counter...")

{:ok, win} = ExQt6.Widget.new_window(app)
ExQt6.Widget.set_title(win, app, "Auto Counter (Timer)")
ExQt6.Widget.resize(win, app, 250, 120)

{:ok, vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(vbox, app, win)

{:ok, label} = ExQt6.Widget.new_label(app, "Count: 0")
{:ok, start_btn} = ExQt6.Widget.new_button(app, "Start")
{:ok, stop_btn} = ExQt6.Widget.new_button(app, "Stop")
{:ok, reset_btn} = ExQt6.Widget.new_button(app, "Reset")

ExQt6.Layout.add(vbox, app, label)
ExQt6.Layout.add(vbox, app, start_btn)
ExQt6.Layout.add(vbox, app, stop_btn)
ExQt6.Layout.add(vbox, app, reset_btn)

{:ok, timer} = ExQt6.Timer.new(app, 500)

ExQt6.Widget.show(win, app)

IO.puts("Running! Timer ticks every 500ms. Timeout 30s.")

defmodule CounterLoop do
  def loop(state) do
    receive do
      {:qt_event, %{"event" => "timer_tick"}} ->
        count = state.count + 1
        ExQt6.Widget.set_text(state.label, state.app, "Count: #{count}")
        loop(%{state | count: count})

      {:qt_event, %{"event" => "clicked", "id" => id}} ->
        cond do
          id == state.start_id ->
            IO.puts("Starting timer...")
            ExQt6.Timer.start(state.timer, state.app)
            loop(state)
          id == state.stop_id ->
            IO.puts("Stopping timer...")
            ExQt6.Timer.stop(state.timer, state.app)
            loop(state)
          id == state.reset_id ->
            IO.puts("Resetting counter...")
            ExQt6.Widget.set_text(state.label, state.app, "Count: 0")
            loop(%{state | count: 0})
          true ->
            loop(state)
        end

      {:qt_event, _} ->
        loop(state)

      {:daemon_died, _reason} ->
        receive do
          {:app_ready, _} -> IO.puts("Daemon restarted!")
        after 10_000 -> IO.puts("Restart timeout!")
        end
        loop(state)

    after
      30_000 ->
        IO.puts("Timeout, quitting...")
        ExQt6.App.cmd(state.app, %{name: "quit"})
    end
  end
end

CounterLoop.loop(%{
  app: app,
  label: label,
  timer: timer,
  count: 0,
  start_id: start_btn.id,
  stop_id: stop_btn.id,
  reset_id: reset_btn.id
})
