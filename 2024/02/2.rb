#!/usr/bin/env ruby

reports = []

$stdin.readlines.each do |line|
  reports << line.strip.split(/\s+/).map(&:to_i)
end

def report_safe?(report)
  ascending = report[0] < report[1]
  report.each_with_index do |d2, i|
    next if i == 0
    d1 = report[i-1]
    return false if ascending && d1 >= d2 or !ascending && d2 >= d1 or (d1-d2).abs > 3
  end
  true
end

def report_safe_without_level?(report)
  (0...report.size).each do |i|
    return true if report_safe?(report[0...i] + report[i+1..])
  end
  false
end

safe_count, safe_count2 = [0, 0]
reports.each do |report|
  safe_count += 1 if report_safe?(report)
  safe_count2 += 1 if report_safe_without_level?(report)
end
puts safe_count, safe_count2
