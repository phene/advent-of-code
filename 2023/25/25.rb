#!/usr/bin/env ruby

Edge = Struct.new(:src, :dest) do
  def ==(other)
    # unidirectional
    (self.src == other.src && self.dest = other.desc) || (self.src == other.dest && self.dest == other.src)
  end

  def to_s
    "#{self.src}-#{self.dest}"
  end
end

Graph = Struct.new(:nodes, :edges)
Subset = Struct.new(:parent, :rank)

node_map = Hash.new { |h, k| h[k] = Set.new }
graph = Graph.new(Set.new, Set.new)

$stdin.readlines.map(&:chomp).map do |line|
  node, *neighbors = line.tr(':', '').split(' ')
  graph.nodes << node
  neighbors.each do |neighbor|
    node_map[node] << neighbor
    node_map[neighbor] << node
    graph.nodes << neighbor
    graph.edges << Edge.new(node, neighbor)
  end
end

graph.nodes = graph.nodes.to_a
graph.edges = graph.edges.to_a

def cut(node_map, node1, node2)
  node_map[node1].delete node2
  node_map[node2].delete node1
end

def subgraphs_product(node_map)
  visited = Set.new
  traverse = [node_map.keys.first]
  while traverse.any?
    node = traverse.shift
    next if visited.include? node
    visited << node
    traverse += node_map[node].to_a
  end
  (node_map.size - visited.size) * visited.size
end

def brute_find_cuts(graph)
  graph.keys.combination(2) do |n1, n2|
    graph.keys.combination(2) do |n3, n4|
      next if Set.new([n1, n2, n3, n4]).size < 3
      graph.keys.combination(2) do |n5, n6|
        next if Set.new([n1, n2, n3, n4, n5, n6]).size < 4
        test_graph = dup_graph(graph)
        cut(test_graph, n1, n2)
        cut(test_graph, n3, n4)
        cut(test_graph, n5, n6)
        size = subgraph_size(test_graph)
        return size * (graph.size - size) if size != graph.size
      end
    end
  end
end

def find(subsets, n)
  subsets[n].parent = find(subsets, subsets[n].parent) if subsets[n].parent != n
  subsets[n].parent
end

def union(subsets, x, y)
  xroot = find(subsets, x)
  yroot = find(subsets, y)

  if subsets[xroot].rank < subsets[yroot].rank
    subsets[xroot].parent = yroot
  elsif subsets[xroot].rank > subsets[yroot].rank
    subsets[yroot].parent = xroot
  else
    subsets[yroot].parent = xroot
    subsets[xroot].rank += 1
  end
end

# Karger’s algorithm for Minimum Cut
# Borrowed heavily from https://www.geeksforgeeks.org/introduction-and-implementation-of-kargers-algorithm-for-minimum-cut/
def min_cut(graph)
  node_count = graph.nodes.size
  edges = graph.edges

  subsets = {}

  graph.nodes.each do |n|
    subsets[n] = Subset.new(n, 0)
  end

  while node_count > 2
    edge = edges.sample
    subset1 = find(subsets, edge.src)
    subset2 = find(subsets, edge.dest)

    next if subset1 == subset2
    node_count -= 1
    union(subsets, subset1, subset2)
  end

  cut_edges = []
  edges.each do |edge|
    subset1 = find(subsets, edge.src)
    subset2 = find(subsets, edge.dest)
    cut_edges << edge if subset1 != subset2
  end
  cut_edges
end

cut_edges = []
cut_edges = min_cut(graph) until cut_edges.size == 3
cut_edges.each do |edge|
  cut(node_map, edge.src, edge.dest)
end
puts subgraphs_product(node_map)
