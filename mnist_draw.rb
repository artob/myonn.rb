#!/usr/bin/env ruby -Ilib
# This is free and unencumbered software released into the public domain.

require 'myonn'
require 'mnist'
require 'ruby2d' # See: https://www.ruby2d.com

# Constants
MNIST_MODEL = MNIST::Model.load('data/mnist_nn.yaml')
PIXEL_SIZE  = 24
FONT_SIZE   = 336

# Globals
$drawing = false
$pixels  = Numo::DFloat.zeros(MNIST::SHAPE)

# Window
set title: "Digit Recognizer"
set background: 'white'
set width: MNIST::COLS * PIXEL_SIZE, height: MNIST::ROWS * PIXEL_SIZE # 672x672

def reset
  $drawing = false
  $pixels = Numo::DFloat.zeros(MNIST::SHAPE)
end

def render_digit(pixels)
  clear
  MNIST::ROWS.times.map.with_index do |y|
    MNIST::COLS.times.map.with_index do |x|
      pixel = pixels[y, x]
      next if pixel.zero?
      value = 1.0 - (pixel / 255.0)
      color = Color.new([value, value, value, 1.0])
      Square.new(x: x * PIXEL_SIZE, y: y * PIXEL_SIZE, size: PIXEL_SIZE, color: color)
    end
  end
end

def render_label(label)
  clear
  Text.new(label.to_s,
    x: (Window.width  - FONT_SIZE) / 2.0 + FONT_SIZE * 0.25,
    y: (Window.height - FONT_SIZE) / 2.0,
    size: FONT_SIZE,
    color: 'black',
  )
end

on :key_up do |event|
  case event.key.to_sym
    when :escape then close
    when :space
      if $pixels
        output = MNIST_MODEL.query($pixels).reshape!(10).to_a
        puts output.map.with_index { |score, index| "%d=%.1f%%" % [index, score * 100] }.join("  ")
        digit = MNIST_MODEL.recognize($pixels)
        render_label(digit)
        $pixels = nil
      else
        reset
        clear
      end
  end
end

on :mouse_down do |event|
  case event.button.to_sym
    when :left then $drawing = true
  end
end

on :mouse_up do |event|
  case event.button.to_sym
    when :left then $drawing = false
  end
end

on :mouse_move do |event|
  if $drawing && $pixels
    x, y = event.x / PIXEL_SIZE, event.y / PIXEL_SIZE
    $pixels[y, x] = 255
    render_digit($pixels)
  end
end

reset

show
