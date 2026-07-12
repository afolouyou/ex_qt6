# ============================================================================
# ExQt6 Task Manager + Pomodoro Dashboard
# ============================================================================
# Widgets used: QPushButton, QLabel, QLineEdit, QComboBox, QCheckBox,
#   QSlider, QPlainTextEdit, QVBoxLayout, QHBoxLayout, QTimer
# ============================================================================

{:ok, app} = ExQt6.App.start_link(target: self())

receive do
  {:app_ready, _} -> IO.puts("App ready!")
after
  5000 -> IO.puts("ERROR: app not ready"); exit(:timeout)
end

IO.puts("Building dashboard...")

# === Main Window ===
{:ok, win} = ExQt6.Widget.new_window(app)
ExQt6.Widget.set_title(win, app, "ExQt6 Task Manager + Pomodoro")
ExQt6.Widget.resize(win, app, 700, 650)

{:ok, main_vbox} = ExQt6.Layout.vbox(app)
ExQt6.Layout.set_layout(main_vbox, app, win)

# === HEADER ===
{:ok, title_label} = ExQt6.Widget.new_label(app, "ExQt6 Task Manager + Pomodoro Dashboard")
ExQt6.Layout.add(main_vbox, app, title_label)

# === TOP SECTION: Pomodoro + Config side by side ===
{:ok, top_hbox} = ExQt6.Layout.hbox(app)
ExQt6.Layout.add_layout(main_vbox, app, top_hbox)

# --- Pomodoro Panel (left) ---
{:ok, pom_vbox} = ExQt6.Layout.vbox(app)
{:ok, pom_title} = ExQt6.Widget.new_label(app, "Pomodoro Timer")
{:ok, timer_label} = ExQt6.Widget.new_label(app, "25:00")
{:ok, pom_status} = ExQt6.Widget.new_label(app, "Status: Idle")

{:ok, pom_btns} = ExQt6.Layout.hbox(app)
{:ok, btn_start} = ExQt6.Widget.new_button(app, "Start")
{:ok, btn_pause} = ExQt6.Widget.new_button(app, "Pause")
{:ok, btn_reset} = ExQt6.Widget.new_button(app, "Reset")
ExQt6.Layout.add(pom_btns, app, btn_start)
ExQt6.Layout.add(pom_btns, app, btn_pause)
ExQt6.Layout.add(pom_btns, app, btn_reset)

{:ok, pom_presets} = ExQt6.Layout.hbox(app)
{:ok, btn_25m} = ExQt6.Widget.new_button(app, "25m")
{:ok, btn_15m} = ExQt6.Widget.new_button(app, "15m")
{:ok, btn_5m} = ExQt6.Widget.new_button(app, "5m")
ExQt6.Layout.add(pom_presets, app, btn_25m)
ExQt6.Layout.add(pom_presets, app, btn_15m)
ExQt6.Layout.add(pom_presets, app, btn_5m)

ExQt6.Layout.add(pom_vbox, app, pom_title)
ExQt6.Layout.add(pom_vbox, app, timer_label)
ExQt6.Layout.add(pom_vbox, app, pom_status)
ExQt6.Layout.add_layout(pom_vbox, app, pom_btns)
ExQt6.Layout.add_layout(pom_vbox, app, pom_presets)

# --- Config Panel (right) ---
{:ok, cfg_vbox} = ExQt6.Layout.vbox(app)
{:ok, cfg_title} = ExQt6.Widget.new_label(app, "Settings")

{:ok, vol_row} = ExQt6.Layout.hbox(app)
{:ok, vol_label} = ExQt6.Widget.new_label(app, "Volume:")
{:ok, volume_slider} = ExQt6.Widget.new_slider(app, min: 0, max: 100, value: 70)
{:ok, vol_value} = ExQt6.Widget.new_label(app, "70")
ExQt6.Layout.add(vol_row, app, vol_label)
ExQt6.Layout.add(vol_row, app, volume_slider)
ExQt6.Layout.add(vol_row, app, vol_value)

{:ok, theme_row} = ExQt6.Layout.hbox(app)
{:ok, theme_label} = ExQt6.Widget.new_label(app, "Theme:")
{:ok, theme_combo} = ExQt6.Widget.new_combobox(app, ["Light", "Dark", "Nord", "Dracula", "Monokai"])
ExQt6.Layout.add(theme_row, app, theme_label)
ExQt6.Layout.add(theme_row, app, theme_combo)

{:ok, notif_check} = ExQt6.Widget.new_checkbox(app, "Desktop Notifications")
{:ok, sound_check} = ExQt6.Widget.new_checkbox(app, "Sound Alerts")

