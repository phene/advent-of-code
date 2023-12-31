#!/usr/bin/env ruby
DIGITS = %w[
  zero
  one
  two
  three
  four
  five
  six
  seven
  eight
  nine
]

REPLACEMENTS = {
  'oneight' => 'oneeight',
  'twone' => 'twoone',
  'threeight' => 'threeeight',
  'fiveight' => 'fiveeight',
  'sevenine' => 'sevinnine',
  'eightwo' => 'eighttwo',
  'eighthree' => 'eightthree',
  'nineight' => 'nineeight',
}.freeze

def convert(digit)
  (DIGITS.index(digit) || digit).to_s
end

def sanitize(line)
  REPLACEMENTS.inject(line.strip) do |k, v|
    line.gsub(k, v)
  end
end

sum = $stdin.readlines.sum do |line|
  digits = sanitize(line).scan(/\d|#{DIGITS.join('|')}/)
  next 0 if digits.empty?
  (convert(digits.first) + convert(digits.last)).to_i
end
puts sum
