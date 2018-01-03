defmodule Mlem.Model do
  defmacro __using__(opts) do
    schema_id = Keyword.get(opts, :schema_id)

    quote do
      def id(), do: unquote(schema_id)
    end
  end
end
