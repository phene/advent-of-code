#!/usr/bin/env ruby

require 'matrix'
V = Vector
SOURCE = V[500,0]
DIRECTIONS = [V[0,1], V[-1,1], V[1,1]]

paths = []
$stdin.readlines.each do |line|
  paths << line.chomp.split(' -> ').map { V[*_1.split(',').map(&:to_i)] }
end

rocks = Set[]
paths.each do |path|
  path.each_cons(2) do |src, dest|
    d = V[*(dest-src).to_a.map { _1.clamp(-1, 1) }]
    until src == dest
      rocks << src
      src += d
    end
    rocks << dest
  end
end

def draw(rocks, grains, draw_floor = false)
  objects = rocks + grains
  min_x, max_x = objects.map { _1[0] }.minmax
  min_y, max_y = [0, objects.map { _1[1] }.max]
  if draw_floor
    floor_y = rocks.map { _1[1] }.max + 2
  else
    floor_y = -1
  end

  (min_y..(max_y+2)).each do |y|
    ((min_x-2)..(max_x+2)).each do |x|
      v = V[x,y]
      if floor_y == y || rocks.include?(v)
        print '#'
      elsif grains.include? v
        print 'o'
      elsif v == SOURCE
        print '+'
      else
        print '.'
      end
    end
    puts
  end
  puts
end

def drop_sand(rocks, grains, max_y, land_on_floor = false)
  grain = SOURCE
  loop do
    if grain[1] == max_y
      break if land_on_floor
      return false
    end
    break unless DIRECTIONS.any? do |dir|
      new_pos = grain + dir
      next false if rocks.include?(new_pos) or grains.include?(new_pos)
      grain = new_pos
      true
    end
  end
  grains << grain
  return grain != SOURCE
end

[false, true].each do |fall_on_floor|
  grains = Set[]
  max_y = rocks.map { |v| v[1] }.max + 1
  (1..).each do |i|
    break unless drop_sand(rocks, grains, max_y, fall_on_floor)
  end
  puts grains.size
end
