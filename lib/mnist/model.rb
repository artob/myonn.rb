# This is free and unencumbered software released into the public domain.

require 'myonn'
require 'mnist/parser'

module MNIST
  class Model
    INPUT_NODES   = 784 # 28x28 pixels
    HIDDEN_NODES  = 200
    OUTPUT_NODES  = 10  # (0..9)

    def self.load(filepath)
      self.new(nn: MYONN::NeuralNetwork.load(filepath))
    end

    def initialize(nn: nil, learning_rate: nil)
      @nn = nn || MYONN::NeuralNetwork.new(
        input_nodes:   INPUT_NODES,
        hidden_nodes:  HIDDEN_NODES,
        output_nodes:  OUTPUT_NODES,
        learning_rate: (learning_rate || 0.1).to_f,
      )
    end

    def save(filepath)
      @nn.save(filepath)
    end

    def train!(filepath, epochs: 1, limit: nil)
      zeros = Numo::DFloat.zeros(@nn.output_nodes)

      MNIST::Parser.open(filepath) do |dataset|
        epochs.times do
          count = 0
          dataset.each_record do |label, pixels|
            count += 1
            break if limit && count >= limit
            inputs = self.normalize(pixels)
            targets = zeros + 0.01
            targets[label] = 0.99
            @nn.train(inputs, targets)
          end
        end
      end
    end

    def validate(filepath)
      scorecard = []

      MNIST::Parser.open(filepath) do |dataset|
        dataset.each_record do |label, pixels|
          output = self.recognize(pixels)
          is_correct = (output == label)
          scorecard.append(is_correct ? 1 : 0)
        end
      end

      scorecard.sum / scorecard.size.to_f
    end

    def recognize(pixels)
      self.query(pixels).max_index()
    end

    def query(pixels)
      inputs = self.normalize(pixels)
      outputs = @nn.query(inputs)
    end

    def normalize(pixels)
      (pixels.reshape(INPUT_NODES) / 255.0 * 0.99) + 0.01
    end
  end # Model
end # MNIST
