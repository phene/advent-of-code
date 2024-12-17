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
  when 7 # cdv
    registers[2] = registers[0] >> combo(operand, registers)
  else
    raise "Invalid opcode #{opcode}"
  end
  ip + 2
end

def log(msg)
  puts msg
end

def run_program(program, registers)
  ip = 0
  output = []
  while program[ip]
    opcode, operand = program[ip], program[ip+1]
    log "#{opcode_name(opcode)} #{operand} #{registers.map{ _1.to_s(2).ljust(30) }.join(' ')}"
    ip = operate(ip, opcode, operand, registers, output)
  end
  log registers.map{ _1.to_s(2).ljust(30) }
  output
end

registers = (1..3).map { readregister $stdin.readline }
$stdin.readline

program = $stdin.readline.split(': ').last.split(',').map(&:to_i)

puts run_program(program, registers.dup).join(',')
