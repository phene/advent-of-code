#!/usr/bin/env ruby

SLOPES = {
  [1, 0] => '>',
  [0, 1] => 'v',
  [-1, 0] => '<',
  [0, -1] => '^',
}
NEIGHBORS = SLOPES.keys

Node = Struct.new(:id, :position, :edges) do
  def ==(other)
    self.id == other.id
  end
end

Edge = Struct.new(:from, :to, :distance) do
  def ==(other)
    self.from == other.from and self.to == other.to
  end
end

grid = $stdin.readlines.map(&:chomp).map(&:chars)
start = [grid.first.index('.'), 0]
finish = [grid.last.index('.'), grid.size - 1]

def build_graph(grid, start, finish, &valid_step)
  start_node = Node.new('start', start, Set.new)
  finish_node = Node.new('finish', finish, Set.new)
  nodes = {
    start => start_node,
    finish => finish_node,
  }
  x_range, y_range = 0...grid.first.size, 0...grid.size
  node_id = 1

  positions = [[start_node, start, Set.new([start]), 0]]

  while positions.any?
    last_node, (x, y), visited, d = positions.shift

    paths = NEIGHBORS.map do |dx, dy|
      nx, ny = x + dx, y + dy
      next unless x_range.cover? nx and y_range.cover? ny
      next if visited.include? [nx, ny]
      next unless valid_step.call(grid[ny][nx], dx, dy)
      [nx, ny]
    end.compact

    if paths.size == 1
      pos = paths.first
      next_node = nodes[pos]

      if next_node
        last_node.edges << Edge.new(last_node, next_node, d + 1)
      else
        positions << [last_node, pos, visited + [pos], d + 1]
      end
    elsif paths.size > 1
      next if nodes[[x, y]]

      next_node = Node.new(node_id, [x, y], Set.new)
      node_id += 1
      last_node.edges << Edge.new(last_node, next_node, d)
      nodes[next_node.position] = next_node

      # Need to backtrack on new node creation to verify edge back to previous node is valid
      backtrack_pos = NEIGHBORS.map do |dx, dy|
        nx, ny = x + dx, y + dy
        next unless x_range.cover? nx and y_range.cover? ny
        next unless visited.include? [nx, ny]
        next unless valid_step.call(grid[ny][nx], dx, dy)
        [nx, ny]
      end.compact.first

      positions << [next_node, backtrack_pos, Set.new([backtrack_pos]), 1] if backtrack_pos

      paths.each do |pos|
        positions << [next_node, pos, visited + [pos], 1]
      end
    end
  end

  [start_node, finish_node]
end

def search_graph(start_node, finish_node)
  positions = [[start_node, Set.new([start_node]), 0]]
  max_distance = 0

  while positions.any?
    node, visited, distance = positions.pop

    if node == finish_node
      max_distance = [distance, max_distance].max
      next
    end

    node.edges.each do |edge|
      next if visited.include? edge.to
      positions << [edge.to, visited + [edge.to], distance + edge.distance]
    end

    positions.sort_by(&:last)
  end

  max_distance
end

# Part 1
start_node, finish_node = build_graph(grid, start, finish) do |step, dx, dy|
  step == '.' or step == SLOPES[[dx, dy]]
end
puts search_graph(start_node, finish_node)

# Part 2
start_node, finish_node = build_graph(grid, start, finish) do |step, dx, dy|
  step != '#'
end
puts search_graph(start_node, finish_node)
