package main

import (
	"bufio"
	"fmt"
	"os"
)

type V struct {
	x  int
	y  int
	dx int
	dy int
}

func countEnergizedPositions(grid []string, start V) int {
	gy, gx := len(grid)-1, len(grid[0])-1
	visited := map[uint64]bool{}
	positions := []V{start}
	energizedPositions := map[uint32]bool{}
	var visit V
	var ndx, ndy int

	for len(positions) > 0 {
		visit, positions = positions[0], positions[1:]
		dx, dy := visit.dx, visit.dy
		x, y := visit.x+dx, visit.y+dy
		if x < 0 || x > gx || y < 0 || y > gy {
			continue
		}

		p := uint64(visit.x) + (uint64(visit.y) << 16) + (uint64(dx) << 32) + (uint64(dy) << 48)
		if visited[p] {
			continue
		}
		visited[p] = true
		energizedPositions[uint32(x)+(uint32(y)<<16)] = true

		switch grid[y][x] {
		case '.':
			positions = append(positions, V{x, y, dx, dy})
		case '/':
			if dx == 0 {
				ndx, ndy = -dy, 0
			} else {
				ndx, ndy = 0, -dx
			}
			positions = append(positions, V{x, y, ndx, ndy})
		case '\\':
			if dx == 0 {
				ndx, ndy = dy, 0
			} else {
				ndx, ndy = 0, dx
			}
			positions = append(positions, V{x, y, ndx, ndy})
		case '-':
			if dx == 0 {
				positions = append(positions, V{x, y, -1, 0}, V{x, y, 1, 0})
			} else {
				positions = append(positions, V{x, y, dx, dy})
			}
		case '|':
			if dy == 0 {
				positions = append(positions, V{x, y, 0, -1}, V{x, y, 0, 1})
			} else {
				positions = append(positions, V{x, y, dx, dy})
			}
		}
	}
	return len(energizedPositions)
}

func ParseInput() []string {
	scanner := bufio.NewScanner(os.Stdin)
	grid := []string{}
	for scanner.Scan() {
		grid = append(grid, scanner.Text())
	}
	return grid
}

func main() {
	grid := ParseInput()
	fmt.Println(countEnergizedPositions(grid, V{-1, 0, 1, 0}))

	mostEnergized := 0

	for y, r := range grid {
		mostEnergized = max(
			mostEnergized,
			countEnergizedPositions(grid, V{-1, y, 1, 0}),
			countEnergizedPositions(grid, V{len(r), y, -1, 0}),
		)
	}

	for x := range len(grid[0]) {
		mostEnergized = max(
			mostEnergized,
			countEnergizedPositions(grid, V{x, -1, 0, 1}),
			countEnergizedPositions(grid, V{x, len(grid), 0, -1}),
		)
	}

	fmt.Println(mostEnergized)
}
