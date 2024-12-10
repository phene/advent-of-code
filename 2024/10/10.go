package main

import (
	"bufio"
	"os"
)

type P struct {
	x int
	y int
}

func (this *P) add(other *P) P {
	return P{this.x + other.x, this.y + other.y}
}

type Grid []Row
type Row []rune

var DELTAS []P = []P{{0, -1}, {0, 1}, {-1, 0}, {1, 0}}

func parseInput() *Grid {
	grid := Grid{}
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		grid = append(grid, Row(scanner.Text()))
	}
	return &grid
}

func findTrailheads(grid *Grid) []P {
	trailheads := []P{}
	for y, row := range *grid {
		for x, cell := range row {
			if cell == '0' {
				trailheads = append(trailheads, P{x, y})
			}
		}
	}
	return trailheads
}

func inBounds(p *P, xmax, ymax int) bool {
	return p.x >= 0 && p.y >= 0 && p.x <= xmax && p.y <= ymax
}

func maxTrails(grid *Grid, trailhead P, uniquePaths bool) int {
	trails := 0
	visited := map[P]bool{}
	paths := []P{trailhead}
	var p P
	xmax, ymax := len((*grid)[0])-1, len(*grid)-1

	for len(paths) > 0 {
		p, paths = paths[0], paths[1:]

		if !uniquePaths && visited[p] {
			continue
		}
		visited[p] = true
		height := (*grid)[p.y][p.x]

		if height == '9' {
			trails++
			continue
		}

		for _, d := range DELTAS {
			np := p.add(&d)
			if inBounds(&np, xmax, ymax) && (*grid)[np.y][np.x] == height+1 {
				paths = append(paths, np)
			}
		}
	}

	return trails
}

func main() {
	grid := parseInput()
	total1, total2 := 0, 0
	for _, trailhead := range findTrailheads(grid) {
		total1 += maxTrails(grid, trailhead, false)
		total2 += maxTrails(grid, trailhead, true)
	}
	println(total1)
	println(total2)
}
