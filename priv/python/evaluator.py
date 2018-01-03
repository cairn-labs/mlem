from keras.models import Sequential, load_model
import numpy as np
import pickle
import os

from dictionary import Dictionary

class Evaluator:
    def __init__(self):
        self.models = {}

    def load_models(self, models_dir, models_config):
        for schema, name in models_config:
            schema = schema.decode('utf-8')
            name = name.decode('utf-8')
            prefix = os.path.join(models_dir, schema, name)
            print('Loading model and dictionary from', prefix)
            try:
                self.models[name] = self._load_model(prefix)
            except FileNotFoundError as e:
                print('Skipping model %s:' % (prefix,))
                print(e)

    def classify(self, model_name, input_features):
        model, dic = self.models[model_name]
        features = dic.vectorize_features([input_features])
        prediction_vec = model.predict_proba(features)
        return self._parse_prediction(prediction_vec, dic)

    def _load_model(self, output_prefix):
        with open(output_prefix + '.dic', 'rb') as inf:
            dictionary = pickle.load(inf)

        model = load_model(output_prefix + '.h5')
        return model, dictionary

    @staticmethod
    def _parse_prediction(prediction_vectors, dictionary):
        # Just take the first prediction since this is designed for single
        # classifications for now.
        vec = prediction_vectors[0]
        return [[dictionary.parse_predicted_label(i), float(p)]
                for i, p in enumerate(vec)]


evaluator = Evaluator()


def init():
    pass


def load_models(models_dir, models_config):
    global evaluator
    evaluator.load_models(models_dir.decode('utf-8'), models_config)


def classify(model_name, doc):
    global evaluator
    return evaluator.classify(model_name.decode('utf-8'), doc)
