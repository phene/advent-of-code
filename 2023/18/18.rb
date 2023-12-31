#!/usr/bin/env ruby

part1_path = []
part2_path = []

NEIGHBORS = {
  'R' => [1, 0],
  'D' => [0, 1],
  'L' => [-1, 0],
  'U' => [0, -1],
}

$stdin.readlines.lazy.map(&:chomp).each do |line|
  direction, distance, color = line.split(' ')
  part1_path << [direction, distance.to_i]
  hex = color.tr('#()', '')
  distance, direction = hex[0..-2].to_i(16), NEIGHBORS.keys[hex[-1].to_i]
  part2_path << [direction, distance]
end

def print_grid(grid)
  grid.each do |row|
    puts row.join('')
  end
  puts
end

def find_vertices(path)
  x, y = [0, 0]
  vertices = [[x, y]]
  path.each do |dir, dist|
    x, y = [x, y].zip(NEIGHBORS[dir].map { |d| d * dist }).map(&:sum)
    vertices << [x, y]
  end
  vertices
end

def area(vertices, path)
  sum = vertices.each_cons(2).sum do |(v1_x, v1_y), (v2_x, v2_y)|
    v1_x * v2_y - v1_y * v2_x
  end + (vertices.last.first * vertices.first.last - vertices.last.last * vertices.first.first)
  (sum.abs + path.sum { _2 }) / 2 + 1 # The perimeter needs to be added to the sum, but I am not actually sure where the +1 comes from
end

puts area(find_vertices(part1_path), part1_path)
puts area(find_vertices(part2_path), part2_path)

# def build_grid(path)
#   x, min_x, max_x = [0, 0, 0]
#   y, min_y, max_y = [0, 0, 0]
#   path.each do |dir, dist|
#     x, y = [x, y].zip(NEIGHBORS[dir].map { |d| d * dist }).map(&:sum)
#     min_x = x if x < min_x
#     min_y = y if y < min_y
#     max_x = x if x > max_x
#     max_y = y if y > max_y
#   end

#   [(min_y..max_y).map { ['.'] * (max_x - min_x + 1) }, [-min_x, -min_y]]
# end

# def trace_path(path, grid, start)
#   pos = start
#   grid[pos.last][pos.first] = '#'

#   path.each do |dir, dist|
#     dist.times do
#       pos = pos.zip(NEIGHBORS[dir]).map(&:sum)
#       raise "pos went negative!" if pos.any?(&:negative?)
#       grid[pos.last][pos.first] = '#'
#     end
#   end

#   grid
# end

# def flood_fill(grid, *start)
#   positions = [start]
#   visited = {}
#   y_range, x_range = 0...grid.size, 0...grid.first.size
#   y_edge, x_edge = [0, y_range.max], [0, x_range.max]
#   fill_value = '#' # Defualt to marking whole fill as interior until we find an edge
#   while positions.any?
#     pos = positions.shift
#     x, y = pos
#     next if visited[pos]
#     fill_value = ',' if x_edge.include?(x) or y_edge.include?(y) # Hit an edge, so must be outside
#     NEIGHBORS.each_value do |dx, dy|
#       x1, y1 = x + dx, y + dy
#       positions << [x1, y1] if x_range.include?(x1) and y_range.include?(y1) and grid[y1][x1] == '.'
#     end
#     visited[pos] = true
#   end
#   visited.each_key do |x, y|
#     grid[y][x] = fill_value
#   end
#   visited.keys
# end

# def hole_size(grid)
#   (0...grid.size).each do |y|
#     (0...grid.first.size).each do |x|
#       next unless grid[y][x] == '.'
#       flood_fill(grid, x, y)
#     end
#   end

#   grid.sum do |row|
#     row.count { |c| c == '#' }
#   end
# end

# # Part 1
# grid, start = build_grid(part1_path)
# #print_grid(grid)
# grid = trace_path(part1_path, grid, start)
# #print_grid(grid)
# puts hole_size(grid)

# grid, start = build_grid(part2_path)
# #print_grid(grid)
# grid = trace_path(part2_path, grid, start)
# #print_grid(grid)
# puts hole_size(grid)
