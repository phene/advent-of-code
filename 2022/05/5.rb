#!/usr/bin/env ruby

class Cargo
  def initialize(cargo)
    @cargo = cargo
  end

  def remove(quantity, column)
    crates = []
    quantity.times do
      @cargo.each_with_index do |row, r|
        next if row[column] == '0'
        crates << row[column]
        row[column] = '0'
        break
      end
    end
    crates
  end

  def add(crates, column)
    crates.each do |crate|
      pos = @cargo.size-1
      @cargo.each_with_index do |row, r|
        next if row[column] == '0'
        pos = r-1
        break
      end
      if pos == -1
        @cargo.unshift(['0'] * @cargo.first.size)
        pos = 0
      end
      @cargo[pos][column] = crate
    end
  end

  def top
    crates = ['0'] * @cargo.first.size
    @cargo.each do |row|
      row.each_with_index do |crate, c|
        next if crate == '0'
        next if crates[c] != '0'
        crates[c] = crate
      end
    end
    crates
  end

  def print
    @cargo.each do |row|
      puts row.inspect
    end
    puts
  end

  def dup
    Cargo.new(@cargo.map { _1.dup })
  end
end

reading_cargo = true
cargo_lines = []
instructions = []

$stdin.readlines.each do |line|
  line = line.chomp
  if line.empty?
    reading_cargo = false
  elsif reading_cargo
    cargo_lines << line.chars.each_slice(4).map do |chrs|
      item = chrs.find { _1.match?(/\w/) }
      next item if item
      '0'
    end
  else
    instructions << line.scan(/\d+/).map(&:to_i)
  end
end

width = cargo_lines.pop.size
cargo_lines.each do |row|
  row.concat(['0'] * (width-row.size))
end

cargo = Cargo.new(cargo_lines)
cargo2 = cargo.dup

instructions.each do |quantity, from, to|
  crates = cargo.remove(quantity, from-1)
  cargo.add(crates, to-1)
end

#cargo.print
puts cargo.top.join('')

instructions.each do |quantity, from, to|
  crates = cargo2.remove(quantity, from-1).reverse
  cargo2.add(crates, to-1)
end

#cargo2.print
puts cargo2.top.join('')
