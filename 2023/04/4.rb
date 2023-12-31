#!/usr/bin/env ruby

def make_copies(game_id)
  ((game_id + 1)..(game_id + $games[game_id]))
    .each { $copies[_1] += 1 }
    .each { make_copies(_1) }
end

$games, $copies = Hash.new(0), Hash.new(0)
part1_points = $stdin.readlines.each_with_index.sum do |line, game_id|
  matching = line.split(':').last.strip.split('|').map { |list| Set.new(list.strip.split(/\s+/).map(&:to_i)) }.inject(&:&)
  $games[game_id] = matching.size
  $copies[game_id] = 1
  (2 ** (matching.size - 1)).floor
end
$games.each_key { make_copies(_1) }
puts part1_points, $copies.values.sum
