#!/usr/bin/env ruby
require 'pry'

MAPS = []

current_map = []
$stdin.readlines.lazy.map(&:chomp).each do |l|
  if l.empty?
    MAPS << current_map
    current_map = []
  else
    current_map << l.gsub('.', '0').gsub('#', '1').chars
  end
end

MAPS << current_map

def reflects?(current_map, row_index, diff = 0)
  first, second = current_map[0...row_index].reverse, current_map[row_index..]

  # Scale down to matching size
  if first.size < second.size
    second = second[0...first.size]
  else
    first = first[0...second.size]
  end

  diff_count = 0

  reflects = (0...first.size).all? do |i|
    next true if first[i] == second[i]
    values = [first[i], second[i]].sort
    return false unless values.first & values.last == values.first # Make sure bit difference doesn't trigger carry
    binary_diff = (values.last - values.first).to_s(2)
    count = binary_diff.chars.count { |c| c == '1' } # number of characters off
    if count + diff_count <= diff
      diff_count += count # keep track of how many differences
      true
    end
  end
  reflects and diff_count == diff
end

def binary_diff(a, b, diff = 1)
  a & b == a
end

def find_reflection(current_map, diff = 0)
  binary_map = current_map.map { |l| l.join('').to_i(2) }
  (1...binary_map.size).find do |idx|
    reflects?(binary_map, idx, diff)
  end || 0
end

sum = MAPS.each_with_index.map do |current_map, idx|
  row = find_reflection(current_map, 0)
  #puts "Found reflection on #{idx + 1} at row #{row}" if row > 0

  col = find_reflection(current_map.transpose, 0)
  #puts "Found reflection on #{idx + 1} at col #{col}" if col > 0
  row * 100 + col
end.sum
puts sum

sum = MAPS.each_with_index.map do |current_map, idx|
  row = find_reflection(current_map, 1)
  #puts "Found reflection on #{idx + 1} at row #{row}" if row > 0

  col = find_reflection(current_map.transpose, 1)
  #puts "Found reflection on #{idx + 1} at col #{col}" if col > 0
  row * 100 + col
end.sum
puts sum
