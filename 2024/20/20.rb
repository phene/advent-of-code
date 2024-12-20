#!/usr/bin/env ruby

require 'matrix'
V = Vector

DIRECTIONS = [V[0, -1], V[1, 0], V[0, 1], V[-1, 0]].freeze

def get_cell(grid, p) = grid[p[1]][p[0]]

def start_and_finish(grid)
  start, finish = [nil, nil]
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      start = V[x,y] if cell == 'S'
      finish = V[x,y] if cell == 'E'
    end
  end
  [start, finish]
end

def calculate_distances(grid, start)
  distances = Hash.new(Float::INFINITY)
  positions = [[start, 0]]

  while positions.any?
    position, dist = positions.shift
    next if distances[position] < dist
    distances[position] = dist
    DIRECTIONS.each do |d|
      np = position + d
      next unless X.include? np[0] and Y.include? np[1]
      positions << [np, dist+1] if get_cell(grid, np) != '#'
    end
  end

  distances
end

grid = File.read('input.txt').each_line.map { |line| line.chomp.chars }
X, Y = [(0...grid[0].size), (0...grid.size)]

start, finish = start_and_finish(grid)
start_costs = calculate_distances(grid, start)
finish_costs = calculate_distances(grid, finish)

[2, 20].each do |cheat_dist|
  cheats = Hash.new(0)
  start_costs.each do |s, sc|
    ((s[0]-cheat_dist)..(s[0]+cheat_dist)).each do |x|
      dy = cheat_dist - (s[0]-x).abs # Limit distance range on y based on x
      ((s[1]-dy)..(s[1]+dy)).each do |y|
        f = V[x,y]
        distance = (s - f).to_a.map(&:abs).sum
        cost = sc + finish_costs[f] + distance
        benefit = finish_costs[start] - cost
        cheats[[s, f]] = benefit if benefit > 0
      end
    end
  end
  puts cheats.each_value.count { _1 >= 100 }
end
