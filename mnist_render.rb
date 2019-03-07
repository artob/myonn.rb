#!/usr/bin/env ruby -Ilib
# This is free and unencumbered software released into the public domain.

require 'mnist'
require 'ruby2d' # See: https://www.ruby2d.com

# Constants
PIXEL_SIZE = 24
FONT_SIZE  = 336

# Globals
$current_index  = 0
$current_record = nil

# Window
set title: "Digit Renderer"
set background: 'white'
set width: MNIST::COLS * PIXEL_SIZE, height: MNIST::ROWS * PIXEL_SIZE # 672x672

def load_record(record_index)
  MNIST::Parser.open('data/mnist_train_100.csv') do |dataset|
    dataset.each_record.take(record_index + 1).last
  end
end

def render_digit
  _, pixels = $current_record
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

def render_label
  label, _ = $current_record
  clear
  Text.new(label.to_s,
    x: (Window.width  - FONT_SIZE) / 2.0 + FONT_SIZE * 0.25,
    y: (Window.height - FONT_SIZE) / 2.0,
    size: FONT_SIZE,
    color: 'black',
  )
end

on :key_up do |event|
  case k = event.key.to_sym
    when :escape then close
    when :up, :down, :left, :right
      $current_index += %i(down right).include?(k) ? 1 : -1
      $current_index = [0, $current_index].max
      $current_record = load_record($current_index)
      render_digit
    when :space
      render_label
  end
end

$current_record = load_record($current_index)
render_digit

show
