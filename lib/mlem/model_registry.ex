defmodule Mlem.ModelRegistry do
  use GenServer
  require Logger
  alias Mlem.Utils, as: U

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: :model_registry)
  end

  def get_schema_module(schema_name) do
    GenServer.call(:model_registry, {:get_schema_module, schema_name})
  end

  def get_schema_name(model_name) do
    GenServer.call(:model_registry, {:get_schema_name, model_name})
  end

  def get_model_config() do
    GenServer.call(:model_registry, {:get_model_config})
  end

  def get_model_config(model_name) do
    GenServer.call(:model_registry, {:get_model_config, model_name})
  end

  ## Server Callbacks

  def init(:ok) do
    %{}
    |> read_model_schemas
    |> read_model_config
    |> index_model_schemas
    |> U.return
  end

  defp read_model_schemas(state) do
    schema_dir = Path.join(U.build_model_path(), "schemas")
    state = Map.put(state, :schemas, %{})

    schema_dir
    |> File.ls!
    |> Enum.filter(&(String.ends_with?(&1, ".exs")))
    |> Enum.map(&(Path.join(schema_dir, &1)))
    |> Enum.reduce(state, &read_schema/2)
  end

  defp read_schema(schema_filename, state) do
    Logger.debug("Reading schema #{schema_filename}")
    [{module, _}] = Code.load_file(schema_filename)
    Map.update!(state, :schemas, fn m -> Map.put(m, module.id(), module) end)
  end

  defp read_model_config(state) do
    model_config_path = Path.join(U.build_model_path(), "models.config")
    case File.read(model_config_path) do
      {:ok, content} ->
        Map.put(state, :model_config, Poison.decode!(content))
      {:error, e} ->
        Logger.error("Error reading model config. Make sure your application contains a priv/ml/models.config file.")
        state
    end
  end

  defp index_model_schemas(state) do
    index =
      state[:model_config]
      |> Map.get("models")
      |> Enum.map(fn m -> {m["name"], m["schema"]} end)
      |> Enum.into(%{})

    Map.put(state, :schema_index, index)
  end

  def handle_call({:get_schema_module, name}, _from, state) do
    {:reply, state[:schemas][name], state}
  end

  def handle_call({:get_model_config}, _from, state) do
    {:reply, state[:model_config], state}
  end

  def handle_call({:get_model_config, model_name}, _from, state) do
    [config | _ ] =
      state[:model_config]
      |> Map.get("models")
      |> Enum.filter(fn s -> s["name"] == model_name end)

    {:reply, config, state}
  end

  def handle_call({:get_schema_name, model_name}, _from, state) do
    {:reply, state[:schema_index][model_name], state}
  end

end
