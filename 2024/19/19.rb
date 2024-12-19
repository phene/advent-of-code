#!/usr/bin/env ruby

@cache = {}
def dfs(design, pattern_hash)
  return 1 if design.empty?
  return @cache[design] if @cache.key? design
  count = 0
  pattern_hash[design[0]].each do |p|
    count += dfs(design[p.size..], pattern_hash) if design.start_with? p
  end
  @cache[design] = count
end

patterns = $stdin.readline.chomp.split(', ')
pattern_hash = Hash.new { |h, k| h[k] = [] }
patterns.each { |p| pattern_hash[p[0]] << p }
$stdin.readline # burn empty line
designs = $stdin.readlines.map(&:chomp)

possible_designs = designs.map { |d| dfs(d, pattern_hash) }

puts possible_designs.select(&:positive?).size
puts possible_designs.sum
