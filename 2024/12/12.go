package main

import (
	"bufio"
	"os"
)

type P struct {
	x int
	y int
}

func (this *P) add(other P) P {
	return P{this.x + other.x, this.y + other.y}
}

type C struct {
	p P
	d P
}

type Grid []Row
type Row []rune
type PointSet map[P]bool

var DIRECTIONS = []P{{0, -1}, {1, 0}, {0, 1}, {-1, 0}}

func parseInput() Grid {
	grid := Grid{}
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		grid = append(grid, Row(scanner.Text()))
	}
	return grid
}

func findRegions(grid Grid) []PointSet {
	pointsToRegions := map[P]int{}
	region := 1
	for y, row := range grid {
		for x := range row {
			p := P{x, y}
			if pointsToRegions[p] > 0 {
				continue
			}
			fillRegion(grid, p, pointsToRegions, region)
			region++
		}
	}
	regions := make([]PointSet, region-1)
	for i := range regions {
		regions[i] = PointSet{}
	}
	for p, r := range pointsToRegions {
		regions[r-1][p] = true
	}
	return regions
}

func fillRegion(grid Grid, start P, pointsToRegions map[P]int, region int) {
	xmax, ymax := len(grid[0])-1, len(grid)-1
	positions := []P{start}
	plant := grid[start.y][start.x]
	var p P
	for len(positions) > 0 {
		p, positions = positions[0], positions[1:]
		if pointsToRegions[p] > 0 {
			continue
		}
		pointsToRegions[p] = region
		for _, d := range DIRECTIONS {
			np := p.add(d)
			if np.y < 0 || np.y > ymax || np.x < 0 || np.x > xmax {
				continue
			}
			if grid[np.y][np.x] == plant {
				positions = append(positions, np)
			}
		}
	}
}

func sumPerimeterAndArea(regions []PointSet) int {
	sum := 0
	for _, points := range regions {
		perimeter := 0
		for p := range points {
			for _, d := range DIRECTIONS {
				if !points[p.add(d)] {
					perimeter++
				}
			}
		}
		sum += len(points) * perimeter
	}
	return sum
}

func sumSidesAndArea(regions []PointSet) int {
	sum := 0

	for _, points := range regions {
		corners := map[C]bool{}
		// Walk all edges until you reach every corner
		for p := range points {
			for _, d := range DIRECTIONS {
				if points[p.add(d)] { // not an edge
					continue
				}
				step := p
				dv := P{d.y, -d.x} // rotate counter-clockwise
				// walk until you reach a corner
				for points[step.add(dv)] && !points[step.add(d.add(dv))] {
					step = step.add(dv)
				}
				corners[C{step, d}] = true
			}
		}

		sum += len(corners) * len(points)
	}
	return sum
}

func main() {
	grid := parseInput()
	regions := findRegions(grid)

	println(sumPerimeterAndArea(regions))
	println(sumSidesAndArea(regions))
}
