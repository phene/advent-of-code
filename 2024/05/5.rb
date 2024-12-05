#!/usr/bin/env ruby

page_deps = Hash.new { |h, k| h[k] = [] }
page_updates = []
$stdin.readlines.each do |line|
  if line.include? '|'
    a, b = line.split('|').map(&:to_i)
    page_deps[a] << b
  elsif line.include? ','
    page_updates << line.split(',').map(&:to_i)
  end
end

total1, total2 = [0, 0]
page_updates.each do |pages|
  sorted_pages = pages.sort do |a, b|
    page_deps[a].include?(b) ? -1 : 1
  end
  middle_page = sorted_pages[pages.size/2]
  if sorted_pages == pages
    total1 += middle_page
  else
    total2 += middle_page
  end
end

puts total1, total2
