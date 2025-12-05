#!/usr/bin/env ruby
require 'matrix'
require_relative '../../range'
V = Vector

def sensors_that_intersect_y(sensors_radii, y)
  sensors_radii.select do |sensor, radii|
    ((sensor[1] - radii)..(sensor[1] + radii)).cover? y
  end.to_h do |sensor, radii|
    dx = radii - (sensor[1] - y).abs
    [sensor, (sensor[0]-dx)..(sensor[0]+dx)]
  end
end

sensor_beacon_pairs = $stdin.readlines.map { _1.scan(/-?\d+/).map(&:to_i).each_slice(2).map { |x, y| V[x,y] } }

sensors_radii = []
beacons = []

sensor_beacon_pairs.each do |sensor, beacon|
  radii = (sensor - beacon).to_a.map(&:abs).sum
  sensors_radii << [sensor, radii]
  beacons << beacon
end
sensors_radii.sort_by! { |s, _| s[0] }

# Part 1
sensors = sensors_that_intersect_y(sensors_radii, 2000000)
ranges = Range.merge_ranges(sensors.values)
puts ranges.map { |r| r.max - r.min }.sum

# Part 2
XY_MAX = 4000000
(0..XY_MAX).each do |y|
  sensors = sensors_that_intersect_y(sensors_radii, y)
  ranges = merge_ranges(sensors.values).map { |r| [r.min, 0].max..[r.max, XY_MAX].min }

  if ranges.size > 1
    x = ranges.sort_by(&:min).first.max + 1
    puts y + XY_MAX * x
    break
  end
end
