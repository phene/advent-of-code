#!/usr/bin/env ruby

require 'matrix'
require 'pairing_heap'

V = Vector
DIRECTIONS = [V[0, -1], V[1, 0], V[0, 1], V[-1, 0]].freeze

def in_bounds(grid, p) = (0...grid.size).include?(p[1]) && (0...grid[0].size).include?(p[0])
def get_cell(grid, p) = grid[p[1]][p[0]]
def update_cell(grid, p, val) = grid[p[1]][p[0]] = val

def find_start_finish(grid)
  start = finish = nil
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if cell == 'S'
        start = V[x,y]
        update_cell(grid, start, 'a')
      end
      if cell == 'E'
        finish = V[x,y]
        update_cell(grid, finish, 'z')
      end
    end
  end
  [start, finish]
end

def find_fastest_path(grid, start, criteria)
  distances = grid.map { [Float::INFINITY] * _1.size }
  queue = PairingHeap::MinPriorityQueue.new
  queue.push [start, 0], 0
  while queue.any?
    pos, dist = queue.pop
    next if get_cell(distances, pos) < dist
    update_cell(distances, pos, dist)
    DIRECTIONS.each do |d|
      np = pos+d
      next unless in_bounds(grid, np) and criteria.call(grid, pos, np)
      next if get_cell(distances, np) < dist+1
      next if queue.include? [np, dist+1]
      queue.push [np, dist+1], dist+1
    end
  end
  distances
end

grid = $stdin.readlines.map { _1.chomp.chars }
start, finish = find_start_finish(grid)
distances = find_fastest_path(grid, start, ->(grid, p, np) { get_cell(grid, np).ord <= get_cell(grid, p).ord + 1})
puts get_cell(distances, finish)

distances = find_fastest_path(grid, finish, ->(grid, p, np) { get_cell(grid, p).ord <= get_cell(grid, np).ord + 1})
shortest = Float::INFINITY
grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    next unless cell == 'a'
    dist = get_cell(distances, V[x,y])
    shortest = dist if dist  < shortest
  end
end
puts shortest
