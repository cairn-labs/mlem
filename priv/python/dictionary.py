import numpy as np

class Dictionary:
    def __init__(self):
        self.word_to_int = {}
        self.int_to_word = {}
        self.label_to_int = {}
        self.int_to_label = {}
        self.num_tokens = None
        self.num_labels = None

    def build_feature_dictionary(self, x_train_list):
        idx = 0
        self.word_to_int = {}
        self.int_to_word = {}

        for row in x_train_list:
            for word in row:
                word = word.decode('utf-8')
                if word not in self.word_to_int:
                    self.word_to_int[word] = idx
                    self.int_to_word[idx] = word
                    idx += 1

        self.num_tokens = idx

    def vectorize_features(self, x_train_list):
        x_train = np.zeros([len(x_train_list), len(self.int_to_word)], dtype=int)
        for idx, row in enumerate(x_train_list):
            for word in row:
                word = word.decode('utf-8')
                if word not in self.word_to_int:
                    continue
                x_train[idx][self.word_to_int[word]] += 1

        return x_train

    def build_label_dictionary(self, y_train_list):
        idx = 0
        self.label_to_int = {}
        self.int_to_label = {}

        for label in y_train_list:
            label = label.decode('utf-8')
            if label not in self.label_to_int:
                self.label_to_int[label] = idx
                self.int_to_label[idx] = label
                idx += 1

        self.num_labels = idx

    def vectorize_labels(self, y_train_list):
        y_train = np.zeros([len(y_train_list), len(self.int_to_label)], dtype=int)
        for idx, label in enumerate(y_train_list):
            label = label.decode('utf-8')
            y_train[idx][self.label_to_int[label]] = 1

        return y_train

    def parse_predicted_label(self, label_int):
        return self.int_to_label.get(label_int)
