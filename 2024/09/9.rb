#!/usr/bin/env ruby

def checksum(disk)
  sum = 0
  disk.each_with_index do |chunk, index|
    sum += chunk * index if chunk != -1
  end
  sum
end

def compact(disk, whole_chunk = false)
  new_disk = disk.dup
  chunk_index = new_disk.size
  while chunk_index > 0
    chunk_index = chunk_index.pred
    next if new_disk[chunk_index] == -1
    chunk_size = 1
    chunk = new_disk[chunk_index]

    if whole_chunk
      # Find size and beginning of chunk
      while new_disk[chunk_index - 1] == chunk do
        chunk_index = chunk_index.pred
        chunk_size = chunk_size.succ
      end
      break if chunk_index == 0
    end

    space_index = 0
    while space_index < chunk_index
      bad_index = (space_index+chunk_size-1).downto(space_index).first { |i| new_disk[i] != -1 }

      if bad_index.nil?
      #if new_disk[space_index, chunk_size].all?(-1) # (space_index...(space_index+chunk_size)).all? { |i| new_disk[i] == -1 }
        (0...chunk_size).each do |offset|
          new_disk[space_index + offset] = chunk
          new_disk[chunk_index + offset] = -1
        end
        break
      end
      space_index = bad_index.succ
    end

  end
  new_disk
end

disk = []
$stdin.readline.chomp.chars.each_with_index do |size, index|
  if index % 2 == 0
    disk += [index/2] * size.to_i
  else
    disk += [-1] * size.to_i
  end
end

new_disk = compact(disk)
puts checksum(new_disk)

new_disk = compact(disk, true)
puts checksum(new_disk)
