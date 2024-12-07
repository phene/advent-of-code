#!/usr/bin/env ruby

grid = []
$stdin.readlines.each do |line|
  grid << line.strip.chars
end

OBSTACLE = '#'
STARTING_POSITION = '^'
EMPTY = '.'

def off_map?(grid, x, y)
  return true if x < 0 or x >= grid[0].size
  return true if y < 0 or y >= grid.size
  false
end

def rotate(dx, dy)
  case [dx, dy]
  when [-1, 0]
    [0, -1]
  when [0, -1]
    [1, 0]
  when [1, 0]
    [0, 1]
  else
    [-1, 0]
  end
end

def step(grid, x, y, dx, dy)
  return nil if off_map?(grid, x + dx, y + dy)
  dx, dy = rotate(dx, dy) while grid[y + dy][x + dx] == OBSTACLE
  [[x + dx, y + dy], [dx, dy]]
end

def start_position(grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      return [[x, y], [0, -1]] if cell == STARTING_POSITION
    end
  end
  nil
end

def traverse(grid) # returns positions and if guard exited
  visited_positions = Set.new
  visited = Set.new
  (x, y), (dx, dy) = start_position(grid)
  visited_positions << [x, y]
  visited << [x, y, dx, dy]
  while pos = step(grid, x, y, dx, dy)
    (x, y), (dx, dy) = pos
    return [visited_positions, false] if visited.include? [x, y, dx, dy]
    visited_positions << [x, y]
    visited << [x, y, dx, dy]
  end
  [visited_positions, true]
end

def with_obstacle(grid, x, y)
  grid[y][x] = OBSTACLE
  yield grid
ensure
  grid[y][x] = EMPTY
end

def place_obsticles_and_find_loops(grid, visited)
  loop_count = 0
  (x0, y0), _ = start_position(grid)
  visited.delete([x0, y0]) # Excluding starting position
  visited.each do |(x, y)|
    with_obstacle(grid, x, y) do |grid|
      _, exited = traverse(grid)
      loop_count = loop_count.succ unless exited
    end
  end
  loop_count
end

original_visited, _ = traverse(grid)
puts original_visited.size

loop_count = place_obsticles_and_find_loops(grid, original_visited)
puts loop_count
