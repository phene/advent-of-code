#!/usr/bin/env ruby

require 'matrix'
V = Vector

#BOUNDS = [11, 7] # example
BOUNDS = [101, 103] # actual
DIRECTIONS = [V[0, -1], V[1, 0], V[0, 1], V[-1, 0]].freeze

def mod(p)
  V[*(0..1).map { p[_1] % BOUNDS[_1] }]
end

def quadrant(p)
  return 0 if p[0] == BOUNDS[0] / 2 or p[1] == BOUNDS[1] / 2
  if p[0] < BOUNDS[0] / 2
    p[1] < BOUNDS[1] / 2 ? 1 : 2
  else
    p[1] < BOUNDS[1] / 2 ? 3 : 4
  end
end

def draw(points)
  grid = (0...BOUNDS[1]).map { ['.'] * BOUNDS[0] }
  points.each { |p| grid[p[1]][p[0]] = '#' }
  grid.each { |row| puts row.join('') }
end

def large_group?(points)
  points = points.to_set
  points.each do |point|
    visited = Set[]
    positions = [point]
    while pos = positions.shift
      next if visited.include?(pos)
      visited << pos
      DIRECTIONS.each do |d|
        positions << (pos+d) if points.include?(pos + d)
      end
    end
    return true if visited.size > points.size / 4
  end
  false
end

def part1(robots)
  quadrants = Hash.new(0)
  robots.each do |p0, v|
    quadrants[quadrant(mod(p0 + v * 100))] += 1
  end
  (1..4).inject(1) do |f, q|
    f * quadrants[q]
  end
end

def part2(robots)
  (1..).each do |t|
    points = robots.map do |p0, v|
      mod(p0 + v * t)
    end.to_set
    if large_group?(points)
      draw(points)
      return t
    end
  end
end

robots = []
$stdin.readlines.each_with_index do |line|
  next unless m = line.match(/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/)
  robots << [V[m[1].to_i, m[2].to_i], V[m[3].to_i, m[4].to_i]]
end

puts part1(robots)
puts part2(robots)
