#!/usr/bin/env ruby

grid = []
start = nil

$stdin.readlines.lazy.map(&:chomp).map(&:chars).each_with_index do |row, y|
  grid << row
  x = row.index('S')
  start = [x, y] if x
end

NEIGHBORS = [
  [1, 0],
  [0, 1],
  [-1, 0],
  [0, -1],
]

def walk_part1(grid, start, steps = 64)
  results = {}
  positions = [[start, steps]]
  visited = {}
  x_range, y_range = 0...grid.first.size, 0...grid.size

  while positions.any?
    (x, y), s = positions.shift
    next if visited[[x, y, s]]
    visited[[x, y, s]] = true
    results[[x, y]] = true and next if s == 0

    NEIGHBORS.each do |(dx, dy)|
      nx, ny = x + dx, y + dy
      next unless x_range.cover? nx and y_range.cover? ny
      next if grid[ny][nx] == '#'
      positions << [[nx, ny], s - 1]
    end
  end
  results.size
end

def translate(val, range)
  pos = val.abs % (range.max + 1)
  return pos if val.positive? or val.zero?
  return pos if pos.zero?
  range.max - pos + 1
end

def walk_part2(grid, start, steps)
  results = Set.new
  positions = [[start, steps]]
  visited = Set.new
  x_range, y_range = 0...grid.first.size, 0...grid.size

  while positions.any?
    (x, y), s = positions.shift
    next if visited.include? [x, y, s]
    visited << [x, y, s]
    results << [x, y] and next if s == 0

    NEIGHBORS.each do |(dx, dy)|
      nx, ny = x + dx, y + dy
      tx, ty = translate(nx, x_range), translate(ny, y_range)
      next if grid[ty][tx] == '#'
      positions << [[nx, ny], s - 1]
    end
  end
  results.size
end

# Part 1
puts walk_part1(grid, start, 64)

# Part 2
target = 26_501_365

# Loops show up at x + (x_max * n)
p1 = walk_part2(grid, start, start.first)
p2 = walk_part2(grid, start, start.first + grid.size)
p3 = walk_part2(grid, start, start.first + grid.size * 2)

# Quadratic equation ~~
a = (p3 - (p2 * 2) + p1) / 2
b = p2 - p1 - a
c = p1
n = (target - start.first) / grid.size

puts (a * (n**2)) + (b * n) + c
