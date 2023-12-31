#!/usr/bin/env ruby

def count_winning_strats(time_limit, record_distance)
  (1...time_limit).count do |hold_time|
    (time_limit - hold_time) * hold_time > record_distance
  end
end

times, distances = $stdin.readlines.map { |l| l.scan(/\d+/).map(&:to_i) }
part1 = times.each_with_index.map do |time_limit, idx|
  count_winning_strats(time_limit, distances[idx])
end.inject(1, &:*)
puts part1

time_limit = times.map(&:to_s).join('').to_i
record_distance = distances.map(&:to_s).join('').to_i
part2 = count_winning_strats(time_limit, record_distance)
puts part2
