#!/usr/bin/env ruby

class Range
  def overlap?(other)
    return false if self.begin > other.max || self.max < other.begin
    true
  end
end unless Range.instance_methods.include? :overlap? # Available in new versions of Ruby

elf_pairs = $stdin.readlines.map { |line| line.chomp.split(',').map { Range.new(*_1.split('-').map(&:to_i)) } }

puts elf_pairs.count { |elf1, elf2| elf1.cover?(elf2) or elf2.cover?(elf1) }
puts elf_pairs.count { |elf1, elf2| elf1.overlap?(elf2) or elf2.overlap?(elf1) }
