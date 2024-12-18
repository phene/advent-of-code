#!/usr/bin/env ruby

require 'matrix'
V = Vector

DIRECTIONS = [V[0, -1], V[1, 0], V[0, 1], V[-1, 0]].freeze
X, Y = [(0..70), (0..70)]

def find_path(falling_bytes)
  start, ending = [V[X.min,Y.min], V[X.max,Y.max]]
  positions = [[start, []]]
  visited = Set.new
  fallen = falling_bytes.to_set

  while positions.any?
    position, path = positions.shift

    return path + [position] if position == ending
    next if visited.include? position
    visited << position

    DIRECTIONS.each do |d|
      np = position + d
      next unless X.include? np[0]
      next unless Y.include? np[1]
      positions << [np, path + [position]] unless fallen.include? np
    end
  end
  []
end

positions = $stdin.readlines.map { V[*_1.split(',').map(&:to_i)] }

path = find_path(positions[0...1024])
puts path.size - 1

broken_path_byte = (0...positions.size).bsearch do |i|
  find_path(positions[0..i]).size == 0
end
puts positions[broken_path_byte].to_a.map(&:to_s).join(',')
