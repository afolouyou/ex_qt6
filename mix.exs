defmodule ExQt6.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_qt6,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      compilers: [:qt_daemon] ++ Mix.compilers(),
      deps: deps(),
      name: "ExQt6",
      description: "Qt6 UI toolkit for Elixir via a C++ daemon process",
      source_url: "https://github.com/folou/ex_qt6"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExQt6.Application, []}
    ]
  end

  defp deps do
    [{:jason, "~> 1.4"}]
  end
end

defmodule Mix.Tasks.Compile.QtDaemon do
  use Mix.Task

  @impl true
  def run(_args) do
    project_dir = File.cwd!()
    src = Path.join(project_dir, "native/qt_daemon/qt_daemon")
    out = Path.join(project_dir, "priv/qt_daemon")
    build_priv = Path.join(Mix.Project.build_path(), "lib/ex_qt6/priv")

    unless File.exists?(src) do
      Mix.raise(
        "Qt daemon not found at #{src}. " <>
          "Compile with: cd native/qt_daemon && nix-shell --run 'bash build.sh'"
      )
    end

    File.mkdir_p!(Path.dirname(out))
    File.cp!(src, out)
    File.mkdir_p!(build_priv)
    File.cp!(src, Path.join(build_priv, "qt_daemon"))

    :ok
  rescue
    e in File.CopyError ->
      Mix.shell().info("Warning: could not copy qt_daemon (file busy): #{Exception.message(e)}")
      :ok
  end
end
