package main

import (
	"bufio"
	"math/bits"
	"os"
	"slices"
	"strconv"
	"strings"
)

func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func readRegister(str string) int {
	return atoi(strings.Split(str, ": ")[1])
}

func parseInput() ([]uint64, []int8) {
	scanner := bufio.NewScanner(os.Stdin)
	registers := make([]uint64, 3)
	for i := range 3 {
		scanner.Scan()
		registers[i] = uint64(readRegister(scanner.Text()))
	}
	scanner.Scan()
	scanner.Text()
	scanner.Scan()
	programDigits := strings.Split(strings.Split(scanner.Text(), ": ")[1], ",")
	program := make([]int8, len(programDigits))
	for i, d := range programDigits {
		program[i] = int8(atoi(d))
	}
	return registers, program
}

func combo(operand int8, registers []uint64) uint64 {
	if operand > 3 {
		return registers[operand-4]
	}
	return uint64(operand)
}

func runProgram(registers []uint64, program []int8) []int8 {
	output := []int8{}
	ip := 0
	var opcode, operand int8
	for ip < len(program)-1 {
		opcode, operand = program[ip], program[ip+1]
		switch opcode {
		case 0: // adv
			registers[0] = registers[0] >> combo(operand, registers)
		case 1: // bxl
			registers[1] = registers[1] ^ uint64(operand)
		case 2: // bst
			registers[1] = combo(operand, registers) % 8
		case 3: // jnz
			if registers[0] != 0 {
				ip = int(operand)
				continue
			}
		case 4: // bxc
			registers[1] = registers[1] ^ registers[2]
		case 5:
			output = append(output, int8(combo(operand, registers)%8))
		case 6:
			registers[1] = registers[0] >> combo(operand, registers)
		case 7:
			registers[2] = registers[0] >> combo(operand, registers)
		}
		ip = ip + 2
	}
	return output
}

func printOutputs(outputs []int8) {
	digits := make([]string, len(outputs))
	for i, o := range outputs {
		digits[i] = strconv.Itoa(int(o))
	}
	println(strings.Join(digits, ","))
}

func runProgramWithA(registers []uint64, program []int8, registerA uint64) []int8 {
	regCopy := slices.Clone(registers)
	regCopy[0] = registerA
	return runProgram(regCopy, program)
}

func searchQuine(registers []uint64, program []int8) uint64 {
	queue := []uint64{0, 1, 2, 3, 4, 5, 6, 7}
	var a uint64
	for len(queue) > 0 {
		a, queue = queue[0], queue[1:]
		if bits.Len64(a)/3+1 == len(program) {
			return a
		}

		for i := range 8 {
			tryA := (a << 3) + uint64(i)
			outputs := runProgramWithA(registers, program, tryA)
			pSlice := len(program) - len(outputs)

			if slices.Equal(outputs, program[pSlice:]) {
				queue = append(queue, tryA)
			}
		}
	}
	panic("Not found!")
}

func main() {
	registers, program := parseInput()
	printOutputs(runProgram(registers, program))
	println(searchQuine(registers, program))
}
