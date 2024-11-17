package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

func ParseFork(regEx *regexp.Regexp, line string) (string, map[byte]string) {
	match := regEx.FindStringSubmatch(line)
	if len(match) == 0 {
		panic("no match")
	}
	return match[1], map[byte]string{'L': match[2], 'R': match[3]}
}

func ParseInput() (string, map[string]map[byte]string) {
	scanner := bufio.NewScanner(os.Stdin)
	fork_re := regexp.MustCompile(`(\w{3}) = \((\w{3}), (\w{3})\)`)

	scanner.Scan()
	steps := scanner.Text()
	forks := make(map[string]map[byte]string)

	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			continue
		}
		root, fork := ParseFork(fork_re, line)
		forks[root] = fork
	}

	return steps, forks
}

func Traverse(start string, steps string, forks map[string]map[byte]string) int {
	node := start
	loops := 0
	for ; node[2] != 'Z'; loops++ {
		for _, path := range steps {
			node = forks[node][byte(path)]
			//fmt.Println(node)
		}
	}
	return loops * len(steps)
}

func gcd(a, b int) int {
	for b != 0 {
		a, b = b, a%b
	}
	return a
}

func lcm(a, b int) int {
	return a * b / gcd(a, b)
}

func main() {
	steps, forks := ParseInput()
	// Part 1
	fmt.Println(Traverse("AAA", steps, forks))

	// Part 2
	distances_lcm := 1
	for start := range forks {
		if start[2] == 'A' {
			distances_lcm = lcm(distances_lcm, Traverse(start, steps, forks))
		}
	}
	fmt.Println(distances_lcm)
}
