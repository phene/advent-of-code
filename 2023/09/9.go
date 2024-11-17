package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func ParseInput() [][]int {
	scanner := bufio.NewScanner(os.Stdin)
	histories := [][]int{}

	for scanner.Scan() {
		history := []int{}
		for _, digit := range strings.Split(scanner.Text(), " ") {
			n, _ := strconv.Atoi(digit)
			history = append(history, n)
		}
		histories = append(histories, history)
	}

	return histories
}

func RegressStep(history []int) ([]int, bool) {
	new_history := make([]int, len(history)-1)
	all_zeroes := true
	for i := 1; i < len(history); i++ {
		x := history[i] - history[i-1]
		new_history[i-1] = x
		if x != 0 {
			all_zeroes = false
		}
	}
	return new_history, all_zeroes
}

func Regress(history []int) [][]int {
	regressions := [][]int{history}
	new_history := history
	all_zeroes := false
	for !all_zeroes {
		new_history, all_zeroes = RegressStep(new_history)
		regressions = append(regressions, new_history)
	}
	return regressions
}

func Extrapolate(regressions [][]int, last bool) int {
	ext := 0
	for i := len(regressions) - 1; i >= 0; i-- {
		if last {
			ext = regressions[i][len(regressions[i])-1] + ext
		} else {
			ext = regressions[i][0] - ext
		}
	}
	return ext
}

func SumExtrapolations(histories [][]int, last bool) int {
	sum := 0
	for i := 0; i < len(histories); i++ {
		sum += Extrapolate(Regress(histories[i]), last)
	}
	return sum
}

func main() {
	histories := ParseInput()
	// Part 1
	fmt.Println(SumExtrapolations(histories, true))
	// Part 2
	fmt.Println(SumExtrapolations(histories, false))
}
