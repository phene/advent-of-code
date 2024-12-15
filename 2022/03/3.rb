#!/usr/bin/env ruby

def priority(p)
  if p.ord > 'Z'.ord
    p.ord - 'a'.ord + 1
  else
    p.ord - 'A'.ord + 27
  end
end

rucksacks = $stdin.readlines.map(&:chomp).map { |line| [line[0...line.size/2].chars, line[line.size/2..].chars] }
priorities = rucksacks.sum do |r1, r2|
  priority(r1.intersection(r2).first)
end
puts priorities

priorities = (0...rucksacks.size/3).sum do |i|
  group = rucksacks[i*3, 3].map { |r1, r2| r1 + r2 }
  priority(group.inject(&:intersection).first)
end
puts priorities
