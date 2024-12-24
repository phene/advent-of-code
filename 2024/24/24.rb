#!/usr/bin/env ruby

$outputs = {}

class Input
  def initialize(val)
    @original = val
    @output = val
  end
  def output(*)
    @output
  end
  def set(out)
    @output = out
  end
  def reset = @output = @original
  def op = 'in'
end

class Output
  class Cycle < StandardError; end
  attr_reader :in1, :in2, :op
  def initialize(op, in1, in2)
    @op = op
    @in1 = in1
    @in2 = in2
  end

  def reset
    @output = nil
  end

  def output(visited = [])
    raise Cycle if visited.include?(@in1) or visited.include?(@in2)
    if !@output.nil?
      @output
    else
      @output =
        case @op
        when 'AND'
          $outputs[@in1].output(visited + [@in1]) && $outputs[@in2].output(visited + [@in2])
        when 'OR'
          $outputs[@in1].output(visited + [@in1]) || $outputs[@in2].output(visited + [@in2])
        when 'XOR'
          $outputs[@in1].output(visited + [@in1]) ^ $outputs[@in2].output(visited + [@in2])
        end
    end
  end
end

def read_number(prefix)
  result = 0
  (0..).each do |idx|
    name = "#{prefix}#{idx.to_s.rjust(2, '0')}"
    break unless $outputs.key?(name)
    result += $outputs[name].output ? (1 << idx) : 0
  end
  result
end

def set_input(in_prefix, number)
  bit = 1
  (0..).each do |in_idx|
    in_name = "#{in_prefix}#{in_idx.to_s.rjust(2, '0')}"
    break unless $outputs.key? in_name
    $outputs[in_name].set(number & (bit << in_idx) != 0)
  end
end

def style_node(node, bad_node = false)
  if node.include? '_'
    op = node.split('_')[1]
    attrs = case op
            when 'AND' then 'shape=invtrapezium,fillcolor=yellow'
            when 'OR' then 'shape=invtriangle,fillcolor=greenyellow'
            when 'XOR' then 'shape=invhouse,fillcolor=green,fontcolor=white'
            end

    return node + "[label=#{op},style=filled,#{attrs}]"
  end

  if node.start_with? 'x'
    return node + "[shape=square,style=filled,fillcolor=deepskyblue]"
  elsif node.start_with? 'y'
    return node + "[shape=square,style=filled,fillcolor=dodgerblue]"
  elsif node.start_with? 'z'
    if bad_node
      return node + "[shape=square,style=filled,fillcolor=red]"
    else
      return node + "[shape=square,style=filled,fillcolor=purple,fontcolor=white]"
    end
  elsif bad_node
    return node + "[shape=square,style=filled,fillcolor=red]"
  else
    return node + "[shape=square,style=filled,fillcolor=lightgrey]"
  end
end

def write_graph(bad_outputs = [])
  File.open('graph.dot', 'w') do |f|
    f.puts "digraph 24 {"

    $outputs.each_key do |out|
      f.puts "  #{style_node(out, bad_outputs.include?(out))}"
    end

    $outputs.each do |out, io|
      next if io.is_a? Input
      operator = "#{io.in1}_#{io.op}_#{io.in2}"
      f.puts "  #{style_node(operator)}"
      f.puts "  #{operator} -> #{out}"
      f.puts "  #{io.in1} -> #{operator}"
      f.puts "  #{io.in2} -> #{operator}"
    end

    f.puts "}"
  end
end

# Recurse upstream nodes to a particular depth
def upstream_nodes(out_name, depth = 2)
  return [] if depth == 0
  return [] if $outputs[out_name].is_a? Input
  [
    $outputs[out_name].in1,
    $outputs[out_name].in2
  ].map do |input|
    next [] if $outputs[input].is_a? Input
    [input] + upstream_nodes(input, depth-1)
  end.flatten.compact
end

def read_input
  outputs = {}
  $stdin.readlines.each do |line|
    if m = line.match(/(\w+): (\d)/)
      outputs[m[1]] = Input.new(m[2] == '1')
    elsif !line.chomp.empty?
      if m = line.match(/(\w+) (AND|XOR|OR) (\w+) -> (\w+)/)
        in1, op, in2, out = m[1..]
        outputs[out] = Output.new(op, in1, in2)
      end
    end
  end
  outputs
