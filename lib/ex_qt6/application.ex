defmodule ExQt6.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ExQt6.App, [name: ExQt6.App]}
    ]

    opts = [strategy: :one_for_one, name: ExQt6.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
