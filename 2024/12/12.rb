#!/usr/bin/env ruby

require 'matrix'
V = Vector

DIRECTIONS = [V[0, -1], V[1, 0], V[0, 1], V[-1, 0]].freeze

def fill_region(grid, start, points_to_regions, region)
  x_range, y_range = [0...grid[0].size, 0...grid.size]
  positions = [start]
  plant = grid[start[1]][start[0]]
  while positions.any?
    p = positions.shift
    next if points_to_regions[p]
    points_to_regions[p] = region
    DIRECTIONS.each do |d|
      np = p + d
      next unless x_range.include? np[0] and y_range.include? np[1]
      positions << np if grid[np[1]][np[0]] == plant
    end
  end
end

def find_regions(grid)
  x_range, y_range = [0...grid[0].size, 0...grid.size]
  points_to_regions = {}
  region = 1
  x_range.each do |x|
    y_range.each do |y|
      v = V[x,y]
      next if points_to_regions[v]
      fill_region(grid, v, points_to_regions, region)
      region = region.succ
    end
  end
  regions_to_points = Hash.new { |h,k| h[k] = [] }
  points_to_regions.each do |p, r|
    regions_to_points[r] << p
  end
  regions_to_points
end

def fetch_perimeter_and_area(regions_to_points)
  regions_to_points.transform_values do |ps|
    ps_set = ps.to_set
    perimeter = 0
    ps.each do |p|
      DIRECTIONS.each do |d|
        perimeter = perimeter.succ unless ps_set.include?(p + d)
      end
    end
    [perimeter, ps.size]
  end
end

def fetch_sides_and_area(regions_to_points)
  regions_to_points.transform_values do |ps|
    # Walk all edges until you reach every corner
    [ps.inject(Set.new) do |corners, p|
      DIRECTIONS.each do |d|
        next if ps.include?(p + d) # not an edge side
        step = p
        dv = V[d[1], -d[0]] # rotate counter-clockwise
        # walk until you reach a corner
        step += dv while ps.include?(step + dv) && !ps.include?(step + d + dv)
        corners << [step, d]
      end
      corners
    end.size, ps.size]
  end
end

grid = []
$stdin.readlines.each_with_index do |line|
  grid << line.chomp.chars
end

regions_to_points = find_regions(grid)
part1 = fetch_perimeter_and_area(regions_to_points).inject(0) do |sum, (_r, (p, a))|
  sum + p * a
end
puts part1

part2 = fetch_sides_and_area(regions_to_points).inject(0) do |sum, (_r, (s, a))|
  sum + s * a
end
puts part2
