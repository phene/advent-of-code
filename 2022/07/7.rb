#!/usr/bin/env ruby

cwd = []
files = {}
$stdin.readlines.each do |line|
  line.chomp!
  if line.start_with?('$')
    if line.start_with?('$ cd ')
      next_dir = line.split(' ')[2]
      if next_dir == '/'
        cwd = []
      elsif next_dir == '..'
        cwd.pop
      else
        cwd.push next_dir
      end
    end
  elsif !line.start_with?('dir')
    size, file = line.split(' ')
    file_dir = cwd.empty? ? file : cwd.join('/') + '/' + file
    files[file_dir] = size.to_i
  end
end

directory_sizes = Hash.new(0)
files.each do |file, size|
  parts = file.split('/')
  parts.pop
  directory_sizes['/'] += size
  parts.size.downto(1).each do |n|
    directory_sizes[parts[0...n]] += size
  end
end

puts directory_sizes.sum { |dir, size|
  next 0 if size > 100_000
  size
}

total_disk = 70_000_000
target_available = 30_000_000
available_disk = total_disk - directory_sizes['/']
target_removal = target_available - available_disk
disk_size_to_delete = directory_sizes['/']
directory_sizes.each do |dir, size|
  disk_size_to_delete = [size,disk_size_to_delete].min if size >= target_removal
end
puts disk_size_to_delete
