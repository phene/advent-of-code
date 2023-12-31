#!/usr/bin/env ruby

def read_bricks
  max_dimension = [0, 0, 0]

  bricks = $stdin.readlines.map(&:chomp).map do |line|
    front, back = line.split('~').map { |coords| coords.split(',').map(&:to_i) }
    dimension = (0..2).find { |d| front[d] != back[d] } || 0 # Zero in case of single-block bricks
    front, back = back, front if front[dimension] > back[dimension] # order by changing dimension
    max_dimension = max_dimension.each_with_index.map { |m, d| [m, front[d], back[d]].max } # Update max dimensions
    (front[dimension]..back[dimension]).map do |v|
      front.dup.tap do |coord|
        coord[dimension] = v
      end
    end
  end

  # Max x and y equal to max of both
  max_dimension[0] = max_dimension[1] = [max_dimension[0], max_dimension[1]].max

  [bricks, max_dimension]
end

def print_space(space)
  space.reverse.each_with_index do |plane, z|
    puts space.size - z - 1
    plane.each_with_index do |row, y|
      puts row.map { |c| (c || '.').to_s }.join('')
    end
    puts '---'
  end
end

def build_space(max_x, max_y, max_z)
  (0..max_z).map do |z|
    (0..max_y).map do |y|
      [nil] * (max_x + 1)
    end
  end
end

def place_brick(space, brick, brick_id)
  brick.each do |x, y, z|
    space[z][y][x] = brick_id
  end
end

def place_bricks(space, bricks)
  bricks.each_with_index do |brick, id|
    place_brick(space, brick, id)
  end
end

def brick_can_fall?(space, bricks, brick_id)
  bricks[brick_id].all? do |x, y, z|
    next false if z <= 1 # z == 0 is floor, so it can't fall if it is at z == 1 either
    b = space[z - 1][y][x]
    b.nil? || b == brick_id # Empty or itself
  end
end

def fell_brick(space, bricks, brick_id)
  fallen = false
  while brick_can_fall?(space, bricks, brick_id)
    fallen = true
    place_brick(space, bricks[brick_id], nil) # Remove brick from old location
    bricks[brick_id] = bricks[brick_id].map { |x, y, z| [x, y, z - 1] } # Update location
    place_brick(space, bricks[brick_id], brick_id) # Re-add brick
  end
  fallen
end

def fell_bricks(space, bricks)
  fallen_bricks = Set.new
  space.each_with_index do |plane, z|
    # Find bricks on current plane
    brick_ids = plane.flat_map do |row|
      row.compact
    end.uniq

    while brick_ids.any? { |brick_id| brick_can_fall?(space, bricks, brick_id) }
      brick_ids.each do |brick_id|
        fallen_bricks << brick_id if fell_brick(space, bricks, brick_id)
      end
    end
  end
  fallen_bricks
end

def dup_space(space) = space.map { |plane| plane.map(&:dup) }
def dup_bricks(bricks) = bricks.map(&:dup)

bricks, (max_x, max_y, max_z) = read_bricks
space = build_space(max_x, max_y, max_z)
place_bricks(space, bricks)
fell_bricks(space, bricks)

# Part 1
fallen_bricks_per_brick = bricks.each_with_index.map do |brick, brick_id|
  test_space = dup_space(space)
  place_brick(test_space, brick, nil) # Remove brick
  fell_bricks(test_space, dup_bricks(bricks))
end
puts fallen_bricks_per_brick.count(&:none?)

# Part 2
puts fallen_bricks_per_brick.sum(&:size)
