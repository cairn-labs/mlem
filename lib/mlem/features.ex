defmodule Mlem.Features do
  defstruct [:bag_of_words, :word_sequence]

  def raw_features(feature_struct) do
    # For now, bag_of_words is the only type of feature available so just
    # return that. Later this function will return the correct raw features
    # for use by the python port.
    feature_struct.bag_of_words
    |> MapSet.to_list
  end
end
