#!/usr/bin/env ruby
require 'matrix'

EMPTY = '.'
PAPER = '@'
V = Vector
class Vector
  def x = self[0]
  def y = self[1]
end

ADJACENTS = [
  V[0, -1],
  V[0, 1],
  V[1, -1],
  V[1, 0],
  V[1, 1],
  V[-1, -1],
  V[-1, 0],
  V[-1, 1],
]

def dup_grid(grid)
  grid.dup.map(&:dup)
end

def movable?(grid, p)
  adjacents = ADJACENTS.count do |d|
    np = p + d
    next false unless (0...grid.size).include? np.y and (0...grid[0].size).include? np.x
    grid[np.y][np.x] == PAPER
  end
  adjacents < 4
end

def fetch_movable(grid)
  movable = []
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      next if cell == EMPTY
      p = V[x,y]
      movable << p if movable?(grid, p)
    end
  end
  movable
end

def clear_movable(grid, movable)
  grid = dup_grid(grid)
  movable.each do |p|
    grid[p.y][p.x] = EMPTY
  end
  grid
end

grid = []
$stdin.readlines.each do |line|
  grid << line.strip.chars
end

part1 = fetch_movable(grid).size
puts part1

part2 = 0
begin
  movable = fetch_movable(grid)
  part2 += movable.size
  grid = clear_movable(grid, movable)
end until movable.empty?
puts part2
