# This is free and unencumbered software released into the public domain.

module MNIST
  ROWS   = 28
  COLS   = 28
  PIXELS = ROWS * COLS
  SHAPE  = [ROWS, COLS].freeze
end # MNIST

require 'mnist/parser'
require 'mnist/model'
