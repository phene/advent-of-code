#!/usr/bin/env ruby

require 'pairing_heap'

def scores(valves, opened)
  opened.sum { |ov, t| valves[ov][:rate] * t }
end

def flow_rate(valves, opened)
  opened.sum { |ov, _| valves[ov][:rate] }
end

def push(queue, item, priority)
  queue.push item, priority
end

@distances = {}
def distance(valves, v1, v2)
  return 0 if v1 == v2
  key = [v1,v2].sort.join('-')
  @distances[key] ||= begin
    queue = valves[v1][:to].map { |v| [v, 1] }
    visited = Set[]
    dist = 0
    while queue.any?
      v, d = queue.shift
      if v == v2
        dist = d
        break
      end
      next if visited.include? v
      visited << v
      valves[v][:to].each do |nv|
        queue << [nv, d+1]
      end
    end
    dist
  end
end

def open_valves(valves, start = 'AA', max_time = 30)
  queue = PairingHeap::MaxPriorityQueue.new
  push queue, [start, 0, {}, max_time], 0

  valves.each_key do |v1|
    valves.each_key do |v2|
      distance(valves, v1, v2)
    end
  end

  best = Hash.new(-1)
  best_val = -1

  while queue.any?
    v, bm, opened, time = queue.pop
    score = scores(valves, opened)

    next if best[bm] > score
    best[bm] = score

    queued = false
    valves.each_key do |nv|
      next if opened.key?(nv)
      nt = time - distance(valves, v, nv) - 1
      next unless nt >= 0
      new_opened = opened.merge(nv => nt)
      new_score = scores(valves, new_opened)
      new_bm = bm | valves[nv][:bitmask]
      next if new_score < best[new_bm]
      queued = true
      push queue, [nv, new_bm, new_opened, nt], new_score
    end
    best_val = score if !queued and score > best_val
  end

  best_val
end


valves = $stdin.readlines.each_with_index.to_h do |line, index|
  m = line.match(/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ((?:\w+,? ?)+)/)
  [m[1], {
    bitmask: (1 << index),
    rate: m[2].to_i,
    to: m[3].split(', ')
  }]
end

# Part 1
puts open_valves(valves, 'AA')
