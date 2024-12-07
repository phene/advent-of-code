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
	operands []int
}

func add(a, b int) int {
	return a + b
}
func mul(a, b int) int {
	return a * b
}
func concat(a, b int) int {
	res, _ := strconv.Atoi(strconv.Itoa(a) + strconv.Itoa(b))
	return res
}

func parseInput() []Equation {
	equations := []Equation{}
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		parts := strings.Split(scanner.Text(), ": ")
		result, _ := strconv.Atoi(parts[0])
		values := strings.Split(parts[1], " ")
		operands := make([]int, len(values))
		for i, v := range values {
			o, _ := strconv.Atoi(v)
			operands[i] = o
		}
		equations = append(equations, Equation{result, operands})
	}
	return equations
}

func findOperations(equation *Equation, i int, partial int, ops []func(a, b int) int) bool {
	if i == len(equation.operands) {
		return partial == equation.result
	} else {
		for _, op := range ops {
			if findOperations(equation, i+1, op(partial, equation.operands[i]), ops) {
				return true
			}
		}
		return false
	}
}

func main() {
	equations := parseInput()
	total1, total2 := 0, 0
	part1Ops := []func(a, b int) int{add, mul}
	part2Ops := []func(a, b int) int{add, mul, concat}

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
