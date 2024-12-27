#!/usr/bin/env ruby

items = []

$stdin.readlines.each_slice(3) do |left, right, _|
  items << eval(left)
  items << eval(right)
end

def compare(left, right)
  if [left, right].all? Integer
    #puts "Comparing #{left} with #{right}"
    left <=> right
  elsif [left, right].all? Array
    #puts "Comparing #{left} with #{right}"
    left.zip(right).each do |l, r|
      cmp = compare(l, r)
      return -1 if cmp < 0
      return 1 if cmp > 0
    end
    return -1 if left.size < right.size
    return 0
  elsif left.nil?
    return 0 if right.nil?
    return -1
  elsif right.nil?
    return 1
  else
    left = [left] unless left.is_a? Array
    right = [right] unless right.is_a? Array
    compare(left, right)
  end
end

sorted_pairs = items.each_slice(2).each_with_index.inject(0) do |sum, ((left, right), idx)|
  #puts "Comparing #{idx} #{left.inspect} with #{right.inspect}"
  cmp = compare(left, right)
  #puts "#{idx} result: #{cmp}"
  next sum + idx + 1 if cmp <= 0
  sum
end

puts sorted_pairs

dividers = [ [[2]], [[6]] ]
items += dividers
sorted_items = items.sort { |l,r| compare(l,r) }
puts dividers.map { sorted_items.index(_1) + 1 }.inject(&:*)
