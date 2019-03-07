# This is free and unencumbered software released into the public domain.

require 'numo/narray'

module MNIST
  ##
  # See: https://pjreddie.com/projects/mnist-in-csv/
  class Parser
    def self.open(filepath, &block)
      File.open(filepath, 'r') do |file|
        block.call(self.new(file))
      end
    end

    def initialize(file)
      @file = file
    end

    def each_record(&block)
      return enum_for(:each_record) unless block_given?

      @file.rewind
      @file.each_line do |csv_line|
        record = csv_line.chomp.split(',').map(&:to_i)
        label  = record.shift
        pixels = Numo::DFloat.cast(record).reshape!(*MNIST::SHAPE)
        block.call(label, pixels)
      end
    end

    def self.parse_record(csv_line)
      record = csv_line.chomp.split(',').map(&:to_i)
      [record.shift, record]
    end

    def normalize(values)
      (Numo::DFloat[*values] / 255.0 * 0.99) + 0.01
    end
  end # Parser
end # MNIST
