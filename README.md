# Mlem

**TODO: Add description and documentation. This project is incomplete and in no way ready for production usage.**

MLEM is a high-level module allowing Elixir applications to train and call machine-learned models in Python. It uses [Erlport](http://erlport.org/) in the backend to manage the Python processes that perform the actual ML. Example usage:

```
# Create a scaffold model schema in Elixir

  $ mix create basic_text_classifier

# After implementing data retrieval, vectorization, and labeling in the 
# created model, train the model

  $ mix train basic_text_classifier
 
# Inside your application's priv/ml/models.config, define a mapping 
# from each model to its schema, as well any metadata required for each
# specific model. For example, models.config could contain:

  {"models": [
     {"schema": "basic_text_classifier",
      "name": "initial_intent_extractor",
      "training_data": "intents.csv"},
      {"name": "single_word_extractor",
      "schema": "common_word_extractor",
      "num_words": 1}]}
      
# Once model is trained, it can be called from a running Elixir application:

  {:ok, result} = Mlem.ModelServer.classify("basic_text_classifier", transcription)
```
