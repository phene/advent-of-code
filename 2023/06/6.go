package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

func parseNumbers(str string) []int {
	number_re := regexp.MustCompile(`\d+`)
	numbers := []int{}
	for _, s := range number_re.FindAllString(str, -1) {
		n, _ := strconv.Atoi(s)
		numbers = append(numbers, n)
	}
	return numbers
}

func parse_input() ([]int, []int) {
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	times := parseNumbers(scanner.Text())
	scanner.Scan()
	distances := parseNumbers(scanner.Text())
	return times, distances
}

func count_winning_strats(time_limit int, distance int) int {
	count := 0
	for hold_time := 1; hold_time < time_limit; hold_time++ {
		if (time_limit-hold_time)*hold_time > distance {
			count += 1
		}
	}
	return count
}

func part1(times []int, distances []int) int {
	p := 1
	for idx, time_limit := range times {
		p *= count_winning_strats(time_limit, distances[idx])
	}
	return p
}

func part2(times []int, distances []int) int {
	new_time_limit_s, new_distance_s := "", ""
	for i := range len(times) {
		new_time_limit_s += strconv.Itoa(times[i])
		new_distance_s += strconv.Itoa(distances[i])
	}
	new_time_limit, _ := strconv.Atoi(new_time_limit_s)
	new_distance, _ := strconv.Atoi(new_distance_s)

	return count_winning_strats(new_time_limit, new_distance)
}

func main() {
	times, distances := parse_input()
	fmt.Println(part1(times, distances))
	fmt.Println(part2(times, distances))
}
