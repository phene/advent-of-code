class Range
  def intersect_with?(other)
    return false if self.begin > other.max || self.max < other.begin
    true
  end

  def intersect_or_meet?(other)
    return false if self.begin > 1 + other.max or 1 + self.max < other.begin
    true
  end

  def intersection(other)
    return [self, other] if (self.max < other.begin or other.max < self.begin)
    [self.begin, other.begin].max..([self.max, other.max].min)
  end
  alias_method :&, :intersection

  def minus(other)
    return [self] if self.begin > other.max || self.max < other.begin
    if self.begin < other.begin && self.max <= other.max
      [self.begin...other.begin]
    elsif self.begin > other.begin && self.max < other.max
      [other.max..self.max]
    else
      [self.begin...other.begin, other.max.succ..self.max]
    end
  end
  alias_method :-, :minus

  def merge(other)
    return [self, other] unless intersect_or_meet?(other)
    [[self.begin, other.begin].min..([self.max, other.max].max)]
  end

  class << self
    def merge_ranges(ranges)
      return ranges if ranges.empty?
      begin
        size = ranges.size
        ranges = ranges.each_with_object([]) do |r1, new_ranges|
          found = false
          new_ranges.each_with_index do |r2, i|
            next unless r1.intersect_or_meet?(r2)
            new_ranges[i] = r1.merge(r2).first
            found = true
            break
          end
          new_ranges << r1 unless found
        end
      end while ranges.size < size
      ranges
    end
  end
end
