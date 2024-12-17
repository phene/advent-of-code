#!/usr/bin/env ruby

def readregister(line) = line.split(': ').last.to_i
def combo(operand, registers) = operand > 3 ? registers[operand-4] : operand
def opcode_name(code) = %w[adv bxl bst jnq bxc out bdv cdv][code]
def operate(ip, opcode, operand, registers, output)
  case opcode
  when 0 # adv
    registers[0] = registers[0] >> combo(operand, registers)
  when 1 # bxl
    registers[1] ^= operand
  when 2 # bst
    registers[1] = combo(operand, registers) % 8
  when 3 # jnz
    return operand if registers[0] != 0
  when 4 # bxc
    registers[1] ^= registers[2]
  when 5 # out
    output << combo(operand, registers) % 8
  when 6 # bdv
    registers[1] = registers[0] >> combo(operand, registers)
  else # when 7 # cdv
    registers[2] = registers[0] >> combo(operand, registers)
  end
  ip + 2
end

def run_program(program, registers)
  ip = 0
  output = []
  while program[ip]
    opcode, operand = program[ip], program[ip+1]
    ip = operate(ip, opcode, operand, registers, output)
  end
  output
end

def run_a(program, registers, a)
  reg = registers.dup
  reg[0] = a
  run_program(program, reg)
end

# Search by chunks of octets, where leading octets correspond to reverse order of outputs
def search_a(program, registers)
  queue = (0..7).to_a
  while queue.any?
    possible_a = queue.shift
    return possible_a if run_a(program, registers, possible_a) == program
    (0..7).each do |i|
      a = (possible_a << 3) + i
      queue << a if run_a(program, registers, a) == program[-((a.bit_length/3)+1)..]
    end
  end
end

registers = (1..3).map { readregister $stdin.readline }
$stdin.readline # Burn empty line
program = $stdin.readline.split(': ').last.split(',').map(&:to_i)

puts run_program(program, registers.dup).map(&:to_s).join(',')
puts search_a(program, registers)
