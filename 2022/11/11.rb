#!/usr/bin/env ruby

class Item
  def initialize(id, val, monkey_id)
    @id = id
    @val = val
    @history = [@val]
    @monkies = [monkey_id]
  end

  def throw(op, test, with_division = true)
    @val = op.call(@val)
    @val /= 3 if with_division
    @val %= $lcm
    @history << @val
    new_monkey = test.call(@val)
    $monkies[new_monkey][:items] << self
    @monkies << new_monkey
  end

  def details
    #     #{@id} has had values:  #{@history.map(&:to_s).join(', ')}
    <<~DETAILS
    #{@id} has been thrown: #{@monkies.map(&:to_s).join(', ')}
    DETAILS
  end

  def reset
    @val = @history.first
    @history = [@val]
    $monkies[@monkies.last][:items].delete self
    $monkies[@monkies.first][:items] << self
    @monkies = [@monkies.first]
    @cycle = nil
  end

  # TODO: Cycles are being interrupted at larger and larger lengths, so we need to find another
  # pattern to the cycles than offset + length
  def find_cycle
    (0..).each do |offset|
      (3..300).each do |length|
        raise "Not enough examples for #{@id}" if offset + length*10 >= @monkies.size
        if @monkies[offset, length*10] == @monkies[offset,length] * 10
          puts "#{@id} cycle at #{offset} + #{length}"
          return [offset, length]
        end
      end
    end
    raise "No cycle found"
  end

  def cycle
    @cycle ||= find_cycle
  end

  def monkey_at(t)
    @cycle ||= find_cycle
    offset, length = @cycle
    return @monkies[t] if t <= offset
    @monkies[offset + ((t - offset) % length)]
  end
end

def monkey_business(rounds, with_division = true)
  rounds.times do |round|
    $monkies.each do |monkey, attrs|
      attrs[:items].each do |item|
        item.throw(attrs[:op], attrs[:test], with_division)
        $monkies[monkey][:inspections] = $monkies[monkey][:inspections].succ
      end
      attrs[:items] = []
    end
  end
  puts $monkies.transform_values { _1[:inspections] }.inspect
  $monkies.each_value.map { _1[:inspections] }.sort.last(2).inject(&:*)
end

item_id = 0
$divisors = []
$monkies = $stdin.readlines.each_slice(7).to_h do |lines|
  operation = lines[2].split('=').last
  divisible_by = lines[3].scan(/\d+/).first.to_i
  if_true, if_false = [lines[4], lines[5]].map { _1.scan(/\d+/).first.to_i }
  monkey_id = lines[0].scan(/\d+/).first.to_i
  $divisors << divisible_by
  [monkey_id, {
    items: lines[1].scan(/\d+/).map(&:to_i).map { Item.new(item_id+=1, _1, monkey_id) },
    op: eval("->(old) { #{operation} } "),
    test: ->(val) { val % divisible_by == 0 ? if_true : if_false },
    inspections: 0,
  }]
end
$lcm = $divisors.inject(&:lcm)
puts monkey_business(20, true)
$monkies.each_value { _1[:items].dup.each(&:reset) }

puts monkey_business(9999, false)
# items = $monkies.each_value.map { _1[:items] }.flatten
# items.each { puts _1.details }
# monkey_inspections = Hash.new(0)
# 10_000.times do |t|
#   items.each do |item|
#     monkey_inspections[item.monkey_at(t)] += 1
#   end
# end
# puts monkey_inspections.inspect
# puts monkey_inspections.values.sort.last(2).inject(&:*)
