defmodule Mlem.ModelServer do
  use GenServer
  alias Mlem.Utils, as: U

  ## Client API

  @doc """
  Starts the server.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: :model_server)
  end

  def classify(model_name, raw_doc) do
    GenServer.call(:model_server, {:classify, model_name, raw_doc})
  end

  ## Server Callbacks
  def init(:ok) do
    {:ok, evaluator_id} = Mlem.Ports.Evaluator.new()
    models_dir = Path.join([U.build_model_path(), "models"])
    model_config = Mlem.ModelRegistry.get_model_config
    Mlem.Ports.Evaluator.load_models(evaluator_id, models_dir, model_config)
    {:ok, %{evaluator_id: evaluator_id}}
  end

  def handle_call({:classify, model_name, raw_doc}, _from, state) do
    options = Mlem.ModelRegistry.get_model_config(model_name)
    schema = options["schema"]
    schema_module = Mlem.ModelRegistry.get_schema_module(schema)
    {:ok, doc} = schema_module.extract_features(raw_doc)

    {:ok, response} =
      if :erlang.function_exported(schema_module, :classify, 2) do
        schema_module.classify(doc, options)
        |> schema_module.parse_results
      else
        state[:evaluator_id]
        |> Mlem.Ports.Evaluator.classify(model_name, doc)
        |> schema_module.parse_results
      end


    {:reply, response, state}
  end
end
