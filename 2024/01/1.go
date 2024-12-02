package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func parseInput() ([]int, []int) {
	scanner := bufio.NewScanner(os.Stdin)
	listA, listB := []int{}, []int{}
	for scanner.Scan() {
		pair := strings.Split(scanner.Text(), "   ")
		a, _ := strconv.Atoi(pair[0])
		b, _ := strconv.Atoi(pair[1])
		listA = append(listA, a)
		listB = append(listB, b)
	}
	slices.Sort(listA)
	slices.Sort(listB)
	return listA, listB
}

func count(list []int, item int) int {
	c := 0
	for i, _ := slices.BinarySearch(list, item); list[i] == item; i++ {
		c++
	}
	return c
}

func main() {
	listA, listB := parseInput()
	sum1, sum2 := 0, 0
	for i, a := range listA {
		sum1 += max(a, listB[i]) - min(a, listB[i])
		sum2 += a * count(listB, a)
	}
	fmt.Println(sum1)
	fmt.Println(sum2)
}
