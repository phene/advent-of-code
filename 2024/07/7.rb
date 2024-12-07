#!/usr/bin/env ruby

equations = []
$stdin.readlines.each do |line|
  result, values = line.split(': ')
  values = values.split(' ').map(&:to_i)
  equations << [result.to_i, values]
end

module AoC
  refine Integer do
    def concat(other)
      (self.to_s + other.to_s).to_i
    end
  end
end
using AoC

# Depth-first search for equation rule, branching on each operation
def find_ops(result, values, ops, partial)
  return false if partial > result # optimization to prune dead trees
  if values.size == 1
    ops.any? do |op|
      result == partial.send(op, values[0])
    end
  else
    ops.any? do |op|
      find_ops(result, values[1..], ops, partial.send(op, values[0]))
    end
  end
end

total1, total2 = [0, 0]
equations.each do |result, values|
  if find_ops(result, values[1..], %i[+ *], values[0])
    total1 += result
    total2 += result
  elsif find_ops(result, values[1..], %i[+ * concat], values[0])
    total2 += result
  end
end
puts total1
puts total2
