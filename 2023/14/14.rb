#!/usr/bin/env ruby

UNMOVABLE = '#'
MOVABLE = 'O'
EMPTY = '.'

def print_grid(grid)
  grid.each do |row|
    puts row.join('')
  end
  puts
end

def calculate_weight(grid)
  grid.each_with_index.map do |row, i|
    row.count { |c| c == MOVABLE } * (grid.size - i)
  end.sum
end

def roll(grid)
  new_grid = grid.map(&:dup)

  grid.each_with_index do |row, y|
    row.each_with_index do |chr, x|
      next unless chr == MOVABLE
      new_y = (y - 1).downto(0).find do |ny|
        new_grid[ny][x] != EMPTY
      end || -1 # Reached edge
      new_y += 1
      if new_y < y
        new_grid[new_y][x] = MOVABLE
        new_grid[y][x] = EMPTY
      end
    end
  end

  new_grid
end

def rotate_clockwise(grid)
  grid.transpose.map(&:reverse)
end

def cycle(grid)
  4.times do # north, west, south, east
    grid = roll(grid)
    grid = rotate_clockwise(grid)
  end
  grid
end

grid = []
$stdin.readlines.lazy.map(&:chomp).each do |line|
  grid << line.chars
end

ORIGINAL = grid.map(&:dup)

# Part 1
grid = roll(ORIGINAL)
puts calculate_weight(grid)

# Part 2
grid = ORIGINAL
CYCLE_COUNT = 1_000_000_000
history = [grid]
cycle_begin = 0

CYCLE_COUNT.times do |i|
  grid = cycle(grid)

  existing = history.index(grid)
  if existing
    cycle_begin = existing
    break
  end

  history << grid
end

# Find grid at CYCLE_COUNT based on cycle history
grid = history[cycle_begin + (CYCLE_COUNT - cycle_begin) % (history.size - cycle_begin)]
puts calculate_weight(grid)
