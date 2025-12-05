#!/usr/bin/env ruby

require 'matrix'
V = Vector
X = (0..6)

def read_rocks
  rocks = []
  rock = []

  File.read('rocks.txt').each_line do |line|
    if line.chomp.empty?
      rocks << rock
      rock = []
    else
      rock << line.chomp.chars
    end
  end
  rocks << rock

  rocks.map do |rock|
    coords = []
    rock.reverse.each_with_index do |row, y|
      row.reverse.each_with_index do |cell, x|
        coords << V[x,y] if cell == '#'
      end
    end
    coords
  end
end

def move_rock(rock, move)
  rock.map { _1 + move }
end

def can_move?(rock, move, grid)
  move_rock(rock, move).all? { |v| !grid.include?(v) && X.include?(v[0]) }
end

def print_grid(grid)
  (grid.map { |v| v[1] }.max + 1).downto(1) do |y|
    print '|'
    X.each do |x|
      if grid.include? V[x,y]
        print '#'
      else
        print '.'
      end
    end
    puts '|'
  end
  puts '+-------+'
  puts
end

moves = $stdin.readline.chomp.chars.map { _1 == '<' ? V[-1,0] : V[1,0] }.cycle
rocks = read_rocks.cycle
grid = X.map { V[_1, 0] }.to_set

height = 0

(0...100000).each do
  rock_deltas = rocks.next
  origin = V[X.min, height + 4]
  rock = rock_deltas.map { origin + _1 }

  loop do
    move = moves.next
    rock = move_rock(rock, move) if can_move?(rock, move, grid)
    if can_move?(rock, V[0, -1], grid)
      rock = move_rock(rock, V[0, -1])
    else
      rock.each { |v| grid << v }
      new_height = [height, rock.map { _1[1] }.max].max
      height = new_height
      break
    end
  end
end

puts height
