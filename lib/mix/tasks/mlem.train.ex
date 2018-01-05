defmodule Mix.Tasks.Mlem.Train do
  use Mix.Task

  @shortdoc "Trains a model."
  def run([model_name]) do
    {:ok, _started} = Application.ensure_all_started(:mlem)
    Mlem.Trainer.train(model_name)
  end
end
