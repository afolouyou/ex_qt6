defmodule ExQt6.Daemon do
  @moduledoc false

  defstruct [:port, :receiver_pid]

  def start(receiver_pid) do
    daemon = daemon_path()
    unless File.exists?(daemon), do: {:error, "qt_daemon not found at #{daemon}"}

    port = Port.open({:spawn, daemon}, [
      :line,
      :exit_status,
      :use_stdio,
      :stderr_to_stdout
    ])

    {:ok, %__MODULE__{port: port, receiver_pid: receiver_pid}}
  end

  def cmd(%__MODULE__{port: port}, commands) when is_list(commands) do
    json = Jason.encode!(commands)
    Port.command(port, json <> "\n")
  end

  def cmd(%__MODULE__{port: port}, command) when is_map(command) do
    json = Jason.encode!(command)
    Port.command(port, json <> "\n")
  end

  def stop(%__MODULE__{port: port}) do
    Port.command(port, ~s({"name":"quit"}\n))
    Port.close(port)
    :ok
  end

  def daemon_path do
    priv = :code.priv_dir(:ex_qt6)
    Path.join(priv, "qt_daemon")
  end
end

defmodule ExQt6.DaemonReceiver do
  use GenServer

  def start_link(opts) do
    target = Keyword.get(opts, :target, ExQt6.App)
    GenServer.start_link(__MODULE__, target)
  end

  def init(target) do
    case ExQt6.Daemon.start(self()) do
      {:ok, daemon} ->
        ExQt6.Daemon.cmd(daemon, %{name: "create_app"})
        ExQt6.Daemon.cmd(daemon, %{name: "exec"})
        {:ok, %{daemon: daemon, target: target}}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_call(:get_daemon, _from, %{daemon: daemon} = state) do
    {:reply, daemon, state}
  end

  def handle_info(msg, %{daemon: %{port: port}} = state) do
    case msg do
      {^port, {:data, {:eol, line}}} ->
        str = if is_list(line), do: List.to_string(line), else: line
        case Jason.decode(str) do
          {:ok, event} -> send(state.target, {:qt_event, event})
          _ -> :ok
        end
        {:noreply, state}

      {^port, {:data, data}} ->
        case Jason.decode(data) do
          {:ok, event} -> send(state.target, {:qt_event, event})
          _ -> :ok
        end
        {:noreply, state}

      {^port, {:exit_status, _status}} ->
        {:stop, :port_died, state}

      _ ->
        {:noreply, state}
    end
  end
end
