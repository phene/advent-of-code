package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"regexp"
	"strconv"
	"strings"
)

func parse_input() []int {
	scanner := bufio.NewScanner(os.Stdin)
	number_re := regexp.MustCompile(`\d+`)
	game_id := -1
	games := []int{}

	for scanner.Scan() {
		game_id += 1
		line := scanner.Text()
		line_parts := strings.Split(line, ":")
		number_groups := strings.Split(line_parts[1], "|")
		group1_s, group2_s := number_groups[0], number_groups[1]
		set := map[int]int{}
		for _, d := range number_re.FindAllString(group1_s, -1) {
			n, _ := strconv.Atoi(d)
			set[n] = 1
		}
		for _, d := range number_re.FindAllString(group2_s, -1) {
			n, _ := strconv.Atoi(d)
			set[n] = set[n] + 1
		}
		matching_size := 0
		for _, n := range set {
			if n > 1 {
				matching_size += 1
			}
		}
		games = append(games, matching_size)
	}

	return games
}

func part1(games []int) int {
	sum := 0
	for _, matching_size := range games {
		sum += int(math.Pow(2, float64(matching_size-1)))
	}
	return sum
}

func make_copies(games []int, copies []int, game_id int) {
	g := game_id + 1
	n := game_id + games[game_id]

	for i := g; i <= n; i++ {
		copies[i] += 1
		make_copies(games, copies, i)
	}
}

func part2(games []int) int {
	copies := make([]int, len(games))

	for g := range games {
		copies[g] += 1
		make_copies(games, copies, g)
	}

	sum := 0
	for _, c := range copies {
		sum += c
	}
	return sum
}

func main() {
	games := parse_input()
	fmt.Println(part1(games))
	fmt.Println(part2(games))
}
