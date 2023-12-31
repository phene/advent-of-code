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
