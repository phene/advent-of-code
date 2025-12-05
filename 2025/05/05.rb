#!/usr/bin/env ruby

require_relative '../../2023/range'

def fresh?(fresh_ranges, ingredient)
  fresh_ranges.any? { _1.cover? ingredient }
end

fresh_ranges, ingredients = [], []
read_ingredients = false

$stdin.readlines.each do |line|
  if line.strip.empty?
    read_ingredients = true
    next
  end

  if read_ingredients
    ingredients << line.to_i
  else
    fresh_ranges << Range.new(*line.strip.split('-').map(&:to_i))
  end
end

fresh_ranges = Range.merge_ranges(fresh_ranges)
puts ingredients.count { fresh? fresh_ranges, _1 }
puts fresh_ranges.sum(&:size)
