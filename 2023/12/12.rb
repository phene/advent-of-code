#!/usr/bin/env ruby

UNKNOWN = '?'
BROKEN = '#'
WORKING = '.'

CACHE = {}

def count_arrangements(springs, damaged_spring_counts)
  return damaged_spring_counts.empty? ? 1 : 0 if springs.nil? || springs.empty? # Reached end of springs, so check if any counts are missing
  return springs.include?(BROKEN) ? 0 : 1 if damaged_spring_counts.empty? # No more counts, but still broken springs

  cache_key = "#{springs}_#{damaged_spring_counts.join(',')}"
  return CACHE[cache_key] if CACHE[cache_key]

  count = 0
  spring = springs[0]

  # Keep counting damanged by skipping working spring and treat unknown as working
  count += count_arrangements(springs[1..], damaged_spring_counts) if spring == WORKING || spring == UNKNOWN

  # Keep counting damaged or treat unknown as damaged
  if spring != WORKING
    current_spring_count, *other_counts = damaged_spring_counts

    # Lookahead for current damaged spring count
    if current_spring_count <= springs.size and !springs[0...current_spring_count].include?(WORKING)
      if [WORKING, UNKNOWN, nil].include? springs[current_spring_count] # Can only end the set if next character is not BROKEN
        count += count_arrangements(springs[(current_spring_count + 1)..], other_counts) # skip
      end
    end
  end

  CACHE[cache_key] = count
end

spring_rows = $stdin.readlines.map do |l|
  springs, damaged_spring_counts = l.chomp.split(' ')
  damaged_spring_counts = damaged_spring_counts.split(',').map(&:to_i)
  [springs, damaged_spring_counts]
end

# Part 1
possible_counts = spring_rows.sum do |springs, damaged_spring_counts|
  count_arrangements(springs, damaged_spring_counts)
end

puts possible_counts

# Part 2
spring_rows.map! do |springs, damaged_spring_counts|
  [5.times.map { springs }.join(UNKNOWN), damaged_spring_counts * 5]
end

possible_counts = spring_rows.sum do |springs, damaged_spring_counts|
  count_arrangements(springs, damaged_spring_counts)
end

puts possible_counts
