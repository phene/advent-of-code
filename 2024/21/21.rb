#!/usr/bin/env ruby

require 'matrix'
V = Vector

DIR_TO_V = [ ['^', V[0, -1]], ['>', V[1, 0]], ['v', V[0, 1]], ['<', V[-1, 0]] ].to_h
KEYPAD = {
  '7' => V[0,0], '8' => V[1,0], '9' => V[2,0],
  '4' => V[0,1], '5' => V[1,1], '6' => V[2,1],
  '1' => V[0,2], '2' => V[1,2], '3' => V[2,2],
                 '0' => V[1,3], 'A' => V[2,3],
}.freeze
KEYPAD_START = KEYPAD['A']
KEYPAD_DEADSPOT = V[0,3]

DPAD = {
                 '^' => V[1,0], 'A' => V[2,0],
  '<' => V[0,1], 'v' => V[1,1], '>' => V[2,1],
}.freeze
DPAD_START = DPAD['A']
DPAD_DEADSPOT = V[0,0]

def x_dpad(delta) = if delta < 0 then '<' * -delta else '>' * delta end
def y_dpad(delta) = if delta < 0 then '^' * -delta else 'v' * delta end

@moves_to_pos = {}
def moves_to_pos(start, finish, deadspot)
  return ['A'] if start == finish
  cache_key = [start, finish, deadspot]
  return @moves_to_pos[cache_key] if @moves_to_pos[cache_key]
  delta = finish - start
  valid_move_sets = Set.new
  (x_dpad(delta[0]) + y_dpad(delta[1])).chars.permutation do |moves|
    move_str = moves.join('') + 'A'
    next if valid_move_sets.include? move_str
    valid = true
    current = start
    moves.each do |move|
      current += DIR_TO_V[move]
      next unless deadspot == current
      valid = false
      break
    end
    valid_move_sets << move_str if valid
  end
  @moves_to_pos[cache_key] = valid_move_sets.to_a
end

@min_moves_for_code = {}
def min_moves_for_code(code, depth = 0, pad = KEYPAD, deadspot = KEYPAD_DEADSPOT)
  cache_key = [code, depth]
  return @min_moves_for_code[cache_key] if @min_moves_for_code[cache_key]
  current = pad['A']
  move_count = 0
  code.each_char do |c|
    next_pos = pad[c]
    moves = moves_to_pos(current, next_pos, deadspot)
    if depth > 0
      move_count += moves.map { min_moves_for_code(_1, depth - 1, DPAD, DPAD_DEADSPOT) }.min
    else
      move_count += moves[0].size
    end
    current = next_pos
  end
  @min_moves_for_code[cache_key] = move_count
end

codes = $stdin.readlines.map { |line| line.chomp }
sum1 = sum2 = 0
codes.each do |code|
  codeNumber = code.to_i
  sum1 += codeNumber * min_moves_for_code(code, 2)
  sum2 += codeNumber * min_moves_for_code(code, 25)
end

puts sum1, sum2
