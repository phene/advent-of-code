package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

type SpringSet struct {
	springs        string
	damaged_counts []int
}

func ParseNumbers(str string) []int {
	numbers := []int{}
	for _, s := range strings.Split(str, ",") {
		n, _ := strconv.Atoi(s)
		numbers = append(numbers, n)
	}
	return numbers
}

func CacheKey(springs string, damaged_counts []int) string {
	str := springs + "_"
	for _, c := range damaged_counts {
		str += strconv.Itoa(c) + ","
	}
	return str
}

func CountArrangements(springs string, damaged_counts []int, cache *map[string]int) int {
	if len(springs) == 0 {
		if len(damaged_counts) > 0 {
			return 0
		} else {
			return 1
		}
	}
	if len(damaged_counts) == 0 {
		if strings.Contains(springs, "#") {
			return 0
		} else {
			return 1
		}
	}

	cache_key := CacheKey(springs, damaged_counts)

	if val, exists := (*cache)[cache_key]; exists {
		return val
	}

	count, spring := 0, springs[0]

	if spring == '.' || spring == '?' {
		count += CountArrangements(springs[1:], damaged_counts, cache)
	}

	if spring != '.' {
		current_count, other_counts := damaged_counts[0], damaged_counts[1:]

		if current_count <= len(springs) && !strings.Contains(springs[:current_count], ".") {
			if current_count == len(springs) {
				count += CountArrangements("", other_counts, cache)
			} else if springs[current_count] != '#' {
				count += CountArrangements(springs[current_count+1:], other_counts, cache)
			}
		}
	}

	(*cache)[cache_key] = count
	return count
}

func ParseInput() []SpringSet {
	scanner := bufio.NewScanner(os.Stdin)

	spring_sets := []SpringSet{}

	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, " ")
		damaged_counts := ParseNumbers(parts[1])
		spring_sets = append(spring_sets, SpringSet{parts[0], damaged_counts})
	}
	return spring_sets
}

func main() {
	spring_sets := ParseInput()
	sum1, sum2 := 0, 0
	for _, spring_set := range spring_sets {
		cache := make(map[string]int)
		sum1 += CountArrangements(spring_set.springs, spring_set.damaged_counts, &cache)

		springs := spring_set.springs + "?" + spring_set.springs + "?" + spring_set.springs + "?" + spring_set.springs + "?" + spring_set.springs
		damaged_counts := slices.Concat(spring_set.damaged_counts, spring_set.damaged_counts, spring_set.damaged_counts, spring_set.damaged_counts, spring_set.damaged_counts)
		sum2 += CountArrangements(springs, damaged_counts, &cache)
	}
	fmt.Println(sum1)
	fmt.Println(sum2)
}
