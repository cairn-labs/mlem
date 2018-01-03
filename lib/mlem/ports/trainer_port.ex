defmodule Mlem.Ports.Trainer do
  use Piton.Port
  alias Mlem.Utils, as: U
  require Logger

  def new() do
    agent_id = System.unique_integer([:positive])
    global_id = get_global_id(agent_id)
    Mlem.Ports.Trainer.start_link(
      [path: U.python_lib_path, python: Path.join([U.python_lib_path, "venv", "bin", "python3"])],
      [name: global_id])
    Mlem.Ports.Trainer.execute(global_id, :trainer, :init, [])
    {:ok, agent_id}
  end

  def add_training_data(agent_id, document, features_type, label_type) do
    global_id = get_global_id(agent_id)

    x =
      case features_type do
        :bag_of_words -> MapSet.to_list(document.features.bag_of_words)
      end

    y =
      case label_type do
        :single_label -> document.labels.single_label
      end

    global_id
    |> Mlem.Ports.Trainer.execute(:trainer, :append_to_training_data, [x, y])
    |> U.return
  end

  def train(agent_id, features_type, label_type) do
    global_id = get_global_id(agent_id)
    Mlem.Ports.Trainer.execute(global_id, :trainer, :prepare_training_data, [features_type, label_type])
    Mlem.Ports.Trainer.execute(global_id, :trainer, :define_model_structure, [])
    Mlem.Ports.Trainer.execute(global_id, :trainer, :train, [])

    :ok
  end

  def serialize(agent_id, output_prefix) do
    agent_id
    |> get_global_id
    |> Mlem.Ports.Trainer.execute(:trainer, :serialize, [output_prefix])
  end

  def abort(agent_id) do
    agent_id
    |> get_global_id
    |> GenServer.stop
  end

  defp get_global_id(agent_id) do
    {:global, String.to_atom("mltrainer" <> Integer.to_string(agent_id))}
  end
end
