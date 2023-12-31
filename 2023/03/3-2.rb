#!/usr/bin/env ruby


def search_parts(part_coords, x_range, y_range)
  parts = []
  y_range.each do |y|
    x_range.each do |x|
      part = part_coords[[x, y]]
      parts << [part, [x, y]]
    end
  end
  parts
end

part_coords = {}
schematic = []

$stdin.readlines.each_with_index do |line, y|
  line = line.strip
  next if line.empty?
  schematic << line
  line.each_char.each_with_index do |chr, x|
    next if chr.match?(/[\d.]/)
    part_coords[[x, y]] = chr
  end
end

gears_found = Hash.new { |h, k| h[k] = [] }

schematic.each_with_index do |line, y|
  part_numbers = line.scan(/\d+/)

  last_x_index = 0

  part_numbers.each do |part_number|
    x0 = line.index(part_number, last_x_index)
    x1 = (x0 + part_number.size)
    last_x_index = x1

    parts = search_parts(part_coords, (x0 - 1)..x1, (y - 1)..(y + 1))

    parts.each do |part, coords|
      next unless part == '*'
      gears_found[coords] << part_number.to_i
    end
  end
end

sum = 0
gears_found.each do |_, part_numbers|
  next if part_numbers.size < 2
  sum += part_numbers.inject(1, &:*)
end
puts sum
