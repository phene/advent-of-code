#!/usr/bin/env ruby

require 'pairing_heap'

grid = []
$stdin.readlines.lazy.map(&:chomp).each do |line|
  grid << line.chars.map(&:to_i)
end

NEIGHBORS = [
  [1, 0],
  [-1, 0],
  [0, -1],
  [0, 1],
]

def fetch_neighbors(x, y, dx, dy, x_range, y_range, direction_range)
  NEIGHBORS.lazy.map do |ndx, ndy|
    [[x + ndx, y + ndy], [ndx, ndy]]
  end.select do |(nx, ny), (ndx, ndy)|
    next false unless x_range.include?(nx) and y_range.include?(ny)
    next false if dy * ndy < 0 or dx * ndx < 0 # Reject back-tracking
    if dy * ndy == 0 and dx * ndx == 0 # Changing directions
      next direction_range.include?(dx.abs + dy.abs) # Can only change direction if already travelled min distance
    end
    # Check for exceeding direction limit
    if ndx == 0
      (dy + ndy).abs <= direction_range.max
    else
      (dx + ndx).abs <= direction_range.max
    end
  end
end

PART1 = (1..3)
PART2 = (4..10)

def traverse(grid, start, direction_range)
  x_range = 0...grid.first.size
  y_range = 0...grid.size
  finish = [x_range.max, y_range.max]
  queue = PairingHeap::MinPriorityQueue.new
  queue.push([start, [1, 0], 0], 0)
  queue.push([start, [0, 1], 0], 0)
  visited = Hash.new(Float::INFINITY)

  while queue.any?
    (x, y), (dx, dy), distance = queue.pop #positions.shift

    next if visited[[x, y, dx, dy]] <= distance

    if [x, y] == finish
      next unless direction_range.include?(dx.abs + dy.abs)
      return distance
    end

    fetch_neighbors(x, y, dx, dy, x_range, y_range, direction_range).each do |(nx, ny), (ndx, ndy)|
      direction =
        if dx == 0 and ndx == 0
          [0, dy + ndy]
        elsif dy == 0 and ndy == 0
          [dx + ndx, 0]
        else
          [ndx, ndy]
        end
      d = distance + grid[ny][nx]
      item = [[nx, ny], direction, d]
      queue.push(item, d) unless queue.include? item
    end

    visited[[x, y, dx, dy]] = distance
  end

  0
end

puts traverse(grid, [0,0], PART1)
puts traverse(grid, [0,0], PART2)
