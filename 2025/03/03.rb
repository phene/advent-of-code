#!/usr/bin/env ruby

def find_largest(bank, size = 2)
  return nil if bank.size < size
  return nil if size < 1

  largest_v, largest_i = 0
  bank[..(-size)].each_with_index do |v, i|
    largest_v, largest_i = v, i if v > largest_v
  end

  return largest_v if size == 1

  v2 = find_largest(bank[largest_i+1..], size - 1)
  (largest_v.to_s + v2.to_s).to_i
end

banks = []

$stdin.readlines.each do |line|
  banks << line.strip.chars.map(&:to_i)
end

part1_sum = banks.sum do |bank|
  find_largest(bank)
end
puts part1_sum

part2_sum = banks.sum do |bank|
  find_largest(bank, 12)
end
puts part2_sum
