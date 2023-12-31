#!/usr/bin/env ruby

def emptiness(space)
  [space.transpose, space].map do |s|
    s.each_with_index.map do |row, d|
      d if row.all? { |c| c == '.' }
    end.compact
  end
end

def dist(g1, g2, empty_x, empty_y, expanse_multiplier)
  x1, x2 = [g1[0], g2[0]].sort
  y1, y2 = [g1[1], g2[1]].sort
  xex = (empty_x & (x1..x2).to_a).size
  yex = (empty_y & (y1..y2).to_a).size

  (x2 - x1 - xex) + (xex * expanse_multiplier) + (y2 - y1 - yex) + (yex * expanse_multiplier)
end

def find_galaxy_coords(space)
  [].tap do |galaxy_coords|
    space.each_with_index do |row, y|
      row.each_with_index do |c, x|
        galaxy_coords << [x, y] if c == '#'
      end
    end
  end
end

space = $stdin.readlines.map { |l| l.chomp.chars }
empty_x, empty_y = emptiness(space)
galaxy_pairs = find_galaxy_coords(space).combination(2)

part1_sum = galaxy_pairs.inject(0) do |sum, (g1, g2)|
  sum + dist(g1, g2, empty_x, empty_y, 2)
end
puts part1_sum

part2_sum = galaxy_pairs.inject(0) do |sum, (g1, g2)|
  sum + dist(g1, g2, empty_x, empty_y, 1_000_000)
end
puts part2_sum
