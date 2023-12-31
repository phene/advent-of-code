#!/usr/bin/env ruby

def regress(history)
  [history].tap do |regressions|
    regressions << regressions.last.each_cons(2).map { |x, y| y - x } until regressions.last.all?(&:zero?)
  end
end

def extrapolate(regressions, multiplier = 1)
  regressions.reverse.each_cons(2) { |prev, this| this << this.last + prev.last * multiplier }.last.last
end

oasis_histories = $stdin.readlines.map { |line| line.chomp.split(' ').map(&:to_i) }
part1 = oasis_histories.sum { |oasis_history| extrapolate(regress(oasis_history)) }
puts part1
part2 = oasis_histories.sum { |oasis_history| extrapolate(regress(oasis_history).map(&:reverse), -1) }
puts part2
