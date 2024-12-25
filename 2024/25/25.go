package main

import (
	"bufio"
	"os"
)

var MAX_BIDDING = 7

func computeBidding(key_or_lock []string) []int {
	bidding := make([]int, len(key_or_lock[0]))
	for i := 0; i < len(key_or_lock[0]); i++ {
		count := 0
		for _, row := range key_or_lock {
			if i >= len(row) {
				println(i)
				println(row)
			}
			if row[i] == '#' {
				count++
			}
		}
		bidding[i] = count
	}
	return bidding
}

func parseInput() ([][]int, [][]int) {
	keys, locks := [][]int{}, [][]int{}
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		current := make([]string, MAX_BIDDING)
		for i := 0; i < MAX_BIDDING; i++ {
			current[i] = scanner.Text()
			scanner.Scan()
		}
		isLock := true
		for _, chr := range current[0] {
			if chr != '#' {
				isLock = false
			}
		}
		bidding := computeBidding(current)
		if isLock {
			locks = append(locks, bidding)
		} else {
			keys = append(keys, bidding)
		}
	}

	return keys, locks
}

func fits(key []int, lock []int) bool {
	for i := 0; i < len(key); i++ {
		if key[i]+lock[i] > MAX_BIDDING {
			return false
		}
	}
	return true
}

func main() {
	keys, locks := parseInput()
	pairs := 0
	for _, key := range keys {
		for _, lock := range locks {
			if fits(key, lock) {
				pairs++
			}
		}
	}
	println(pairs)
}
