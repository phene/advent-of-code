#!/usr/bin/env ruby

def mix_numbers(numbers)
  size = numbers.size
  mixed = numbers.each_with_index.map { |n, i| [n, i] }
  size.times do |i|
    n = mixed[i][0]
    idx = mixed[i][1]
    new_idx = (idx + n - (n < 0 ? 1 : 0)) % (size - (n > 0 ? 1 : 0))
    if new_idx < idx
      range_transform = ->(j) {
        next new_idx if j == idx
        (new_idx...idx).cover?(j) ? j+1 : j
      }
    elsif new_idx > idx
      range_transform = ->(j) {
        next new_idx if j == idx
        ((idx+1)..new_idx).cover?(j) ? j-1 : j
      }
    else
      next
    end

    mixed.map! { |n, j| [n, range_transform.call(j)] }
  end
  puts mixed.inspect
  mixed.sort_by(&:last).map(&:first)

  # numbers.each do |n|
  #   idx = mixed.index(n)
  #   new_idx = (idx + n - (n < 0 ? 1 : 0)) % (size - (n > 0 ? 1 : 0))
  #   if new_idx < idx
  #     mixed = mixed[0...new_idx] + [n] + mixed[new_idx...idx] + mixed[(idx+1)..]
  #   elsif new_idx > idx
  #     mixed = mixed[0...idx] + mixed[(idx+1)..new_idx] + [n] + mixed[(new_idx+1)..]
  #   end
  #   #puts "Moved #{n} from #{idx} to #{new_idx}: #{mixed.inspect}"
  # end
  # mixed
end

def grove(numbers, coords = [1000, 2000, 3000])
  idx = numbers.index(0)
  coords.sum do |coord|
    numbers[(idx+coord) % numbers.size].tap { puts _1 }
  end
end

numbers = $stdin.readlines.map(&:to_i)
mixed = mix_numbers(numbers)
puts mixed.inspect
puts grove(mixed)
