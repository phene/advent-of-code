package main

import (
	"bufio"
	"os"
	"strings"
)

func parseInput() (map[byte][]string, []string) {
	patternMap, designs := map[byte][]string{}, []string{}
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	for _, p := range strings.Split(scanner.Text(), ", ") {
		patternMap[p[0]] = append(patternMap[p[0]], p)
	}
	scanner.Scan()
	scanner.Text()
	for scanner.Scan() {
		designs = append(designs, scanner.Text())
	}
	return patternMap, designs
}

var DFS_CACHE = map[string]int{}

func dfs(design string, patternMap map[byte][]string) int {
	if len(design) == 0 {
		return 1
	}
	if DFS_CACHE[design] > 0 {
		return DFS_CACHE[design]
	}
	count := 0
	for _, p := range patternMap[design[0]] {
		if strings.HasPrefix(design, p) {
			count += dfs(design[len(p):], patternMap)
		}
	}
	DFS_CACHE[design] = count
	return count
}

func main() {
	patternMap, designs := parseInput()

	part1, part2 := 0, 0
	for _, d := range designs {
		count := dfs(d, patternMap)
		if count > 0 {
			part1++
			part2 += count
		}
	}

	println(part1)
	println(part2)
}
