defmodule Mlem.Trainer do
  require Logger
  alias Mlem.Utils, as: U
  alias Mlem.ModelRegistry

  def train(model_name) do
    # 1. Create python instance
    # 2. Turn custom model definitions from elixir schema into keras pipeline
    # 3. Create train test split and run it through keras in python
    # 4. Store resulting model in the appropriate folder in U.root_module_name
    # 5. Update models.config?

    Logger.info("Creating Python training process...")
    {:ok, python_id} = Mlem.Ports.Trainer.new()

    schema_name = ModelRegistry.get_schema_name(model_name)
    schema_module = ModelRegistry.get_schema_module(schema_name)
    model_config = Mlem.ModelRegistry.get_model_config(model_name)
    training_data_path = Path.join([Mlem.Utils.build_model_path,
                                    "training_data",
                                    model_config["training_data"]])

    for [raw_doc, raw_labels] <- schema_module.get_training_data(training_data_path) do
      {:ok, doc} = schema_module.extract_features(raw_doc)
      {:ok, doc} = schema_module.extract_labels(doc, raw_labels)
      Mlem.Ports.Trainer.add_training_data(python_id, doc, :bag_of_words, :single_label)
    end

    Mlem.Ports.Trainer.train(python_id, :bag_of_words, :single_label)

    output_dir = ensure_output_directory(schema_module)
    Mlem.Ports.Trainer.serialize(python_id, Path.join(output_dir, model_name))

  end

  def ensure_output_directory(schema_module) do
    output_dir = Path.join([U.build_model_path(), "models", schema_module.id()])
    File.mkdir_p!(output_dir)
    output_dir
  end
end
