
pos = 50
zeros_0 = 0
zeros_1 = 0

$stdin.readlines.each do |line|
  line = line.strip
  break if line.empty?
  dir, dist = line[0], line[1..].to_i
  dir = dir == 'L' ? -1 : 1
  puts "pos = #{pos} + #{dist} * #{dir}"
  while dist >= 100
    zeros_1 += dist / 100
    dist = dist % 100
  end
  if pos == 0 && dir == 1 # compensate for going down to zero and switching directions
    zeros_1 += 1
  end

  pos += dist * dir
  if pos % 100 != pos
    zeros_1 += 1
    puts "zeros_1 += 1"
    pos = pos % 100
  end

  zeros_1 -= 1 if pos == 0 and dir == 1 # compensate for compensations when looping over and landing on zero
  zeros_0 += 1 if pos == 0
end

puts zeros_0
puts zeros_1
