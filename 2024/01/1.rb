#!/usr/bin/env ruby

list1, list2 = [], []
$stdin.readlines.each do |line|
  m = line.match /(\d+)\s+(\d+)/
  list1 << m[1].to_i
  list2 << m[2].to_i
end
list1.sort!
list2.sort!

sum1, sum2 = 0, 0
list1.each_with_index do |a, i|
  b = list2[i]
  sum1 += (a - b).abs
  sum2 += a * list2.count(a)
end
puts sum1, sum2
