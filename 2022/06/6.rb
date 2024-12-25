#!/usr/bin/env ruby

buffer = $stdin.readline.chars

[4, 14].each do |size|
  position = -1
  buffer.each_cons(size).each_with_index do |(*chrs), index|
    position = index+size and break if chrs.to_set.size == size
  end
  puts position
end
