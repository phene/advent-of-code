#!/usr/bin/env ruby

require 'matrix'

hailstones = $stdin.readlines.map(&:chomp).map do |line|
  line.split(' @ ').map { |s| s.split(/\s?,\s?/).map(&:to_i) }
end

# MIN = 7
# MAX = 27
MIN = 200000000000000
MAX = 400000000000000

def hailstone_line_2d(hailstone)
  x1, y1, _, dx, dy, _ = hailstone.flatten.map(&:to_r)
  [Vector[x1, y1], Vector[x1 + dx, y1 + dy]]
end

def count_collisions_2d(hailstones, test_area)
  intersections = 0

  hailstones.each_with_index do |hailstone, idx|
    p1, p2 = hailstone_line_2d(hailstone)

    hailstones[(idx + 1)..].each do |other_hailstone|
      p3, p4 = hailstone_line_2d(other_hailstone)

      # https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_points_on_each_line
      mx12 = Matrix.columns([[p1[0], p2[0]], [1, 1]]).det
      mx34 = Matrix.columns([[p3[0], p4[0]], [1, 1]]).det
      my12 = Matrix.columns([[p1[1], p2[1]], [1, 1]]).det
      my34 = Matrix.columns([[p3[1], p4[1]], [1, 1]]).det

      p_bottom = Matrix[[mx12, my12], [mx34, my34]].det

      unless p_bottom.zero? # p_bottom == 0 if no intersection
        a = Matrix[p1, p2].det
        b = Matrix[p3, p4].det
        px = Matrix[[a, mx12], [b, mx34]].det / p_bottom
        py = Matrix[[a, my12], [b, my34]].det / p_bottom

        # Intersected in the past
        next if [px, py].each_with_index.any? do |p, d|
          next true if p1[d] > p2[d] ? p > p1[d] : p < p1[d]
          p3[d] > p4[d] ? p > p3[d] : p < p4[d]
        end

        # Intersected in the test area
        intersections += 1 if [px, py].all? { |p| test_area.cover? p.to_i }
      end
    end
  end

  intersections
end

def hailstone_line_3d(hailstone, t = 1)
  (x0, y0, z0), (dx, dy, dz) = hailstone
  [Vector[x0, y0, z0], Vector[x0 + (t * dx), y0 + (t * dy), z0 + (t * dz)]]
end

# Coefficients for (p - a) x (v - av) == (p - b) x (v - bv)
def matrix_half(a, av, b, bv)
  dx, dy, dz = (a - b).to_a
  dvx, dvy, dvz = (av - bv).to_a

  [
    [   0, -dvz,  dvy,   0, -dz,  dy],
    [ dvz,    0, -dvx,  dz,   0, -dx],
    [-dvy,  dvx,    0, -dy,  dx,   0],
  ]
end

# Constant terms for (p - a) x (v - av) == (p - b) x (v - bv)
def vector_half(a, av, b, bv)
  x, y, z = 0, 1, 2
  [
    (b[y] * bv[z] - b[z] * bv[y]) - (a[y] * av[z] - a[z] * av[y]),
    (b[z] * bv[x] - b[x] * bv[z]) - (a[z] * av[x] - a[x] * av[z]),
    (b[x] * bv[y] - b[y] * bv[x]) - (a[x] * av[y] - a[y] * av[x]),
  ]
end

def find_start_for_trick_shot(hailstones)
  h1, h2, h3 = hailstones.first(3).map { |h| h.map { |v| Vector[*v] }}

  s1 = [*h1, *h2]
  s2 = [*h1, *h3]

  a = Matrix.rows(matrix_half(*s1) + matrix_half(*s2))
  b = Vector.elements(vector_half(*s1) + vector_half(*s2))

  x = a.inverse * b
  x.to_a.first(3).sum.to_i
end

# Part 1
puts count_collisions_2d(hailstones, MIN..MAX)

# Part 2
puts find_start_for_trick_shot(hailstones)
