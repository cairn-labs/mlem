defmodule Mix.Tasks.Mlem.Create do
  use Mix.Task
  import Mix.Generator
  import Macro, only: [camelize: 1]
  alias Mlem.Utils, as: U

  @shortdoc "Creates a new model schema."
  def run([schema_name]) do
    Mix.shell.info "Creating new model schema #{schema_name}..."
    filename = Path.join([U.src_model_path, "schemas", schema_name <> ".exs"])
    module = Enum.join([U.root_module_name, "ModelSchemas", camelize(schema_name)], ".")
    Mix.Generator.create_directory(Path.dirname(filename))
    Mix.Generator.create_file(filename, model_file_template(mod: module, id: schema_name))
  end

  embed_template(:model_file, """
  defmodule <%= @mod %> do
    use Mlem.Model, schema_id: <%= inspect @id %>

    def extract_features(raw_doc) do
       # Implement feature extraction here, returning an Mlem.Document struct.
       {:ok, %Mlem.Document{features: %Mlem.Features{}, raw: raw_doc}}
    end

    def extract_labels(doc, labels_raw) do
      # Accepts an %Mlem.Document struct and an object containing the label
      # information for training. Returns a copy of the Document struct with
      # labels added.
      {:ok, %Mlem.Document{doc | labels: %Mlem.Labels{}}}
    end

    def get_training_data() do
      # Returns an enumerable of raw documents from a training data source.
      {:ok, []}
    end

    def parse_results(results_raw) do
      # Accepts a raw results object from the model, and returns it in a form
      # appropriate for your application.
      {:ok, results_raw}
    end
  end
  """)
end