end

# Returns the names of outputs the give bad results when testing
# single bit inputs that would trigger carry
def find_bad_outputs
  input_bits = $outputs.each_key.count { |k| k.start_with? 'x' }
  bad_outputs = Set[]

  input_bits.times do |n|
    $outputs.each_value(&:reset)

    set_input('x', (1 << n))
    set_input('y', (1 << n))

    expected_z = (1 << (n+1))
    actual_z = read_number('z')

    bad_bits = expected_z ^ actual_z
    bad_bit_numbers = []
    (input_bits+1).times do |n|
      bad_bit_numbers << n if bad_bits & (1 << n) != 0
    end
    bad_bit_numbers.each do |n|
      bad_outputs << "z#{n.to_s.rjust(2, '0')}"
    end
  end

  bad_outputs
end

# Tests grouped combinations together
def find_swapped_outputs(groups)
  visited = Set[]
  output_bits = $outputs.each_key.count { |k| k.start_with? 'z' }
  tests = [
    # These tests should exclude most bad swaps
    [("1" * (output_bits-1)).to_i(2), 1], # Full carry
    [("01" * ((output_bits-1)/2)).to_i(2), ("10" * ((output_bits-1)/2)).to_i(2)], # zero carry
  ]

  # A bunch of other random tests in the case of flukes
  100.times do
    tests << [Random.rand(2**(output_bits-1)), Random.rand(2**(output_bits-1))]
  end

  # Find output name for each group
  group_outputs = groups.map { |g| g.find { _1.start_with? 'z' } }.compact

  groups[0].combination(2) do |grp0_outs|
    # skip combinations that don't include output
    next if group_outputs.size > 0 && !grp0_outs.include?(group_outputs[0])
    groups[1].combination(2) do |grp1_outs|
      next if group_outputs.size > 1 && !grp1_outs.include?(group_outputs[1])
      groups[2].combination(2) do |grp2_outs|
        next if group_outputs.size > 2 && !grp2_outs.include?(group_outputs[2])
        groups[3].combination(2) do |grp3_outs|
          next if group_outputs.size > 3 && !grp3_outs.include?(group_outputs[3])
          out_names = grp0_outs + grp1_outs + grp2_outs + grp3_outs
          visit = out_names.each_slice(2).map { [_1, _2].sort.join('-') }.sort.join('_')
          next if visited.include? visit
          visited << visit

          orig_outputs = out_names.to_h { [_1, $outputs[_1]] } # save connections

          out_names.each_slice(2) do |o1, o2|
            $outputs[o1] = orig_outputs[o2]
            $outputs[o2] = orig_outputs[o1]
          end

          found = true

          tests.each do |x, y|
            $outputs.each_value(&:reset) # clear outputs and recompute
            set_input('x', x)
            set_input('y', y)
            z = read_number('z')
            if x + y != z
              found = false
              break
            end
          end

          return out_names if found
        rescue Output::Cycle # Ignore cyclical errors and continue
        ensure
          $outputs.merge!(orig_outputs) # reset back to original
        end
      end
    end
  end
end

# Part 1
$outputs = read_input
puts read_number('z')

write_graph

# Part 2
bad_outputs = find_bad_outputs

# Output must be product of XOR, otherwise it's a bad output
required = bad_outputs.select { |out| $outputs[out].op != 'XOR' }

# Required outputs to swap will never be swapped with one of their upstreams,
# but with an upstream of the next output
upstreams = (bad_outputs-required).to_h { [_1, upstream_nodes(_1)] }
groups = []
required.each do |out|
  succ = out.next
  groups <<  [out] + upstreams.delete(succ) if upstreams[succ]
end
# Observed solutions always include 3 output values that need swapping,
# so group the remaining together as a final group
groups << upstreams.values.flatten

# This dramatically increases the search space if for some reason there
# are fewer than 3 output values that need swapping
if groups.size < 4
  (4-groups.size).times do
    groups << groups.last
  end
end

nodes_to_swap = find_swapped_outputs(groups)

puts nodes_to_swap.sort.join(',')

write_graph(nodes_to_swap)
