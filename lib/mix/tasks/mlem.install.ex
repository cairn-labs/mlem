defmodule Mix.Tasks.Mlem.Install do
  use Mix.Task
  import Mix.Generator
  alias Mlem.Utils, as: U

  @shortdoc "Installs ElixirML Python components."
  def run([]) do
    create_python()
  end

  defp create_python do
    python_lib_path = U.python_lib_path
    Mix.Generator.create_directory(python_lib_path)

    Mix.shell.info "Installing python3 virtualenv..."
    System.cmd("virtualenv", ["-p", "python3", Path.join(python_lib_path, "venv")])

    Mix.shell.info "Installing python dependencies..."
    System.cmd(Path.join([python_lib_path, "venv", "bin", "pip3"]),
      ["install", "-r", Path.join(python_lib_path, "requirements.txt")],
      into: IO.stream(:stdio, :line))
  end

end
