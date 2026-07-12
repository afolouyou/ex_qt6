defmodule ExQt6 do
  @moduledoc """
  Qt6 UI toolkit for Elixir.

  Uses a Qt C++ daemon process communicating via JSON over stdin/stdout.

  ## Quick Start

      # Start the application (auto-started via OTP supervisor)
      {:ok, app} = ExQt6.App.start_link(target: self())

      # Wait for daemon to be ready
      receive do
        {:app_ready, daemon} -> :ok
      end

      # Create widgets
      {:ok, win} = ExQt6.Widget.new_window(app)
      ExQt6.Widget.set_title(win, app, "Hello")
      {:ok, btn} = ExQt6.Widget.new_button(app, "Click me")
      {:ok, layout} = ExQt6.Layout.vbox(app)
      ExQt6.Layout.set_layout(layout, app, win)
      ExQt6.Layout.add(layout, app, btn)
      ExQt6.Widget.show(win, app)
  """
end
