#!/usr/bin/env ruby
require_relative '../range'

class Rule
  attr_reader :category, :condition, :destination

  def initialize(category, condition, destination)
    @category = category
    @condition = condition
    @destination = destination
  end

  def satisfied?(part)
    return true if @category.nil? # Catch-all rule
    return @condition.cover? part.attributes[@category].rating
  end

  def to_s
    if @category.nil?
      @destination
    else
      "#{@category}=#{@condition}:#{@destination}"
    end
  end

  def negate
    n_cond =
      if @condition.begin == Attribute::MIN_RATING
        (@condition.max + 1)..Attribute::MAX_RATING
      else
        Attribute::MIN_RATING...@condition.begin
      end
    Rule.new(@category, n_cond, '--')
  end
end

class Part
  attr_reader :attributes
  def initialize(attributes)
    @attributes = attributes
  end
  def value
    @attributes.values.sum(&:rating)
  end
end

class Attribute
  MAX_RATING = 4_000
  MIN_RATING = 1
  TYPES = %w[x m a s]
  attr_reader :type, :rating
  def initialize(type, rating)
    @type = type
    @rating = rating.to_i
  end
  def to_s
    "#{@type}=#{@rating}"
  end
end

class Workflow
  attr_reader :name
  attr_reader :rules

  def initialize(name, rule_strs)
    @name = name
    @rules = parse(rule_strs)
  end

  def process(part)
    rule = @rules.find { |r| r.satisfied?(part) }
    rule.destination
  end

  def destinations
    rules.map(&:destination)
  end

  def parse(rule_strs)
    rule_strs.map do |rule|
      cond, dest = rule.split(':')
      if dest.nil?
        Rule.new(nil, ..nil, cond)
      else
        if cond.include? '<'
          part, limit = cond.split('<')
          Rule.new(part, Attribute::MIN_RATING...(limit.to_i), dest)
        else
          part, limit = cond.split('>')
          Rule.new(part, (limit.to_i + 1)..Attribute::MAX_RATING, dest)
        end
      end
    end
  end

  def to_s
    "#{name}{#{rules.map(&:to_s).join(',')}}"
  end
end

def read_workflow_and_parts
  workflows = {}
  parts = []
  line_is_workflow = true

  $stdin.readlines.lazy.map(&:chomp).each do |line|
    if line.empty?
      line_is_workflow = false
    elsif line_is_workflow
      # px{a<2006:qkq,m>2090:A,rfg}
      name, *rules = line.split(/\{|,|\}/)
      workflows[name] = Workflow.new(name, rules)
    else
      # {x=787,m=2655,a=1222,s=2876}
      attrs = line.split(/\{|,|\}/).map do |attr_info|
        next if attr_info.empty?
        type, rating = attr_info.split('=')
        [type, Attribute.new(type, rating)]
      end.compact.to_h
      parts << Part.new(attrs)
    end
  end

  [workflows, parts]
end

def part1_process_parts(workflows, parts)
  accepted_parts = []

  parts.each do |part|
    workflow_name = 'in'
    until workflow_name == 'A' or workflow_name == 'R'
      workflow_name = workflows[workflow_name].process(part)
    end
    case workflow_name
    when 'A'
      accepted_parts << part
    end
  end

  accepted_parts.sum(&:value)
end

def reduce_workflows(workflows)
  workflows.each do |name, workflow|
    case workflow.rules.last.destination
    when 'A', 'R'
      # nothing
    else
      other_wf = workflow.rules.pop # drop last rules
      workflow.rules.concat workflows[other_wf.destination].rules
    end
  end

  workflows.delete_if do |name, _|
    next false if name == 'in'
    workflows.each_value.none? { |wf| wf.destinations.include? name }
  end
end

def workflow_paths(workflows)
  accepted_paths = []
  rejected_paths = []
  partial_paths = [ [[], 'in'] ]

  while partial_paths.any?
    rules, next_wf = partial_paths.shift

    if next_wf == 'A'
      accepted_paths << [rules, next_wf]
      next
    elsif next_wf == 'R'
      rejected_paths << [rules, next_wf]
      next
    end

    wf = workflows[next_wf]
    wf.rules.each_with_index do |rule, idx|
      next_rules = wf.rules[0...idx].map(&:negate)
      partial_paths << [rules + next_rules + [rule], rule.destination]
    end
  end

  [accepted_paths, rejected_paths]
end

def range_sets_from_paths(paths)
  paths.map do |rules, dest|
    ranges = Hash.new { |h, k| h[k] = [] }
    rules.each do |rule|
      next if rule.category.nil?
      ranges[rule.category] << rule.condition
    end
    ranges.transform_values! do |rs|
      rs = rs[1..].inject([rs[0]]) do |all, r|
        all.flat_map do |r2|
          r.intersection(r2)
        end
      end
      next rs.first if rs.size == 1
      rs
    end
    Attribute::TYPES.each do |type|
      ranges[type] = Attribute::MIN_RATING..Attribute::MAX_RATING if ranges[type] == []
    end
    ranges
  end
end

def merge_ranges(ranges)
  new_ranges = []
  indexes_merged = []
  ranges.each_with_index do |range, idx|
    next if indexes_merged[idx]
    ranges[(idx + 1)..].each_with_index do |other_range, other_idx|
      if range.all? { |c, r| other_range[c].intersect_with?(r) }
        indexes_merged[other_idx] = true
        range = range.map do |c, rs|
          [c, other_range[c].merge(rs).first]
        end.to_h
      end
    end
    new_ranges << range
    indexes_merged[idx] = true
  end
  new_ranges
end

def sum_combinations(ranges)
  ranges.sum do |range|
    range.values.inject(1) do |prod, r|
      prod * r.size
    end
  end
end

# Part 1
workflows, parts = read_workflow_and_parts
puts part1_process_parts(workflows, parts)

# Part 2
accepted_paths, _ = workflow_paths(workflows)
accepted_ranges = range_sets_from_paths(accepted_paths)

accepted_ranges = merge_ranges(merge_ranges(merge_ranges(accepted_ranges)))
puts sum_combinations(accepted_ranges)
