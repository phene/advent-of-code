#!/usr/bin/env ruby

sum1, sum2 = [0, 0]
mult_enabled = true
$stdin.readlines.each do |line|
  line.scan(/mul\((\d{1,3}),(\d{1,3})\)|(don't|do)\(\)/).each do |x, y, do_dont|
    if x.nil?
      mult_enabled = (do_dont == "do")
      next
    end
    sum1 += x.to_i * y.to_i
    sum2 += x.to_i * y.to_i if mult_enabled
  end
end
puts sum1, sum2
