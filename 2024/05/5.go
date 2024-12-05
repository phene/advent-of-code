package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func parseInput() (map[int][]int, [][]int) {
	scanner := bufio.NewScanner(os.Stdin)
	pageDeps := map[int][]int{}
	pageUpdates := [][]int{}

	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, "|") {
			parts := strings.Split(line, "|")
			before, _ := strconv.Atoi(parts[0])
			after, _ := strconv.Atoi(parts[1])
			pageDeps[before] = append(pageDeps[before], after)
		} else if strings.Contains(line, ",") {
			digits := strings.Split(line, ",")
			pages := make([]int, len(digits))
			for i, digit := range digits {
				page, _ := strconv.Atoi(digit)
				pages[i] = page
			}
			pageUpdates = append(pageUpdates, pages)
		}
	}

	return pageDeps, pageUpdates
}

func main() {
	pageDeps, pageUpdates := parseInput()
	total1, total2 := 0, 0

	for _, pages := range pageUpdates {
		sortedPages := make([]int, len(pages))
		copy(sortedPages, pages)

		slices.SortFunc(sortedPages, func(a, b int) int {
			if slices.Contains(pageDeps[a], b) {
				return -1
			}
			return 1
		})

		middlePage := sortedPages[len(sortedPages)/2]

		if slices.Compare(pages, sortedPages) == 0 {
			total1 += middlePage
		} else {
			total2 += middlePage
		}
	}

	fmt.Println(total1)
	fmt.Println(total2)
}
