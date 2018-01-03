from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout
import numpy as np
import pickle

from dictionary import Dictionary

class Trainer:
    def __init__(self):
        self.reset()

    def reset(self):
        self.model = None
        self.x_train_list = []
        self.y_train_list = []
        self.x_train = None
        self.y_train = None
        self.dictionary = Dictionary()

    def define_model_structure(self):
        self.model = Sequential([
            Dense(256, input_shape=(self.dictionary.num_tokens,)),
            Dropout(0.25),
            Dense(128, input_shape=(self.dictionary.num_tokens,)),
            Dropout(0.25),
            Activation('relu'),
            Dense(self.dictionary.num_labels),
            Activation('softmax')])

        self.model.compile(optimizer='rmsprop',
                           loss='binary_crossentropy',
                           metrics=['accuracy'])

    def train(self):
        print('Training Keras model...')
        self.model.fit(self.x_train, self.y_train, epochs=10, batch_size=32)

    def serialize(self, output_prefix):
        print('Serializing dictionary...')
        with open(output_prefix + '.dic', 'wb') as outf:
            pickle.dump(self.dictionary, outf)

        print('Serializing Keras model...')
        self.model.save(output_prefix + '.h5')

    def append_to_training_data(self, x, y):
        self.x_train_list.append(x)
        self.y_train_list.append(y)

    def prepare_training_data(self, features_format, labels_format):
        self._prepare_features(features_format)
        self._prepare_labels(labels_format)

    def _prepare_features(self, features_format):
        if features_format == "bag_of_words":
            print('Building dictionary...')
            self.dictionary.build_feature_dictionary(self.x_train_list)
            print('Building feature vectors...')
            self.x_train = self.dictionary.vectorize_features(self.x_train_list)
            print('Found %d distinct tokens' % (self.dictionary.num_tokens,))
        else:
            raise NotImplementedError("Features format %s not implemented." % (features_format,))

    def _prepare_labels(self, labels_format):
        if labels_format == "single_label":
            print('Building label dictionary...')
            self.dictionary.build_label_dictionary(self.y_train_list)
            print('Building label vectors...')
            self.y_train = self.dictionary.vectorize_labels(self.y_train_list)
            print('Found %d distinct labels' % (self.dictionary.num_labels,))
        else:
            raise NotImplementedError("Labels format %s not implemented." % (labels_format,))



trainer = Trainer()


def init():
    pass


def define_model_structure():
    global trainer
    # TODO make this configurable from Elixir.
    trainer.define_model_structure()


def append_to_training_data(x, y):
    global trainer
    trainer.append_to_training_data(x, y)


def prepare_training_data(features_format, labels_format):
    global trainer
    trainer.prepare_training_data(features_format.decode('utf-8'), labels_format.decode('utf-8'))


def serialize(output_prefix):
    global trainer
    trainer.serialize(output_prefix.decode('utf-8'))


def train():
    global trainer
    trainer.train()
