#!/usr/bin/env ruby
part_1_max_cubes = { 'red' => 12, 'green' => 13, 'blue' => 14 }
results = $stdin.readlines.each_with_index.map do |line, game_id|
  max_cubes = Hash.new(0)
  line.strip.split(':').last.strip.split(/\s*[;,]\s*/).each do |cube|
    number, color = cube.split(' ')
    max_cubes[color] = [max_cubes[color], number.to_i].max
  end
  game_id = -1 unless max_cubes.all? { |color, count| part_1_max_cubes[color] >= count }
  [game_id + 1, max_cubes.values.inject(1, &:*)]
end
sums = results.inject([0, 0]) do |(part1, part2), (game_id, product)|
  [part1 + game_id, part2 + product]
end
puts(*sums)
