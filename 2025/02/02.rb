#!/usr/bin/env ruby

ranges = $stdin.readline.strip.split(',').map do |r|
 a, b = r.split('-').map(&:to_i)
 a..b
end

part1_sum = ranges.flat_map do |range|
  range.select do |s|
    s = s.to_s
    next false unless s.size.even?
    invalid = s[0...s.size/2] == s[s.size/2..]
    invalid
  end
end.sum

puts part1_sum

part2_sum = ranges.flat_map do |range|
  range.select do |s|
    s = s.to_s
    invalid = (1..s.size / 2).any? do |i|
      count = s.size / i
      s == s[0...i] * count
    end
    invalid
  end
end.sum

puts part2_sum
