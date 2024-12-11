#!/usr/bin/env ruby

CACHE={}

def transform(stone, n)
  return 1 if n == 0
  CACHE[[stone, n]] ||= begin
    if stone == 0
      transform(1, n-1)
    elsif (s = stone.to_s).size % 2 == 0
      transform(s[0, s.size/2].to_i, n-1) + transform(s[s.size/2..].to_i, n-1)
    else
      transform(stone * 2024, n-1)
    end
  end
end

stones = $stdin.readline.chomp.split(' ').map(&:to_i)

size = stones.sum do |stone|
  transform(stone, 25)
end
puts size

size = stones.sum do |stone|
  transform(stone, 75)
end
puts size
