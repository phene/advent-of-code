#!/usr/bin/env ruby
require 'matrix'

# V = Vector
# class Vector
#   def x = self[0]
#   def y = self[1]
# end
SPLITTER = '^'

grid = []

$stdin.readlines.each do |line|
  line.chomp!
  grid << line.chars
end

start_x = grid.first.index('S')

split_count = 0
uniq_paths = 1
beam_positions_1, beam_positions_2 = [[[start_x]], [[[start_x, 1]]]]

(1...grid.size).each do |y|
  row = grid[y]
  new_beam_positions_1 = beam_positions_1.last.flat_map do |x|
    if row[x] == SPLITTER
      split_count += 1
      [x-1, x+1]
    else
      [x]
    end
  end.uniq
  beam_positions_1 << new_beam_positions_1

  new_beam_positions_2 = beam_positions_2.last.map do |x, c|
    if row[x] == SPLITTER
      uniq_paths
      [[x-1, c], [x+1, c]]
    else
      [[x, c]]
    end
  end.flatten(1).group_by(&:first).map do |x, arr|
    [x, arr.map(&:last).sum]
  end

  beam_positions_2 << new_beam_positions_2
end

puts split_count
puts beam_positions_2.last.map(&:last).sum

