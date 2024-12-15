#!/usr/bin/env ruby
require 'matrix'
V = Vector

ROBOT = '@'
BOX = 'O'
WALL = '#'
EMPTY = '.'
LEFT_BOX = '['
RIGHT_BOX = ']'

MOVES = {
  '^' => V[0, -1],
  '>' => V[1, 0],
  'v' => V[0, 1],
  '<' => V[-1, 0],
}.freeze

def update_cell(grid, p, item) = grid[p[1]][p[0]] = item
def get_cell(grid, p) = grid[p[1]][p[0]]

def each_cell(grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      yield cell, x, y
    end
  end
end

def boxes_score(grid)
  score = 0
  each_cell(grid) do |cell, x, y|
    case cell
    when BOX, LEFT_BOX
      score += x + y * 100
    end
  end
  score
end

def start(grid)
  each_cell(grid) do |cell, x, y|
    return V[x,y] if cell == ROBOT
  end
  nil
end

def move(grid, p1, p2)
  thing = get_cell(grid, p1)
  case get_cell(grid, p2)
  when EMPTY
    update_cell(grid, p2, thing)
    update_cell(grid, p1, EMPTY)
    p2
  when WALL
    p1
  when BOX
    if p2 != move(grid, p2, p2 + (p2 - p1)) # Could move box
      update_cell(grid, p2, thing)
      update_cell(grid, p1, EMPTY)
      p2
    else
      p1
    end
  else # LEFT_BOX, RIGHT_BOX
    d = p2 - p1
    if d == MOVES['<'] or d == MOVES['>'] # Moving horizontal
      if p2 != move(grid, p2, p2 + d)
        update_cell(grid, p2, thing)
        update_cell(grid, p1, EMPTY)
        p2
      else
        p1
      end
    else # Moving vertically, so interactions with halves of boxes
      other_half =
        if get_cell(grid, p2) == LEFT_BOX
          p2 + MOVES['>']
        else
          p2 + MOVES['<']
        end
      # Check if both halves can move before attempting to move
      if can_move?(grid, p2, p2 + d) and can_move?(grid, other_half, other_half+d)
        move(grid, p2, p2 + d)
        move(grid, other_half, other_half + d)
        update_cell(grid, p1, EMPTY)
        update_cell(grid, p2, thing)
        update_cell(grid, other_half, EMPTY)
        p2
      else
        p1
      end
    end
  end
end

def can_move?(grid, p1, p2)
  case get_cell(grid, p2)
  when EMPTY
    true
  when WALL
    false
  else # LEFT_BOX, RIGHT_BOX
    d = p2 - p1
    if d == MOVES['<'] or d == MOVES['>'] # Moving horizontally, so no special interactions
      can_move?(grid, p2 + d)
    else
      other_half = get_cell(grid, p2) == LEFT_BOX ? p2 + MOVES['>'] : p2 + MOVES['<']
      can_move?(grid, p2, p2 + d) and can_move?(grid, other_half, other_half + d)
    end
  end
end

def traverse(grid, movements)
  position = start(grid)
  while movement = movements.shift
    position = move(grid, position, position + MOVES[movement])
  end
end

def transform_grid(grid)
  grid.map do |row|
    row.flat_map do |cell|
      case cell
      when '.'
        ['.', '.']
      when 'O'
        ['[', ']']
      when '#'
        ['#', '#']
      when '@'
        ['@', '.']
      end
    end
  end
end

def draw(grid)
  grid.each do |row|
    puts row.join('')
  end
  puts
end

def copy_grid(grid)
  new_grid = []
  grid.each do |row|
    new_grid << row.dup
  end
  new_grid
end

grid = []
movements = []
still_grid = true

$stdin.readlines.each_with_index do |line|
  if still_grid
    if line.strip.empty?
      still_grid = false
    else
      grid << line.chomp.chars
    end
  else
    movements.concat line.chomp.chars
  end
end

part1_grid = copy_grid(grid)
traverse(part1_grid, movements.dup)
# draw(part1_grid)
puts boxes_score(part1_grid)

part2_grid = transform_grid(grid)
traverse(part2_grid, movements.dup)
# draw(part2_grid)
puts boxes_score(part2_grid)
