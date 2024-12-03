package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	re := regexp.MustCompile(`mul\((\d{1,3}),(\d{1,3})\)|(don't|do)\(\)`)
	multEnabled := true
	sum1, sum2 := 0, 0
	for scanner.Scan() {
		matches := re.FindAllStringSubmatch(scanner.Text(), -1)
		for _, match := range matches {
			switch match[3] {
			case "do":
				multEnabled = true
			case "don't":
				multEnabled = false
			case "":
				x, _ := strconv.Atoi(match[1])
				y, _ := strconv.Atoi(match[2])
				sum1 += x * y
				if multEnabled {
					sum2 += x * y
				}
			}
		}
	}
	fmt.Println(sum1)
	fmt.Println(sum2)
}
