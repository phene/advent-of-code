package main

import (
	"bufio"
	"image"
	"os"
)

type CostMap map[image.Point]int
type Grid []Row
type Row []rune
type Visit struct {
	p image.Point
	d int
}
type PointPair struct {
	s image.Point
	f image.Point
}

func (grid Grid) GetCell(p image.Point) rune {
	return grid[p.Y][p.X]
}

var DIRECTIONS = []image.Point{{0, -1}, {1, 0}, {0, 1}, {-1, 0}}

func parseInput() Grid {
	grid := Grid{}
	scanner := bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		line := scanner.Text()
		grid = append(grid, Row(line))
	}
	return grid
}

func startAndFinish(grid Grid) (image.Point, image.Point) {
	start, finish := image.Point{}, image.Point{}
	for y, row := range grid {
		for x, cell := range row {
			if cell == 'S' {
				start = image.Point{x, y}
			} else if cell == 'E' {
				finish = image.Point{x, y}
			}
		}
	}
	return start, finish
}

func inBounds(grid Grid, pos image.Point) bool {
	return pos.X >= 0 && pos.X < len(grid[0]) && pos.Y >= 0 && pos.Y < len(grid)
}

func calculateDistances(grid Grid, start image.Point) CostMap {
	costMap := CostMap{}
	positions := []Visit{{start, 0}}
	var visit Visit

	for len(positions) > 0 {
		visit, positions = positions[0], positions[1:]
		if costMap[visit.p] > 0 && costMap[visit.p] < visit.d {
			continue
		}
		costMap[visit.p] = visit.d

		for _, d := range DIRECTIONS {
			np := visit.p.Add(d)
			if inBounds(grid, np) && grid.GetCell(np) != '#' {
				positions = append(positions, Visit{np, visit.d + 1})
			}
		}
	}
	return costMap
}

func abs(x int) int {
	if x > 0 {
		return x
	}
	return -x
}

func main() {
	grid := parseInput()
	start, finish := startAndFinish(grid)

	startCosts := calculateDistances(grid, start)
	finishCosts := calculateDistances(grid, finish)

	for _, cheatDist := range []int{2, 20} {
		cheats := map[PointPair]int{}

		for s, sc := range startCosts {
			for x := max(s.X-cheatDist, 0); x <= min(s.X+cheatDist, len(grid[0])-1); x++ {
				dy := cheatDist - abs(s.X-x)
				for y := max(s.Y-dy, 0); y <= min(s.Y+dy, len(grid)-1); y++ {
					f := image.Point{x, y}
					if grid.GetCell(f) == '#' { // can't finish in a wall
						continue
					}
					d := s.Sub(f)
					cost := sc + finishCosts[f] + abs(d.X) + abs(d.Y)
					benefit := finishCosts[start] - cost
					if benefit > 0 {
						cheats[PointPair{s, f}] = benefit
					}
				}
			}
		}
		count := 0
		for _, benefit := range cheats {
			if benefit >= 100 {
				count++
			}
		}
		println(count)
	}
}
