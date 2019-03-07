#!/usr/bin/env ruby -Ilib
# This is free and unencumbered software released into the public domain.

require 'myonn'
require 'mnist'

model = MNIST::Model.load('data/mnist_nn.yaml')

score = model.validate('data/mnist_test.csv')
puts '%.1f%%' % (score * 100.0)
