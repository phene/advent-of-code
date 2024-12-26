#!/usr/bin/env ruby

require 'matrix'
V = Vector

DIRS = {
  'R' => V[1, 0],
  'L' => V[-1, 0],
  'U' => V[0, -1],
  'D' => V[0, 1],
}

def draw(knots, visits)
  x_min, x_max = (knots.map { _1[0] } + visits.map { _1[0] }).minmax
  y_min, y_max = (knots.map { _1[1] } + visits.map { _1[1] }).minmax

  (y_min..y_max).each do |y|
    (x_min..x_max).each do |x|
      p = V[x,y]
      if knots.first == p
        print 'H'
      elsif knots.any? p
        print knots.index(p)
      elsif visits.include? p
        print '#'
      else
        print '.'
      end
    end
    puts
  end
  puts
end

def simulate_steps(steps, knot_count)
  knots = [V[0,0]] * knot_count
  visits = Set[V[0,0]]
  steps.each do |dir, dist|
    dist.times do
      knots[0] += dir
      (1...knot_count).each do |ki|
        next unless (knots[ki-1]-knots[ki]).to_a.any? { _1.abs > 1 }
        knots[ki] += V[*(knots[ki-1]-knots[ki]).to_a.map { _1.clamp(-1, 1) }] # Move at most one in any direction
        visits << knots[ki] if ki == knot_count - 1
      end
      #draw(knots, visits)
    end
  end
  visits.size
end

steps = []
$stdin.readlines.each do |line|
  dir, dist = line.split(' ')
  steps << [DIRS[dir], dist.to_i]
end

puts simulate_steps(steps, 2)
puts simulate_steps(steps, 10)
