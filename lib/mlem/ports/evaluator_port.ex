defmodule Mlem.Ports.Evaluator do
  use Piton.Port
  alias Mlem.Utils, as: U
  require Logger

  def new() do
    agent_id = System.unique_integer([:positive])
    global_id = get_global_id(agent_id)
    Mlem.Ports.Evaluator.start_link(
      [path: U.python_lib_path, python: Path.join([U.python_lib_path, "venv", "bin", "python3"])],
      [name: global_id])
    Mlem.Ports.Evaluator.execute(global_id, :evaluator, :init, [])
    {:ok, agent_id}
  end

  def classify(agent_id, model_name, document) do
    agent_id
    |> get_global_id
    |> Mlem.Ports.Evaluator.execute(:evaluator, :classify,
         [model_name, Mlem.Features.raw_features(document.features)])
  end

  def load_models(agent_id, models_path, config_object) do
    config_for_python =
      config_object
      |> Map.get("models")
      |> Enum.map(fn m -> [m["schema"], m["name"]] end)

    agent_id
    |> get_global_id
    |> Mlem.Ports.Evaluator.execute(:evaluator, :load_models,
                                        [models_path, config_for_python])
  end

  def abort(agent_id) do
    agent_id
    |> get_global_id
    |> GenServer.stop
  end

  defp get_global_id(agent_id) do
    {:global, String.to_atom("mlevaluator" <> Integer.to_string(agent_id))}
  end
end
