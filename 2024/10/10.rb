#!/usr/bin/env ruby

DELTAS = [[0, -1], [0, 1], [-1, 0], [1, 0]].freeze

def find_trailheads(grid)
  trailheads = []
  grid.each_with_index do |row, y|
    row.each_with_index do |height, x|
      trailheads << [x, y] if height == 0
    end
  end
  trailheads
end

def max_trails(grid, trailhead, unique_paths = false)
  trails = 0
  visited = Set.new
  paths = [trailhead]
  x_range, y_range = [0...grid[0].size, 0...grid.size]

  while paths.any?
    x, y = paths.shift
    next if !unique_paths and visited.include? [x, y]
    visited << [x, y]
    height = grid[y][x]

    if height == 9
      trails += 1
      next
    end

    DELTAS.each do |dx, dy|
      nx, ny = [x + dx, y + dy]
      paths << [nx, ny] if x_range.include?(nx) and y_range.include?(ny) and grid[ny][nx] == height + 1
    end
  end

  trails
end

grid = []
$stdin.readlines.each_with_index do |line|
  grid << line.chomp.chars.map(&:to_i)
end

total1, total2 = [0, 0]

find_trailheads(grid).each do |trailhead|
  total1 += max_trails(grid, trailhead, false)
  total2 += max_trails(grid, trailhead, true)
end

puts total1, total2
