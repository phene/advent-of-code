#!/usr/bin/env ruby

class BluePrint
  ROBOT_TYPES = %i[ore clay obsidian geode]
  attr_accessor :id, :costs, :storage, :robots, :max_robots

  def initialize(id, costs:, storage: Hash.new(0), robots: Hash.new(0), max_robots: nil)
    @id = id
    @costs = costs
    @storage = storage
    @robots = robots
    @max_robots = max_robots || %i[ore clay obsidian].to_h do |mineral_type|
      [mineral_type, ROBOT_TYPES.map { @costs[_1][mineral_type] || 0 }.max]
    end
  end

  def can_build?(robot_type)
    @costs[robot_type].all? do |mineral_type, cost|
      @storage[mineral_type] >= cost
    end
  end

  def build(robot_type)
    self.class.new(
      @id,
      costs: @costs,
      storage: collect.tap do |storage|
        next if robot_type == :none
        @costs[robot_type].each do |mineral_type, cost|
          storage[mineral_type] -= cost
        end
      end,
      robots: @robots.dup.tap do
        next if robot_type == :none
        _1[robot_type] += 1
      end,
      max_robots: @max_robots
    )
  end

  def decisions(time_left)
    return [build(:none)] if time_left == 1
    return [build(:geode)] if can_build? :geode
    return [build(:obsidian), build(:none)] if can_build? :obsidian and @robots[:obsidian] < @max_robots[:obsidian]

    options = [build(:none)]
    options << build(:clay) if can_build?(:clay) and @robots[:clay] < @max_robots[:clay]
    options << build(:ore) if can_build?(:ore) and @robots[:ore] < @max_robots[:ore]
    options
  end

  def inspect
    "<BluePrint @id=#{@id} @storage=#{@storage.inspect} @robots=#{@robots.inspect}>"
  end

  def collect(store = @storage.dup)
    ROBOT_TYPES.each_with_object(store) do |type, new_store|
      new_store[type] += @robots[type]
    end
  end

  def quality_level
    @id * @storage[:geode]
  end

  def most_possible_geodes(time_left)
    @storage[:geode] + @robots[:geode] * time_left + ((time_left * (time_left) - 1) / 2)
  end

  def self.read_input
    $stdin.readlines.map do |line|
      id, ore_r_cost, clay_r_cost, \
        obsidian_r_ore_cost, obsidian_r_clay_cost, \
        geode_r_ore_cost, geode_r_obsidian_cost = line.scan(/(\d+)/).flatten.map(&:to_i)
      BluePrint.new(
        id,
        costs: {
          ore: {
            ore: ore_r_cost,
          },
          clay: {
            ore: clay_r_cost,
          },
          obsidian: {
            ore: obsidian_r_ore_cost,
            clay: obsidian_r_clay_cost,
          },
          geode: {
            ore: geode_r_ore_cost,
            obsidian: geode_r_obsidian_cost,
          },
        },
        robots: {
          ore: 1,
          clay: 0,
          obsidian: 0,
          geode: 0,
        }
      )
    end
  end
end

def bfs(start, max_time = 24)
  stack = [[start, max_time]]
  best = start
  visited = Set[]
  best_geode_times = Hash.new(0)

  while stack.any?
    bp, time_left = stack.pop
    visit = [bp.storage.values, bp.robots.values, time_left]

    if time_left == 0
      if bp.storage[:geode] > best.storage[:geode]
        best = bp
      end
      next
    # elsif bp.most_possible_geodes(time_left) < best.storage[:geode]
    #   next
    elsif bp.storage[:geode] < best_geode_times[time_left]
      next
    elsif visited.include? visit
      next
    end
    visit << visit

    if bp.storage[:geode] > best_geode_times[time_left]
      best_geode_times[time_left] = bp.storage[:geode]
    end

    bp.decisions(time_left).each do |new_bp|
      stack.push [new_bp, time_left-1]
    end
  end
  puts "Best: #{best.inspect}"
  best
end

blueprints = BluePrint.read_input
best_blueprints = blueprints.map { bfs(_1) }
puts best_blueprints.sum(&:quality_level)
