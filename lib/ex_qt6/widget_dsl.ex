defmodule ExQt6.Widget.DSL do
  @moduledoc """
  Macro to conveniently use ExQt6 widgets in scripts.

  ## Usage

      defmodule MyApp do
        use ExQt6.Widget.DSL

        def run do
          init(target: self())

          win = new_window()
          set_title(win, "My App")
          {:ok, layout} = vbox()
          set_layout(layout, win)
          {:ok, btn} = new_button("Click me")
          add(layout, btn)
          show(win)
        end
      end

  All Widget, Layout, and Timer functions are imported.
  A default `app` is set via `init/1` and used automatically.
  Widgets can be registered with `register/2` and looked up with `find/1`.
  """
  defmacro __using__(_opts) do
    quote do
      import ExQt6.Widget.DSL
      import ExQt6.Widget, except: [new_window: 1, new_button: 2]
      import ExQt6.Layout
      import ExQt6.Timer

      @doc false
      defp app do
        ExQt6.Widget.DSL.get_app()
      end
    end
  end

  @doc """
  Initialize the DSL with the caller pid as event target.
  Optionally pass `:name` for the GenServer.
  """
  def init(opts \\ []) do
    target = Keyword.get(opts, :target, self())
    case ExQt6.App.start_link(target: target) do
      {:ok, pid} ->
        :ets.new(:ex_qt6_named_widgets, [:named_table, :public, :set])
        Process.sleep(500)
        pid
      {:error, {:already_started, pid}} ->
        pid
    end
  end

  @doc false
  def get_app do
    case Process.get(:ex_qt6_app) do
      nil ->
        raise "Call ExQt6.Widget.DSL.init() first"
      app ->
        app
    end
  end

  @doc """
  Register a widget with a name for later lookup.
  """
  def register(widget, name) do
    :ets.insert(:ex_qt6_named_widgets, {name, widget})
    widget
  end

  @doc """
  Find a widget by name. Returns the widget struct or nil.
  """
  def find(name) do
    case :ets.lookup(:ex_qt6_named_widgets, name) do
      [{^name, widget}] -> widget
      [] -> nil
    end
  end
end