ExQt6.Layout.add(cfg_vbox, app, cfg_title)
ExQt6.Layout.add_layout(cfg_vbox, app, vol_row)
ExQt6.Layout.add_layout(cfg_vbox, app, theme_row)
ExQt6.Layout.add(cfg_vbox, app, notif_check)
ExQt6.Layout.add(cfg_vbox, app, sound_check)

ExQt6.Layout.add_layout(top_hbox, app, pom_vbox)
ExQt6.Layout.add_layout(top_hbox, app, cfg_vbox)

# === TASK INPUT ===
{:ok, input_hbox} = ExQt6.Layout.hbox(app)
ExQt6.Layout.add_layout(main_vbox, app, input_hbox)

{:ok, task_input} = ExQt6.Widget.new_lineedit(app, "Enter new task...")
{:ok, cat_label} = ExQt6.Widget.new_label(app, "Category:")
{:ok, cat_combo} = ExQt6.Widget.new_combobox(app, ["Work", "Personal", "Bug", "Feature", "Docs"])
{:ok, btn_add} = ExQt6.Widget.new_button(app, "+ Add")

ExQt6.Layout.add(input_hbox, app, task_input)
ExQt6.Layout.add(input_hbox, app, cat_label)
ExQt6.Layout.add(input_hbox, app, cat_combo)
ExQt6.Layout.add(input_hbox, app, btn_add)

# === TASK LIST ===
{:ok, task_title} = ExQt6.Widget.new_label(app, "--- Tasks ---")
ExQt6.Layout.add(main_vbox, app, task_title)

# 5 pre-created task rows (empty by default, fillable via input)
initial_tasks = ["Fix authentication bug", "Write API docs", "Deploy v2.0", "Review PR #142", "Update deps"]

tasks = Enum.map(initial_tasks, fn text ->
  {:ok, hbox} = ExQt6.Layout.hbox(app)
  {:ok, check} = ExQt6.Widget.new_checkbox(app, "")
  {:ok, label} = ExQt6.Widget.new_label(app, text)
  {:ok, cat} = ExQt6.Widget.new_combobox(app, ["Work", "Personal", "Bug", "Feature", "Docs"])
  {:ok, prio} = ExQt6.Widget.new_combobox(app, ["Low", "Med", "High", "Critical"])

  ExQt6.Layout.add(hbox, app, check)
  ExQt6.Layout.add(hbox, app, label)
  ExQt6.Layout.add(hbox, app, cat)
  ExQt6.Layout.add(hbox, app, prio)
  ExQt6.Layout.add_layout(main_vbox, app, hbox)

  %{row: hbox, check: check, label: label, cat: cat, prio: prio, label_text: text}
end)

# === NOTES ===
{:ok, notes_title} = ExQt6.Widget.new_label(app, "--- Event Log ---")
{:ok, notes} = ExQt6.Widget.new_textedit(app, "Event log will appear here...\n")
ExQt6.Layout.add(main_vbox, app, notes_title)
ExQt6.Layout.add(main_vbox, app, notes)

# === STATUS BAR ===
{:ok, status_hbox} = ExQt6.Layout.hbox(app)
ExQt6.Layout.add_layout(main_vbox, app, status_hbox)

{:ok, status_label} = ExQt6.Widget.new_label(app, "Ready")
{:ok, event_label} = ExQt6.Widget.new_label(app, "Events: 0")
{:ok, clock_label} = ExQt6.Widget.new_label(app, "")

ExQt6.Layout.add(status_hbox, app, status_label)
ExQt6.Layout.add(status_hbox, app, event_label)
ExQt6.Layout.add(status_hbox, app, clock_label)

# === Show & Timers ===
ExQt6.Widget.show(win, app)

{:ok, pom_timer} = ExQt6.Timer.new(app, 1000)
{:ok, clock_timer} = ExQt6.Timer.new(app, 1000)
ExQt6.Timer.start(clock_timer, app)

IO.puts("Dashboard ready! Running event loop...")

