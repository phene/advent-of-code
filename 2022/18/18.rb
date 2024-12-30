#!/usr/bin/env ruby

require 'matrix'
V = Vector
DIRECTIONS = [V[0,0,1], V[0,0,-1], V[0,1,0], V[0,-1,0], V[1,0,0], V[-1,0,0]]

# DFS to find path out of x and y ranges
def path_out?(lava_drops, start, ranges)
  positions = [start]
  visited = Set[]
  while positions.any?
    pt = positions.pop
    return true unless ranges.each_with_index.all? { |r, i| r.cover?(pt[i]) }
    next if visited.include? pt
    visited << pt

    DIRECTIONS.each do |dir|
      new_pt = pt + dir
      positions << new_pt unless lava_drops.include? new_pt
    end
  end
  false
end

lava_drops = $stdin.readlines.map { V[*_1.split(',').map(&:to_i)] }.to_set
x_range = Range.new(*lava_drops.map { _1[0] }.minmax)
y_range = Range.new(*lava_drops.map { _1[1] }.minmax)
z_range = Range.new(*lava_drops.map { _1[2] }.minmax)

exposed_sides = lava_drops.sum do |lava|
  DIRECTIONS.count do |dir|
    !lava_drops.include?(lava+dir)
  end
end
puts exposed_sides

accessible_sides = lava_drops.sum do |lava|
  DIRECTIONS.count do |dir|
    side = lava+dir
    next false if lava_drops.include?(side)
    path_out?(lava_drops, side, [x_range, y_range, z_range])
  end
end
puts accessible_sides
