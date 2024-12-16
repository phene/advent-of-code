#!/usr/bin/env ruby

require 'matrix'
V = Vector

def cw(v) = V[v[1], -v[0]]
def ccw(v) = V[-v[1], v[0]]
def get_cell(grid, p) = grid[p[1]][p[0]]

def start_and_end(grid)
  s, e = [nil, nil]
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      s = V[x,y] if cell == 'S'
      e = V[x,y] if cell == 'E'
    end
  end
  [s, e]
end

def traverse(grid)
  s, e = start_and_end(grid)
  queue = [
    [s, V[1,0], 0, []], # Start position right
    [s, V[0,-1], 1000, []] # Start position up, incurs ccw rotation cost
  ]
  visited = Hash.new(Float::INFINITY)
  paths = []
  while queue.any?
    p, d, score, path = queue.shift
    next if visited[[p,d]] < score
    next if get_cell(grid, p) == '#'
    path += [p]
    if p == e
      paths << [path, score]
      next
    end
    visited[[p,d]] = score

    [[d, 1], [cw(d), 1001], [ccw(d), 1001]].each do |nd, ds|
      queue << [p + nd, nd, score + ds, path]
    end
  end

  paths
end

grid = $stdin.readlines.map(&:chomp).map(&:chars)

paths = traverse(grid)
best_score = paths.map(&:last).min
puts best_score

best_paths = paths.select { _1.last == best_score }
points = best_paths.map(&:first).map(&:to_set).inject(&:+)
puts points.size
