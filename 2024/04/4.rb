#!/usr/bin/env ruby

grid = []
$stdin.readlines.each do |line|
  grid << line.strip.chars
end

## PART 1
def search_lateral(grid, word = 'XMAS')
  total = 0
  words = [word, word.reverse]
  grid.each do |line|
    words.each do |word|
      total += line.join('').scan(word).size
    end
  end
  total
end

def fetch_diagonal_word(grid, x0, y0, dx, dy, n)
  return nil unless (0...grid.size).include?(y0+(n-1)*dy)
  return nil unless (0...grid[0].size).include?(x0+(n-1)*dx)
  (0...n).map do |i|
    grid[y0+i*dy][x0+i*dx]
  end.join('')
end

def search_diagonal(grid, word = 'XMAS')
  total = 0
  dx_dys = [[-1, -1], [-1, 1], [1, -1], [1, 1]]
  grid.each_with_index do |line, y|
    last_x = 0
    line = line.join('')
    loop do
      x = line.index(word[0], last_x)
      break unless x
      last_x = x.succ
      total += dx_dys.map do |(dx, dy)|
        fetch_diagonal_word(grid, x, y, dx, dy, word.size)
      end.count(word)
    end
  end
  total
end

total = search_lateral(grid)
total += search_lateral(grid.transpose)
total += search_diagonal(grid)
puts total

## PART 2

def is_x_mas?(grid, x, y)
  # Needs to be at least distance 2 from edges
  return false if x < 1 or x > grid[0].size - 2
  return false if y < 1 or y > grid.size - 2
  return false unless [grid[y-1][x-1], grid[y+1][x+1]].sort.join('') == 'MS'
  return false unless [grid[y-1][x+1], grid[y+1][x-1]].sort.join('') == 'MS'
  return true
end

def search_x_mas(grid)
  total = 0
  grid.each_with_index do |line, y|
    next if y == 0 or y == grid.size - 1 # skip first and last rows. can't be on the edge
    last_x = 0
    line = line.join('')
    loop do
      x = line.index('A', last_x)
      break unless x
      last_x = x.succ
      total = total.succ if is_x_mas?(grid, x, y)
    end
  end
  total
end

puts search_x_mas(grid)
