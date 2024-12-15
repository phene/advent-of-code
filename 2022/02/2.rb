#!/usr/bin/env ruby

SHAPE = { 'X' => 1, 'Y' => 2, 'Z' => 3, 'A' => 1, 'B' => 2, 'C' => 3 }
ABC = %w[A B C]
XYZ = %w[X Y Z]

def score1(a, b)
  return SHAPE[b] + 3 if ABC.index(a) == XYZ.index(b)
  return SHAPE[b] + 6 if XYZ[(ABC.index(a)+1)%3] == b
  SHAPE[b]
end

def score2(a, b)
  case b
  when 'X' then return SHAPE[XYZ[(ABC.index(a)-1)%3]]
  when 'Y' then return SHAPE[XYZ[ABC.index(a)%3]] + 3
  else return SHAPE[XYZ[(ABC.index(a)+1)%3]] + 6
  end
end

games = $stdin.readlines.map { |line| line.chomp.split(' ') }
puts games.map { |a, b| score1(a, b) }.sum
puts games.map { |a, b| score2(a, b) }.sum
