#!/usr/bin/env ruby

PRUNE = 16777216

def next_secret(s)
  a = ((s << 6) ^ s) % PRUNE
  b = ((a >> 5) ^ a) % PRUNE
  ((b << 11) ^ b) % PRUNE
end

def last_digit(n) = n.to_s[-1].to_i

def sequence_sum(histories, sequence_indexes, seq)
  histories.inject(0) do |s, (init, history)|
    next s unless i = sequence_indexes[init][seq]
    s + history[i]
  end
end

def find_sum_with_best_sequence(histories, sequence_indexes)
  visited = Set[]
  sequence_indexes.each_value.inject(0) do |best, indexes|
    indexes.each_key.inject(best) do |b, seq|
      next b if visited.include? seq
      visited << seq
      [b, sequence_sum(histories, sequence_indexes, seq)].max
    end
  end
end

def generate_sequence_indexes(changes)
  indexes = {}
  changes.each_cons(4).each_with_index do |seq, i|
    indexes[seq] = i + 4 unless indexes[seq]
  end
  indexes
end

initial_secrets = $stdin.readlines.map(&:to_i)
last_secret_sum = 0
histories = {}
sequence_indexes = {}
initial_secrets.each do |s|
  initial = s
  history = [last_digit(s)]
  changes = []
  2000.times do
    s = next_secret(s)
    history << last_digit(s)
    changes << history[-1] - history[-2]
  end
  histories[initial] = history
  sequence_indexes[initial] = generate_sequence_indexes(changes)
  last_secret_sum += s
end
puts last_secret_sum
puts find_sum_with_best_sequence(histories, sequence_indexes)