# ============================================================================
# Event Loop
# ============================================================================
defmodule Dashboard do
  def format_time(seconds) do
    m = div(seconds, 60)
    s = rem(seconds, 60)
    String.pad_leading(Integer.to_string(m), 2, "0") <>
      ":" <>
      String.pad_leading(Integer.to_string(s), 2, "0")
  end

  def log_event(state, msg) do
    count = state.event_count + 1
    new_log = "#{msg}\n"
    current = state.log_text
    log_text = if String.length(current) > 3000, do: new_log, else: current <> new_log
    %{state | event_count: count, log_text: log_text}
  end

  def loop(state) do
    receive do
      # === Pomodoro Timer Tick ===
      {:qt_event, %{"event" => "timer_tick", "id" => tid}} when tid == state.pom_timer_id ->
        if state.pom_running do
          new_secs = state.pom_seconds - 1
          if new_secs <= 0 do
            ExQt6.Widget.set_text(state.timer_label, state.app, "00:00")
            ExQt6.Widget.set_text(state.pom_status, state.app, "Status: DONE! Take a break!")
            ExQt6.Timer.stop(state.pom_timer, state.app)
            state = log_event(state, ">>> Pomodoro completed!")
            ExQt6.Widget.set_text(state.notes, state.app, state.log_text)
            loop(%{state | pom_running: false, pom_seconds: 0})
          else
            ExQt6.Widget.set_text(state.timer_label, state.app, format_time(new_secs))
            loop(%{state | pom_seconds: new_secs})
          end
        else
          loop(state)
        end

      # === Clock Tick ===
      {:qt_event, %{"event" => "timer_tick", "id" => tid}} when tid == state.clock_timer_id ->
        {{_, _, _}, {h, m, s}} = :calendar.local_time()
        time_str = String.pad_leading(Integer.to_string(h), 2, "0") <>
          ":" <> String.pad_leading(Integer.to_string(m), 2, "0") <>
          ":" <> String.pad_leading(Integer.to_string(s), 2, "0")
        ExQt6.Widget.set_text(state.clock_label, state.app, time_str)
        loop(state)

      # === Button Clicks ===
      {:qt_event, %{"event" => "clicked", "id" => id}} ->
        state = cond do
          id == state.btn_start_id ->
            unless state.pom_running do
              ExQt6.Timer.start(state.pom_timer, state.app)
              ExQt6.Widget.set_text(state.pom_status, state.app, "Status: Running")
              log_event(state, "[Pomodoro] Started (#{format_time(state.pom_seconds)})")
            else
              state
            end

          id == state.btn_pause_id ->
            if state.pom_running do
              ExQt6.Timer.stop(state.pom_timer, state.app)
              ExQt6.Widget.set_text(state.pom_status, state.app, "Status: Paused (#{format_time(state.pom_seconds)})")
              log_event(state, "[Pomodoro] Paused at #{format_time(state.pom_seconds)}")
            else
              state
            end

          id == state.btn_reset_id ->
            ExQt6.Timer.stop(state.pom_timer, state.app)
            ExQt6.Widget.set_text(state.timer_label, state.app, format_time(state.pom_total))
            ExQt6.Widget.set_text(state.pom_status, state.app, "Status: Idle")
            log_event(state, "[Pomodoro] Reset to #{format_time(state.pom_total)}")

          id == state.btn_25m_id ->
            set_pomodoro(state, 25 * 60)

          id == state.btn_15m_id ->
            set_pomodoro(state, 15 * 60)

          id == state.btn_5m_id ->
            set_pomodoro(state, 5 * 60)

          id == state.btn_add_id ->
            state

          true ->
            log_event(state, "Button click: id=#{id}")
        end

        ExQt6.Widget.set_text(state.event_label, state.app, "Events: #{state.event_count}")
        ExQt6.Widget.set_text(state.notes, state.app, state.log_text)
        loop(state)

      # === Return pressed on input ===
      {:qt_event, %{"event" => "return_pressed", "id" => id, "text" => text}} ->
        state = if id == state.task_input_id and text != "" do
          add_task_with_text(state, text)
        else
          log_event(state, "Return pressed: #{text}")
        end
        ExQt6.Widget.set_text(state.event_label, state.app, "Events: #{state.event_count}")
        ExQt6.Widget.set_text(state.notes, state.app, state.log_text)
        loop(state)

      # === Checkbox toggles ===
      {:qt_event, %{"event" => "check_changed", "id" => id, "checked" => checked}} ->
        task = Enum.find(state.tasks, fn t -> t.check.id == id end)
        state = if task do
          status = if checked, do: "DONE", else: "TODO"
          log_event(state, "[Task] #{task.label_text} -> #{status}")
        else
          name = cond do
            id == state.notif_check_id -> "Notifications"
            id == state.sound_check_id -> "Sound"
            true -> "checkbox=#{id}"
          end
          log_event(state, "[Setting] #{name}: #{if checked, do: "ON", else: "OFF"}")
        end
        ExQt6.Widget.set_text(state.event_label, state.app, "Events: #{state.event_count}")
        ExQt6.Widget.set_text(state.notes, state.app, state.log_text)
        loop(state)

      # === Slider changes ===
      {:qt_event, %{"event" => "value_changed", "id" => id, "value" => value}} ->
        state = if id == state.volume_slider_id do
          ExQt6.Widget.set_text(state.vol_value_label, state.app, Integer.to_string(value))
          log_event(state, "[Setting] Volume: #{value}%")
        else
          log_event(state, "Slider id=#{id}: #{value}")
        end
        ExQt6.Widget.set_text(state.event_label, state.app, "Events: #{state.event_count}")
        ExQt6.Widget.set_text(state.notes, state.app, state.log_text)
        loop(state)

      # === Combobox changes ===
      {:qt_event, %{"event" => "index_changed", "id" => id, "text" => text}} ->
        state = cond do
          id == state.theme_combo_id ->
            log_event(state, "[Setting] Theme -> #{text}")
          id == state.cat_combo_id ->
            log_event(state, "[Setting] Input category -> #{text}")
          true ->
            task = Enum.find(state.tasks, fn t -> t.cat.id == id || t.prio.id == id end)
            if task do
              log_event(state, "[Task] \"#{task.label_text}\" -> #{text}")
            else
              log_event(state, "Combobox id=#{id}: #{text}")
            end
        end
        ExQt6.Widget.set_text(state.event_label, state.app, "Events: #{state.event_count}")
        ExQt6.Widget.set_text(state.notes, state.app, state.log_text)
        loop(state)

      # === Text changed on input ===
      {:qt_event, %{"event" => "text_changed", "id" => id, "text" => _text}} when id == state.task_input_id ->
        loop(state)

      # === Text changed on notes ===
      {:qt_event, %{"event" => "text_changed", "id" => _id, "text" => _text}} ->
        loop(state)

      # === Daemon died ===
      {:daemon_died, reason} ->
        IO.puts("Daemon died: #{inspect(reason)}, waiting for restart...")
        receive do
          {:app_ready, _} -> IO.puts("Daemon restarted!")
        after 10_000 -> IO.puts("Restart timeout!")
        end
        loop(state)

      # === Catch-all ===
      {:qt_event, _other} ->
        loop(state)

    after
      120_000 ->
        IO.puts("Timeout!")
        ExQt6.App.cmd(state.app, %{name: "quit"})
    end
  end

  defp set_pomodoro(state, seconds) do
    if state.pom_running do
      ExQt6.Timer.stop(state.pom_timer, state.app)
    end
    ExQt6.Widget.set_text(state.timer_label, state.app, format_time(seconds))
    ExQt6.Widget.set_text(state.pom_status, state.app, "Status: Ready (#{format_time(seconds)})")
    log_event(state, "[Pomodoro] Set to #{format_time(seconds)}")
  end

  defp add_task_with_text(state, text) do
    task = Enum.find(state.tasks, fn t -> t.label_text == "" end)
    if task do
      ExQt6.Widget.set_text(task.label, state.app, text)
      ExQt6.Widget.set_text(state.task_input, state.app, "")
      tasks = Enum.map(state.tasks, fn t ->
        if t == task, do: %{t | label_text: text}, else: t
      end)
      log_event(%{state | tasks: tasks}, "[Task] Added: #{text}")
    else
      ExQt6.Widget.set_text(state.task_input, state.app, "")
      log_event(state, "[Task] List full! (5 max)")
    end
  end
end

Dashboard.loop(%{
  app: app,
  timer_label: timer_label,
  pom_status: pom_status,
  pom_timer: pom_timer,
  pom_timer_id: pom_timer.id,
  clock_timer: clock_timer,
  clock_timer_id: clock_timer.id,
  pom_seconds: 25 * 60,
  pom_total: 25 * 60,
  pom_running: false,
  btn_start_id: btn_start.id,
  btn_pause_id: btn_pause.id,
  btn_reset_id: btn_reset.id,
  btn_25m_id: btn_25m.id,
  btn_15m_id: btn_15m.id,
  btn_5m_id: btn_5m.id,
  btn_add_id: btn_add.id,
  volume_slider_id: volume_slider.id,
  vol_value_label: vol_value,
  theme_combo_id: theme_combo.id,
  cat_combo_id: cat_combo.id,
  task_input_id: task_input.id,
  notif_check_id: notif_check.id,
  sound_check_id: sound_check.id,
  tasks: tasks,
  notes: notes,
  event_label: event_label,
  clock_label: clock_label,
  event_count: 0,
  log_text: ""
})
