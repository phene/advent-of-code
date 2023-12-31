#!/usr/bin/env ruby

DIRECTIONS = $stdin.readline.strip.chars
$stdin.readline # Burn empty line
MAP = $stdin.readlines.map do |line|
  node, left, right = line.match(/(\w+) = \((\w+), (\w+)\)/).captures
  [node, { 'L' => left, 'R' => right }]
end.to_h

# Part 1
node = 'AAA'
steps = DIRECTIONS.size * (1..).find do
  node = DIRECTIONS.inject(node) { MAP[_1][_2] }
  next true if node == 'ZZZ'
end
puts steps

# Part 2
# Paths are cyclic and actually navigating them all together takes _way_ too long
# Find steps per path and take LCM
nodes = MAP.keys.select { |k| k.end_with? 'A' }
steps = nodes.map do |node|
  DIRECTIONS.size * (1..).find do |tries|
    node = DIRECTIONS.inject(node) { MAP[_1][_2] }
    next true if node.end_with? 'Z'
  end
end.inject(1, &:lcm)
puts steps
