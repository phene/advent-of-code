#!/usr/bin/env ruby

require 'matrix'
V = Vector
A_TOKENS = 3
B_TOKENS = 1
PART2_DELTA = 10_000_000_000_000

def calculate_cost(m, v)
  a, b = *m.lup.solve(v).to_a # matrix math!
  # Accept only non-negative integer solutions
  return 0 unless a.denominator == 1 and b.denominator == 1 and a >= 0 and b >= 0
  (a.to_i * A_TOKENS + b.to_i * B_TOKENS)
end

games = []
until $stdin.eof?
  x1, y1 = *$stdin.readline.split(': ').last.split(', ').map{ _1[1..].to_i }
  x2, y2 = *$stdin.readline.split(': ').last.split(', ').map{ _1[1..].to_i }
  prize = V[*$stdin.readline.split(': ').last.split(', ').map{ _1[2..].to_i }]
  games << [Matrix[[x1, x2], [y1, y2]], prize]
  $stdin.readline unless $stdin.eof? # burn empty line between games
end

sum1, sum2 = [0, 0]
games.each do |game|
  m, b = *game
  sum1 += calculate_cost(m, b)
  sum2 += calculate_cost(m, V[b[0]+PART2_DELTA, b[1]+PART2_DELTA])
end

puts sum1, sum2
