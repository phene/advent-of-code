package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func parseInput() [][]int {
	scanner := bufio.NewScanner(os.Stdin)
	reports := [][]int{}
	for scanner.Scan() {
		report_strs := strings.Split(scanner.Text(), " ")
		report := make([]int, len(report_strs))
		for i, digits := range report_strs {
			n, _ := strconv.Atoi(digits)
			report[i] = n
		}
		reports = append(reports, report)
	}
	return reports
}

func reportIsSafe(report []int) bool {
	ascending := (report[0] < report[1])
	for i := 1; i < len(report); i++ {
		r1, r2 := report[i-1], report[i]
		if (ascending && r1 >= r2) || (!ascending && r2 >= r1) || (max(r1, r2)-min(r1, r2)) > 3 {
			return false
		}
	}
	return true
}

func reportIsSafe2(report []int) bool {
	for i := range len(report) {
		if reportIsSafe(slices.Concat(report[0:i], report[i+1:])) {
			return true
		}
	}
	return false
}

func main() {
	reports := parseInput()
	sum1, sum2 := 0, 0

	for _, report := range reports {
		if reportIsSafe(report) {
			sum1 += 1
		}
		if reportIsSafe2(report) {
			sum2 += 1
		}
	}
	fmt.Println(sum1)
	fmt.Println(sum2)
}
