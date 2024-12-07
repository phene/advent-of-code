package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Equation struct {
	result   int
	operands []Operand
}
type Operand int

func (this *Operand) add(other Operand) Operand {
	return *this + other
}
func (this *Operand) mul(other Operand) Operand {
	return *this * other
}
func (this *Operand) concat(other Operand) Operand {
	newStr := strconv.Itoa(int(*this)) + strconv.Itoa(int(other))
	res, _ := strconv.Atoi(newStr)
	return Operand(res)
}
func (this *Operand) eq(other int) bool {
	return int(*this) == other
}

var part1Ops = func(a, b Operand) []Operand {
	return []Operand{a.add(b), a.mul(b)}
}
var part2Ops = func(a, b Operand) []Operand {
	return append(part1Ops(a, b), a.concat(b))
}

func parseInput() []Equation {
	equations := []Equation{}
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		parts := strings.Split(scanner.Text(), ": ")
		result, _ := strconv.Atoi(parts[0])
		values := strings.Split(parts[1], " ")
		operands := make([]Operand, len(values))
		for i, v := range values {
			o, _ := strconv.Atoi(v)
			operands[i] = Operand(o)
		}
		equations = append(equations, Equation{result, operands})
	}
	return equations
}

func findOperations(equation *Equation, i int, partial Operand, ops func(a, b Operand) []Operand) bool {
	if i == len(equation.operands) {
		return partial.eq(equation.result)
	} else {
		newPartials := ops(partial, equation.operands[i])
		for _, p := range newPartials {
			if findOperations(equation, i+1, p, ops) {
				return true
			}
		}
		return false
	}
}

func main() {
	equations := parseInput()
	total1, total2 := 0, 0

	for _, equation := range equations {
		if findOperations(&equation, 1, equation.operands[0], part1Ops) {
			total1 += equation.result
			total2 += equation.result
		} else if findOperations(&equation, 1, equation.operands[0], part2Ops) {
			total2 += equation.result
		}
	}

	fmt.Println(total1)
	fmt.Println(total2)
}
