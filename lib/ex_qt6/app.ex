defmodule ExQt6.App do
  use GenServer

  @type t :: pid()

  def start_link(opts \\ []) do
    case Keyword.get(opts, :name) do
      nil -> GenServer.start_link(__MODULE__, opts)
      name -> GenServer.start_link(__MODULE__, opts, name: name)
    end
  end

  def cmd(pid, command) do
    GenServer.call(pid, {:cmd, command})
  end

  def batch(pid, commands) when is_list(commands) do
    GenServer.call(pid, {:batch, commands})
  end

  def get_daemon(pid) do
    GenServer.call(pid, :get_daemon)
  end

  def init(opts) do
    Process.flag(:trap_exit, true)
    target = Keyword.get(opts, :target, self())
    {:ok, %{daemon: nil, target: target, receiver_pid: nil}, {:continue, :start_receiver}}
  end

  def handle_continue(:start_receiver, state) do
    case ExQt6.DaemonReceiver.start_link(target: self()) do
      {:ok, receiver_pid} ->
        {:noreply, %{state | receiver_pid: receiver_pid}}
      {:error, reason} ->
        {:stop, reason, state}
    end
  end

  def handle_call(:get_daemon, _from, %{daemon: daemon} = state) do
    {:reply, daemon, state}
  end

  def handle_call({:cmd, _command}, _from, %{daemon: nil} = state) do
    {:reply, {:error, :not_ready}, state}
  end

  def handle_call({:cmd, command}, _from, %{daemon: daemon} = state) do
    ExQt6.Daemon.cmd(daemon, command)
    {:reply, :ok, state}
  end

  def handle_call({:batch, _commands}, _from, %{daemon: nil} = state) do
    {:reply, {:error, :not_ready}, state}
  end

  def handle_call({:batch, commands}, _from, %{daemon: daemon} = state) do
    ExQt6.Daemon.cmd(daemon, commands)
    {:reply, :ok, state}
  end

  def handle_info({:qt_event, %{"event" => "app_created"}}, %{target: target, receiver_pid: rp} = state) do
    daemon = GenServer.call(rp, :get_daemon)
    send(target, {:app_ready, daemon})
    {:noreply, %{state | daemon: daemon}}
  end

  def handle_info({:qt_event, event}, %{target: target} = state) do
    send(target, {:qt_event, event})
    {:noreply, state}
  end

  def handle_info({:app_ready, _daemon}, state) do
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, :normal}, %{receiver_pid: pid} = state) do
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, reason}, %{receiver_pid: pid} = state) do
    IO.puts("[ExQt6.App] Receiver #{inspect(pid)} died: #{inspect(reason)}, restarting...")
    send(state.target, {:daemon_died, reason})
    {:noreply, %{state | daemon: nil, receiver_pid: nil}, {:continue, :start_receiver}}
  end

  def terminate(_reason, %{daemon: %ExQt6.Daemon{} = daemon, receiver_pid: rp}) do
    ExQt6.Daemon.stop(daemon)
    if rp, do: Process.unlink(rp)
    :ok
  end

  def terminate(_reason, _state), do: :ok
end
