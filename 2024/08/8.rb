#!/usr/bin/env ruby

def antenna_positions(grid)
  antennas = Hash.new { |h, k| h[k] = [] }
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      antennas[cell] << [x, y] if cell != '.'
    end
  end
  antennas
end

def find_antinodes(antennas, x_range, y_range, resonants = (1..1))
  antinodes = Set.new
  antennas.each do |_, locations|
    locations.combination(2) do |(x1, y1), (x2, y2)|
      resonants.each do |resonant|
        a1x = x1 + resonant * (x1 - x2)
        a1y = y1 + resonant * (y1 - y2)
        break unless x_range.include?(a1x) and y_range.include?(a1y)
        antinodes << [a1x, a1y]
      end

      resonants.each do |resonant|
        a2x = x2 + resonant * (x2 - x1)
        a2y = y2 + resonant * (y2 - y1)
        break unless x_range.include?(a2x) and y_range.include?(a2y)
        antinodes << [a2x, a2y]
      end
    end
  end
  antinodes
end

grid = []
$stdin.readlines.each do |line|
  grid << line.strip.chars
end

antennas = antenna_positions(grid)

antinodes = find_antinodes(antennas, 0...grid[0].size, 0...grid.size, 1..1)
puts antinodes.size

antinodes = find_antinodes(antennas, 0...grid[0].size, 0...grid.size, 0..)
puts antinodes.size
