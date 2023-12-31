#!/usr/bin/env ruby

def is_part_number(part_coords, x_range, y_range)
  y_range.each do |y|
    x_range.each do |x|
      part = part_coords[[x, y]]
      return part if part
    end
  end
  false
end

part_coords = {}
schematic = []

$stdin.readlines.each_with_index do |line, y|
  line = line.strip
  next if line.empty?
  schematic << line
  line.each_char.each_with_index do |chr, x|
    next if chr.match?(/[\d.]/)
    part_coords[[x, y]] = true
  end
end

part_numbers_found = []

schematic.each_with_index do |line, y|
  part_numbers = line.scan(/\d+/)
  last_x_index = 0

  part_numbers.each do |part_number|
    x0 = line.index(part_number, last_x_index)
    x1 = (x0 + part_number.size)
    last_x_index = x1

    next unless is_part_number(part_coords, (x0 - 1)..x1, (y - 1)..(y + 1))
    part_numbers_found << part_number.to_i
  end
end

puts part_numbers_found.sum
