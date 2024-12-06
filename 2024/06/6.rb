#!/usr/bin/env ruby

grid = []
$stdin.readlines.each do |line|
  grid << line.strip.chars
end

OBSTACLE = '#'
STARTING_POSITION = '^'

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

def create_obstacle(grid, ox, oy)
  grid.each_with_index.map do |row, y|
    row.dup.tap do |newRow|
      newRow[ox] = OBSTACLE if y == oy
    end
  end
end

def place_obsticles_and_find_loops(grid, visited)
  loop_obstacles = []
  (x0, y0), _ = start_position(grid)
  visited.delete([x0, y0]) # Excluding starting position
  visited.each do |(x, y)|
    _, exited = traverse(create_obstacle(grid, x, y))
    loop_obstacles << [x, y] unless exited
  end
  loop_obstacles
end

original_visited, _ = traverse(grid)
puts original_visited.size

loop_obstacles = place_obsticles_and_find_loops(grid, original_visited)
puts loop_obstacles.size
