package main

import (
	"bufio"
	"fmt"
	"math/bits"
	"os"
	"slices"
	"strconv"
)

func reflects(currentMap []uint, row_index int, diff int) bool {
	first, second := slices.Clone(currentMap[:row_index]), currentMap[row_index:]
	slices.Reverse(first)

	if len(first) < len(second) {
		second = second[:len(first)]
	} else if len(first) > len(second) {
		first = first[:len(second)]
	}

	diff_count := 0

	for i := range len(first) {
		var v1, v2 uint
		if first[i] == second[i] {
			continue
		} else if first[i] < second[i] {
			v1, v2 = first[i], second[i]
		} else {
			v1, v2 = second[i], first[i]
		}

		if v1&v2 != v1 {
			return false
		}
		count := bits.OnesCount(v2 - v1)

		if count+diff_count <= diff {
			diff_count += count
		} else {
			return false
		}
	}
	return diff_count == diff
}

func convertBinary(strMap []string) []uint {
	binaryMap := make([]uint, len(strMap))
	for i, v := range strMap {
		bv, _ := strconv.ParseInt(v, 2, 32)
		binaryMap[i] = uint(bv)
	}
	return binaryMap
}

func findReflection(currentMap []string, diff int) int {
	binaryMap := convertBinary(currentMap)
	for i := range len(binaryMap) - 1 {
		if reflects(binaryMap, i+1, diff) {
			return i + 1
		}
	}
	return 0
}

func transpose(strMap []string) []string {
	newMap := make([]string, len(strMap[0]))
	for i := 0; i < len(strMap[0]); i++ {
		row := make([]byte, len(strMap))
		for j := 0; j < len(strMap); j++ {
			row[j] = strMap[j][i]
		}
		newMap[i] = string(row)
	}
	return newMap
}

func sumReflections(maps [][]string, diff int) int {
	sum := 0
	for _, currentMap := range maps {
		sum += 100 * findReflection(currentMap, diff)
		sum += findReflection(transpose(currentMap), diff)
	}
	return sum
}

func ParseInput() [][]string {
	scanner := bufio.NewScanner(os.Stdin)
	maps := [][]string{}
	currentMap := []string{}

	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			maps = append(maps, currentMap)
			currentMap = []string{}
			continue
		}
		row := ""
		for _, c := range line {
			if c == '#' {
				row += "1" // uint(math.Pow(2, float64(i)))
			} else {
				row += "0"
			}
		}
		currentMap = append(currentMap, row)
	}
	return append(maps, currentMap)
}

func main() {
	maps := ParseInput()
	fmt.Println(sumReflections(maps, 0))
	fmt.Println(sumReflections(maps, 1))
}
