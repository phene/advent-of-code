#!/usr/bin/env ruby

sequence = $stdin.read.strip.split(',')

def hash_code(seq)
  val = 0
  seq.each_char.map(&:ord).each do |ascii_code|
    val += ascii_code
    val = (val * 17) % 256
  end
  val
end

# Part 1
hsh = sequence.sum do |seq|
  hash_code(seq)
end
puts hsh

# Part 2
boxes = Hash.new { |h, k| h[k] = {} }
sequence.each do |seq|
  if seq.include? '-'
    label = seq.split('-').first
    box = hash_code(label)
    boxes[box].delete(label)
  else # includes '='
    label, n = seq.split('=')
    box = hash_code(label)
    boxes[box][label] = n.to_i
  end
end

sum = 0
boxes.each do |box, lenses|
  lenses.each_with_index do |(label, focal), slot|
    sum += (box + 1) * focal * (slot + 1)
  end
end
puts sum
