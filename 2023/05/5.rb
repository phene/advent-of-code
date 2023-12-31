#!/usr/bin/env ruby

class Range
  def intersection(other)
    return nil if (self.max < other.begin or other.max < self.begin)
    [self.begin, other.begin].max..([self.max, other.max].min)
  end
  alias_method :&, :intersection
end

def transform_ranges(to_froms, ranges)
  tfm_ranges = []
  ranges.each do |range|
    uncovered_ranges = [range]
    to_froms.each do |to, from|
      rs = uncovered_ranges.dup
      uncovered_ranges = []
      rs.each do |r|
        int = (r & from)
        if int.nil?
          uncovered_ranges << r
        else
          uncovered_ranges << (r.begin...int.begin) if r.begin < int.begin
          uncovered_ranges << (int.max...r.max) if int.max < r.max

          begin_offset = int.begin - from.begin
          end_offset = from.max - int.max
          tfm_ranges << ((to.begin + begin_offset)..(to.max - end_offset))
        end
      end
    end
    tfm_ranges.concat uncovered_ranges
  end
  tfm_ranges
end

def all_transforms(transformations, seed_range)
  transformations.inject([seed_range]) do |ranges, tfms|
    transform_ranges(tfms, ranges)
  end
end

transformations = []
seeds = $<.readline.split(':').last.scan(/\d+/).map(&:to_i)

$<.readlines.each do |line|
  line = line.strip
  next if line.empty?
  transformations << [] and next if line.include? ':'

  to, from, n = line.scan(/\d+/).map(&:to_i)
  transformations.last << [to...(to + n), from...(from + n)]
end

# Part 1
locations = seeds.map do |seed|
  all_transforms(transformations, seed...(seed + 1)).map(&:begin).min
end
puts locations.min

# Part 2
locations = seeds.each_slice(2).map do |seed, n|
  all_transforms(transformations, seed...(seed + n)).map(&:begin).min
end
puts locations.min

