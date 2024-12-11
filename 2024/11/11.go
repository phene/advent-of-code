package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func parseInput() []int {
	stones := []int{}
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	for _, s := range strings.Split(scanner.Text(), " ") {
		stones = append(stones, atoi(s))
	}
	return stones
}

type Key struct {
	stone int
	n     int
}

var CACHE map[Key]int = map[Key]int{}

func transform(stone, n int) int {
	if n == 0 {
		return 1
	}
	cache_key := Key{stone, n}
	val, found := CACHE[cache_key]
	if found {
		return val
	}
	var result int
	str := strconv.Itoa(stone)
	if stone == 0 {
		result = transform(1, n-1)
	} else if len(str)%2 == 0 {
		result = transform(atoi(str[0:(len(str)/2)]), n-1) + transform(atoi(str[len(str)/2:]), n-1)
	} else {
		result = transform(stone*2024, n-1)
	}
	CACHE[cache_key] = result
	return result
}

func main() {
	stones := parseInput()
	fmt.Println(stones)
	sum := 0
	for _, stone := range stones {
		sum += transform(stone, 25)
	}
	println(sum)

	sum = 0
	for _, stone := range stones {
		sum += transform(stone, 75)
	}
	println(sum)
}
