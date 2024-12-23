#!/usr/bin/env ruby

def find_triples(connections)
  triples = Set[]
  visited = Set[]
  connections.each do |a, bs|
    bs.each do |b|
      next if visited.include? [a,b].sort
      visited << [a,b].sort
      connections[b].each do |c|
        next if a == c
        triples << [a, b, c].sort if bs.include? c
      end
    end
  end
  triples
end

def is_clique?(connections, nodes)
  nodes.all? do |n1|
    nodes.all? do |n2|
      n1 == n2 or connections[n1].include? n2
    end
  end
end

def largest_clique_with(connections, a)
  largest = []
  (connections[a].size+1).downto(1) do |size|
    ([a] + connections[a]).combination(size) do |clique|
      largest = clique if is_clique?(connections, clique) && clique.size > largest.size
      break if largest.size == size
    end
    break if largest.size == size
  end
  largest
end

def find_largest_clique(connections)
  largest_clique = []
  connections.each_key do |a|
    clique = largest_clique_with(connections, a)
    largest_clique = clique if clique.size > largest_clique.size
  end
  largest_clique
end

connections = Hash.new { |h,k| h[k] = [] }
$stdin.readlines.map do
  a, b, = _1.chomp.split('-')
  connections[a] << b
  connections[b] << a
end

triple_with_t_count = find_triples(connections).count do |triple|
  triple.any? { _1[0] == 't' }
end
puts triple_with_t_count
puts find_largest_clique(connections).sort.join(',')
