#!/usr/bin/env ruby

$xhistory = []
$clock = 1
$x = 1
$instructions = []
$crt = []

def draw
  px = ($clock % 40) - 1
  $crt << [] if px == 0
  if ($x - px).abs <= 1
    $crt.last << '#'
  else
    $crt.last << '.'
  end
end

def tick
  $clock += 1
  draw
  if ($clock + 20) % 40 == 0
    puts "#{$clock} * #{$x} = #{$clock*$x}"
    $xhistory << $clock * $x
  end
end

$instructions = $stdin.readlines.map(&:chomp)

draw
$instructions.cycle do |instr|
  break if $clock >= 240
  if instr == 'noop'
    tick
  else
    add_x = instr.split(' ').last.to_i
    tick
    $x += add_x
    tick
  end
end

puts $xhistory.sum
$crt.each { puts _1.join('') }
