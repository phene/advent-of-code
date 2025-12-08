#!/usr/bin/env ruby

SPLITTER = '^'
grid = []

$stdin.readlines.each do |line|
  line.chomp!
  grid << line.chars
end

start_x = grid.first.index('S')
split_count = 0
beam_positions = [[[start_x, 1]]]

(1...grid.size).each do |y|
  row = grid[y]
  new_beam_positions = beam_positions.last.map do |x, c|
    if row[x] == SPLITTER
      split_count += 1
      [[x-1, c], [x+1, c]]
    else
      [[x, c]]
    end
  end.flatten(1).group_by(&:first).map do |x, arr|
    # Sum path counts reaching x
    [x, arr.map(&:last).sum]
  end

  beam_positions << new_beam_positions
end

puts split_count
puts beam_positions.last.map(&:last).sum
