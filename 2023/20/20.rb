#!/usr/bin/env ruby

class StateMachine
  attr_accessor :signals, :elements, :broadcast_counter

  def initialize(elements)
    @signals = Hash.new(0)
    @elements = elements.to_h do |element|
      [element.name, element]
    end
    @elements.each_value do |element|
      element.wire_up! self
    end
    @signal_queue = []
    @listeners = []
    @broadcast_counter = 0
  end

  def listen_for_signal(target, signal, &block)
    @listeners << [target, signal, block]
  end

  def send_signal(target, source, signal)
    @signal_this_tick = true
    @signals[signal] += 1
    #puts "#{source} -#{signal}-> #{target}"
    @signal_queue << [target, source, signal]

    @listeners.each do |t, s, blk|
      next unless target == t and signal == s
      blk.call(t, s)
    end
  end

  def deliver_signals
    @signal_queue.each do |target, source, signal|
      elements[target]&.send_signal(signal, source)
    end
    @signal_queue = []
  end

  def trigger_broadcast
    send_signal('broadcaster', 'button', :low)
    @broadcast_counter += 1
  end

  def run
    trigger_broadcast
    deliver_signals while @signal_queue.any?
  end

  def reset
    @broadcast_counter = 0
    @listeners = []
    @signal_queue = []
    @elements.each_value do |element|
      element.wire_up! self
    end
  end

  def result
    @signals.values.inject(1, &:*)
  end
end

class Element
  attr_reader :name, :outputs, :state_machine

  def initialize(name, outputs)
    @name = name
    @outputs = outputs
  end
end

class Broadcaster < Element
  def wire_up!(state_machine)
    @state_machine = state_machine
  end

  def send_signal(signal, source)
    outputs.each do |output|
      state_machine.send_signal(output, name, signal)
    end
  end
end

class FlipFlop < Element
  attr_accessor :state

  def wire_up!(state_machine)
    @state_machine = state_machine
    reset
  end

  def send_signal(signal, source)
    return unless signal == :low

    @state = !@state

    outputs.each do |output|
      state_machine.send_signal(output, name, state ? :high : :low)
    end
  end

  def reset
    @state = false
  end
end

class Conjunction < Element
  attr_reader :input_states

  def wire_up!(state_machine)
    @state_machine = state_machine
    reset
  end

  def reset
    @input_states = {}
    state_machine.elements.each_value do |element|
      @input_states[element.name] = :low if element.outputs.include? name
    end
  end

  def output_signal
    @input_states.each_value.all?(:high) ? :low : :high
  end

  def send_signal(signal, source)
    @input_states[source] = signal

    out_sig = output_signal
    outputs.each do |output|
      state_machine.send_signal(output, name, out_sig)
    end
  end
end

elements = []

$stdin.readlines.lazy.map(&:chomp).each do |line|
  source, outputs = line.split(' -> ')
  outputs = outputs.split(/\s?,\s?/)
  if source == 'broadcaster'
    elements << Broadcaster.new(source, outputs)
  elsif source.start_with? '%'
    elements << FlipFlop.new(source[1..], outputs)
  else
    elements << Conjunction.new(source[1..], outputs)
  end
end

state_machine = StateMachine.new(elements)

# Part 1
1000.times do
  state_machine.run
end

puts state_machine.result

# Part 2

# From input file, these are the inputs to xm, which inverts into rx
# when xm receives a high signals from all of these (which is when
# they each receive a low signal) it will send the desired low signal to rx
FINAL_CONS = %w[sv ng ft jz]
runs = FINAL_CONS.map do |con|
  res = 0
  state_machine.reset
  state_machine.listen_for_signal(con, :low) do |c, s|
    res = state_machine.broadcast_counter
  end
  loop do
    state_machine.run
    break if res > 0
  end
  res
end.inject(1, &:lcm)

puts runs
