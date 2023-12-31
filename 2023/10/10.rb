#!/usr/bin/env ruby

ALL_PATHS_OUT = [[-1, 0], [1, 0], [0, 1], [0, -1]]
CHARS_TO_PATHS = {
  '-' => [[-1, 0], [1, 0]],
  '|' => [[0, -1], [0, 1]],
  'J' => [[-1, 0], [0, -1]],
  'L' => [[0, -1], [1, 0]],
  'F' => [[0, 1], [1, 0]],
  '7' => [[-1, 0], [0, 1]],
  '.' => [],
  'S' => ALL_PATHS_OUT,
}

def read_grid(io)
  start = nil
  grid = []
  io.readlines.each_with_index do |line, idx|
    row = line.chomp.chars
    start = [row.index('S') , idx] if line.include? 'S'
    grid << row.map { |c| CHARS_TO_PATHS[c].dup }
  end
  [grid, start]
end

# Eliminate cell paths with dead-ends
def prune_bad_paths(grid)
  y_range, x_range = 0...grid.size, 0...grid.first.size
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      cell.select! do |dx, dy|
        x1, y1 = x + dx, y + dy
        next false unless y_range.include?(y1) and x_range.include?(x1)
        cells_connected?(grid, x, y, x1, y1)
      end
    end
  end
end

# Identify and remove broken pipes
def remove_broken_pipes(grid, pipe_circuit)
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      next if pipe_circuit[[x, y]]
      next if cell.empty?
      row[x] = []
    end
  end
end

def cells_connected?(grid, x1, y1, x2, y2)
  return false if x1 < 0 || x2 < 0 || y1 < 0 || y2 < 0
  return false unless grid[y1][x1].any? { |dx, dy| x1 + dx == x2 and y1 + dy == y2 }
  grid[y2][x2].any? { |dx, dy| x2 + dx == x1 and y2 + dy == y1 }
end

# Walk from Start through entire pipe
def walk_pipeline(grid, start)
  visited = {}
  positions = [[start, 0]]
  y_range, x_range = 0...grid.size, 0...grid.first.size
  while positions.any?
    begin
      pos, dist = positions.shift
      x, y = pos
      next if visited[pos]
      next unless y_range.include?(y) and x_range.include?(x)
      any_positions = grid[y][x].each { |dx, dy| positions << [[x + dx, y + dy], dist + 1] }
      visited[pos] = dist if any_positions.any?
    end
  end
  visited
end

# Grow a row, ensuring connections are preserved
def expand_row(grid, row, y)
  new_row = [row[0]]
  row.each_cons(2).each_with_index do |(c1, c3), x|
    new_row << (cells_connected?(grid, x, y, x + 1, y) ? CHARS_TO_PATHS['-'] : [])
    new_row << c3
  end
  new_row
end

def expand_grid(grid)
  double_grid = [expand_row(grid, grid[0], 0)]
  grid.each_cons(2).each_with_index do |(row1, row3), y|
    row2 = (0...row1.size).map do |x|
      cells_connected?(grid, x, y, x, y + 1) ? CHARS_TO_PATHS['|'] : []
    end
    double_grid << expand_row(grid, row2, -2)
    double_grid << expand_row(grid, row3, y + 1)
  end
  double_grid
end

def flood_fill(grid, *start)
  positions = [start]
  visited = {}
  y_range, x_range = 0...grid.size, 0...grid.first.size
  y_edge, x_edge = [0, y_range.max], [0, x_range.max]
  fill_value = 'I' # Defualt to marking whole fill as interior until we find an edge
  while positions.any?
    pos = positions.shift
    x, y = pos
    next if visited[pos]
    fill_value = 'O' if x_edge.include?(x) or y_edge.include?(y) # Hit an edge, so must be outside
    ALL_PATHS_OUT.each do |dx, dy|
      x1, y1 = x + dx, y + dy
      positions << [x1, y1] if x_range.include?(x1) and y_range.include?(y1) and grid[y1][x1] == []
    end
    visited[pos] = true
  end
  visited.each_key do |x, y|
    grid[y][x] = fill_value
  end
  visited.keys
end

def fetch_empty_cells(grid)
  [].tap do |empty_cells|
    grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        empty_cells << [x, y] if cell.empty?
      end
    end
  end
end

def count_inside_cells(double_grid, empty_cells)
  inside_count = 0
  empty_cells.each do |x, y|
    next unless x % 2 == 0 and y % 2 == 0 # Cells with odd coordinates are fill from doubling, so ignore
    inside_count += 1 if double_grid[y][x] == 'I'
  end
  inside_count
end

grid, start = read_grid($stdin)
prune_bad_paths(grid) # Particularly needed to determine which kind of pipe is actually at S
pipe_circuit = walk_pipeline(grid, start)
puts pipe_circuit.values.max # Part 1

remove_broken_pipes(grid, pipe_circuit)
double_grid = expand_grid(grid)
empty_cells = fetch_empty_cells(double_grid).each do |x, y|
  flood_fill(double_grid, x, y) if double_grid[y][x] == []
end
puts count_inside_cells(double_grid, empty_cells) # Part 2
