#!/usr/bin/env ruby

require 'matrix'
V = Vector

def in_bounds(grid, p) = (0...grid.size).include?(p[1]) && (0...grid[0].size).include?(p[0])
def get_cell(grid, p) = grid[p[1]][p[0]]
def update_cell(grid, p, val) = grid[p[1]][p[0]] = val

def visible_trees(grid)
  x_range, y_range = [0...grid[0].size, 0...grid.size]
  visible_grid = grid.map { |row| row.map { false } }

  y_range.each do |y|
    [x_range, x_range.max.downto(x_range.min)].each do |xs|
      highest_cell = -1
      xs.each do |x|
        next_cell = get_cell(grid, V[x,y])
        update_cell(visible_grid, V[x,y], true) if next_cell > highest_cell
        highest_cell = [next_cell, highest_cell].max
      end
    end
  end

  x_range.each do |x|
    [y_range, y_range.max.downto(y_range.min)].each do |ys|
      highest_cell = -1
      ys.each do |y|
        next_cell = get_cell(grid, V[x,y])
        update_cell(visible_grid, V[x,y], true) if next_cell > highest_cell
        highest_cell = [next_cell, highest_cell].max
      end
    end
  end
  visible_grid.sum { _1.count(&:itself) }
end

def best_scenic_score(grid)
  x_range, y_range = [0...grid[0].size, 0...grid.size]
  scenic_scores = grid.map { |row| row.map { 0 } }

  x_range.each do |x|
    y_range.each do |y|
      score = 1
      p = V[x,y]
      p_h = get_cell(grid, p)
      # Walk each direction until we reach a tree of equal
      # or greater heigh, or we reach the end of the grid
      [V[1,0], V[-1,0], V[0,-1], V[0,1]].each do |d|
        dir_score = 0
        (1..).each do |n|
          np = p + d*n
          break unless in_bounds(grid, np)
          dir_score += 1
          break if get_cell(grid, np) >= p_h
        end
        score *= dir_score
      end
      update_cell(scenic_scores, p, score)
    end
  end

  scenic_scores.inject(0) { [_1, _2.max].max }
end

grid = $stdin.readlines.map { _1.chomp.chars.map(&:to_i) }
puts visible_trees(grid)
puts best_scenic_score(grid)
