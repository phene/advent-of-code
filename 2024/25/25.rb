#!/usr/bin/env ruby

MAX_BIDDING = 7

def compute_bidding(key_or_lock)
  (0...key_or_lock.first.size).map do |i|
    key_or_lock.count do |row|
      row[i] == '#'
    end
  end
end

def lock_or_key(lock_or_key, locks, keys)
  if lock_or_key.first.all? '#'
    locks << compute_bidding(lock_or_key)
  else
    keys << compute_bidding(lock_or_key)
  end
end

def read_input
  keys, locks = [[], []]
  current = []
  $stdin.readlines.each do |line|
    line = line.chomp
    if line.empty?
      lock_or_key(current, locks, keys)
      current = []
    else
      current << line.chars
    end
  end
  lock_or_key(current, locks, keys)
  [keys, locks]
end

keys, locks = read_input
pairs = keys.sum do |key|
  locks.count do |lock|
    key.each_with_index.all? do |bidding, pin|
      bidding + lock[pin] <= MAX_BIDDING
    end
  end
end
puts pairs
