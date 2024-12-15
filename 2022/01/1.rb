#!/usr/bin/env ruby

elves = []
elf = 0
$stdin.readlines.each do |line|
  if line.chomp.empty?
    elves << elf
    elf = 0
  else
    elf += line.to_i
  end
end
elves << elf

puts elves.max
puts elves.sort.last(3).sum
