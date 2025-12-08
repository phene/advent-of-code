#!/usr/bin/env ruby

require 'matrix'
V = Vector
class Vector
  def x = self[0]
  def y = self[1]
  def z = self[2]
end

MAX_CONNECTIONS = 1000

def all_connected(connections, coord)
  seen = {}
  to_visit = [coord]

  until to_visit.empty?
    current = to_visit.pop
    next if seen[current]

    seen[current] = true
    to_visit.concat(connections[current])
  end

  seen.keys
end

def sorted_pairs(coords)
  pairs = coords.combination(2).to_a
  pairs.sort_by { |(a, b)| (a - b).magnitude }
end

def fetch_circuits(coords, connections)
  in_circuit = {}
  circuits = {}
  circuit_count = 1

  coords.each do |coord|
    if in_circuit[coord]
      next
    end
    circuit = all_connected(connections, coord)
    circuits[circuit_count] = circuit
    circuit.each do |connected_coord|
      in_circuit[connected_coord] = true
    end
    circuit_count += 1
  end
  circuits
end

coords = $stdin.readlines.map do |line|
  V[*line.split(',').map(&:to_i)]
end

pairs = sorted_pairs(coords)

connections = Hash.new { |h, k| h[k] = [] }
pairs.first(MAX_CONNECTIONS).each do |pair|
  connections[pair[0]] << pair[1]
  connections[pair[1]] << pair[0]
end

circuits = fetch_circuits(coords, connections)
puts circuits.values.map(&:size).sort.last(3).inject(1, &:*)

# Continue connecting until all are connected
pairs[MAX_CONNECTIONS..].each do |pair|
  connections[pair[0]] << pair[1]
  connections[pair[1]] << pair[0]

  circuits = fetch_circuits(coords, connections)
  if circuits.size == 1
    puts pair[0].x * pair[1].x
    break
  end
end
