# This is free and unencumbered software released into the public domain.

require 'numo/linalg/linalg'
Numo::Linalg::Loader.load_openblas '/opt/homebrew/Cellar/openblas/0.3.5/lib'
#puts Numo::Linalg::Loader.libs

require 'numo/narray'
require 'yaml'

module MYONN
  class NeuralNetwork
    attr_reader :input_nodes
    attr_reader :input_weights
    attr_reader :hidden_nodes
    attr_reader :output_weights
    attr_reader :output_nodes
    attr_reader :learning_rate
    attr_reader :activation_function

    def expit(x)
      (1 + Numo::NMath.exp(-x)) ** -1
    end

    def self.load(filepath)
      data = YAML.load_file(filepath)
      %i(input_weights output_weights).each do |k|
        v = data[k]
        data[k] = Numo::DFloat.cast(v['data']).reshape(*v['shape'])
      end
      self.new(data)
    end

    ##
    # Initializes the network.
    def initialize(input_nodes:, input_weights: nil, hidden_nodes:, output_nodes:, output_weights: nil, learning_rate: 0.3, activation_function: nil)
      @input_nodes         = input_nodes
      @input_weights       = input_weights  || Numo::DFloat.new(hidden_nodes, input_nodes).rand_norm(0.0, input_nodes ** -0.5)
      @hidden_nodes        = hidden_nodes
      @output_weights      = output_weights  || Numo::DFloat.new(output_nodes, hidden_nodes).rand_norm(0.0, hidden_nodes ** -0.5)
      @output_nodes        = output_nodes
      @learning_rate       = learning_rate.to_f
      @activation_function = method(activation_function || :expit)
    end

    ##
    # Returns a hash with this network's configuration.
    def to_hash
      {
        input_nodes: @input_nodes,
        hidden_nodes: @hidden_nodes,
        output_nodes: @output_nodes,
        learning_rate: @learning_rate,
        activation_function: @activation_function.name,
        input_weights: @input_weights,
        output_weights: @output_weights,
      }
    end

    ##
    # Returns a YAML string with this network's configuration.
    def to_yaml
      data = self.to_hash.inject({}) do |hash, (k, v)|
        hash[k] = case v
          when Numo::DFloat
            count = v.shape.reduce(1, :*)
            {
              'count' => count,
              'shape' => v.shape,
              'data'  => v.reshape(count).to_a,
            }
          else v
        end
        hash
      end
      YAML.dump(data)
    end

    def save(filepath)
      File.open(filepath, 'w') do |file|
        file.write(self.to_yaml)
      end
    end

    ##
    # Trains the network.
    #
    # @return [void]
    def train(inputs_list, targets_list)
      inputs  = inputs_list.expand_dims(0).transpose  # TODO
      targets = targets_list.expand_dims(0).transpose # TODO

      hidden_inputs  = @input_weights.dot(inputs)
      hidden_outputs = @activation_function.(hidden_inputs)

      final_inputs   = @output_weights.dot(hidden_outputs)
      final_outputs  = @activation_function.(final_inputs)

      output_errors  = targets - final_outputs
      hidden_errors  = @output_weights.transpose.dot(output_errors)

      @output_weights += @learning_rate * (output_errors * final_outputs * (1.0 - final_outputs)).dot(hidden_outputs.transpose)
      @input_weights  += @learning_rate * (hidden_errors * hidden_outputs * (1.0 - hidden_outputs)).dot(inputs.transpose)
    end

    ##
    # Queries the network.
    #
    # @return [Numo::DFloat]
    def query(inputs_list)
      inputs = inputs_list.expand_dims(0).transpose

      hidden_inputs  = @input_weights.dot(inputs)
      hidden_outputs = @activation_function.(hidden_inputs)

      final_inputs   = @output_weights.dot(hidden_outputs)
      final_outputs  = @activation_function.(final_inputs)
    end
  end # NeuralNetwork
end # MYONN
