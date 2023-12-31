#!/usr/bin/env ruby

grid = []
$stdin.readlines.lazy.map(&:chomp).each do |line|
  grid << line.chars
end

def count_energized_positions(grid, start)
  energized_positions = {}
  visited = {}
  positions = [start]

  y_range = 0...grid.size
  x_range = 0...grid.first.size

  while positions.any?
    visit = positions.shift
    (px, py), (dx, dy) = visit
    x, y = px + dx, py + dy
    next unless x_range.include?(x) and y_range.include?(y) # Exited the grid
    next if visited[visit]
    visited[visit] = true
    energized_positions[[x, y]] = true

    case grid[y][x]
    when '.'
      positions << [[x, y], [dx, dy]]
    when '/'
      if dx == 0
        ndx = dy > 0 ? -1 : 1
        ndy = 0
      else
        ndx = 0
        ndy = dx > 0 ? -1 : 1
      end
      positions << [[x, y], [ndx, ndy]]
    when '\\'
      if dx == 0
        ndx = dy > 0 ? 1 : -1
        ndy = 0
      else
        ndx = 0
        ndy = dx > 0 ? 1 : -1
      end
      positions << [[x, y], [ndx, ndy]]
    when '-'
      if dx == 0
        positions << [[x, y], [-1, 0]]
        positions << [[x, y], [1, 0]]
      else
        positions << [[x, y], [dx, dy]]
      end
    when '|'
      if dy == 0
        positions << [[x, y], [0, -1]]
        positions << [[x, y], [0, 1]]
      else
        positions << [[x, y], [dx, dy]]
      end
    end
  end
  energized_positions.size
end

# Part 1
puts count_energized_positions(grid, [[-1, 0], [1, 0]])

# Part 2
most_energized = 0

# left and right edges
(0...grid.size).each do |y|
  most_energized = [
    most_energized,
    count_energized_positions(grid, [[-1, y], [1, 0]]),
    count_energized_positions(grid, [[grid.first.size, y], [-1, 0]]),
  ].max
end

# top and bottom edges
(0...grid.first.size).each do |x|
  most_energized = [
    most_energized,
    count_energized_positions(grid, [[x, -1], [0, 1]]),
    count_energized_positions(grid, [[x, grid.size], [0, -1]]),
  ].max
end

puts most_energized
