#!/usr/bin/env ruby -Ilib
# This is free and unencumbered software released into the public domain.

require 'myonn'
require 'mnist'

model = MNIST::Model.new(
  learning_rate: (ENV['RATE'] || 0.1).to_f,
)

model.train!('data/mnist_train.csv',
  limit:  (ENV['LIMIT']  || 100).to_i,
  epochs: (ENV['EPOCHS'] || 1).to_i,
)

score = model.validate('data/mnist_test_10.csv')
puts '%.1f%%' % (score * 100.0)

#model.save('data/mnist_nn.yaml') unless ENV['SAVE'].nil?
