defmodule Mlem.Utils do
  require Logger

  def return(val) do
    {:ok, val}
  end

  def build_model_path do
    Path.join([Mix.Project.app_path(), "priv", "ml"])
  end

  def src_model_path do
    Path.join([Path.dirname(Mix.Project.deps_path), "priv", "ml"])
  end

  def python_lib_path do
    Path.join([Application.app_dir(:elixir_ml), "priv", "python"])
  end

  def root_module_name do
    [root | _]  =
      Mix.Project.get!()
      |> inspect
      |> String.split(".")

    root
  end
end
