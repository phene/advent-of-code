package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strings"
)

var MOVABLE byte = 'O'
var UNMOVABLE byte = '#'
var EMPTY byte = '.'

func ParseInput() []string {
	scanner := bufio.NewScanner(os.Stdin)
	grid := []string{}
	for scanner.Scan() {
		grid = append(grid, scanner.Text())
	}
	return grid
}

func calculateWeight(grid []string) int {
	sum := 0
	for i, row := range grid {
		sum += strings.Count(row, string(MOVABLE)) * (len(grid) - i)
	}
	return sum
}

func rotateClockwise(grid []string) []string {
	newGrid := make([]string, len(grid[0]))
	for i := 0; i < len(grid[0]); i++ {
		row := make([]byte, len(grid))
		for j := 0; j < len(grid); j++ {
			row[len(grid)-j-1] = grid[j][i]
		}
		newGrid[i] = string(row)
	}
	return newGrid
}

func roll(grid []string) []string {
	newGrid := slices.Clone(grid)

	for y, row := range grid {
		for x, chr := range row {
			if byte(chr) != MOVABLE {
				continue
			}
			var ny int
			for ny = y - 1; ny >= 0; ny-- {
				if newGrid[ny][x] != EMPTY {
					break
				}
			}
			ny++
			if ny < y {
				newGrid[ny] = newGrid[ny][:x] + string(MOVABLE) + newGrid[ny][x+1:]
				newGrid[y] = newGrid[y][:x] + string(EMPTY) + newGrid[y][x+1:]
			}
		}
	}
	return newGrid
}

func cycle(grid []string) []string {
	grid = rotateClockwise(roll(grid))
	grid = rotateClockwise(roll(grid))
	grid = rotateClockwise(roll(grid))
	return rotateClockwise(roll(grid))
}

func main() {
	grid := ParseInput()
	grid = roll(grid)
	fmt.Println(calculateWeight(grid))

	history := [][]string{grid}
	cycle_count := 1000000000
	var cycle_begin int

	for i := 0; i <= cycle_count; i++ {
		grid = cycle(grid)

		cycle_begin = slices.IndexFunc(history, func(e []string) bool {
			for i, row := range e {
				if row != grid[i] {
					return false
				}
			}
			return true
		})

		if cycle_begin > -1 {
			break
		}
		history = append(history, grid)
	}

	grid = history[cycle_begin+(cycle_count-cycle_begin)%(len(history)-cycle_begin)]
	fmt.Println(calculateWeight(grid))
}
