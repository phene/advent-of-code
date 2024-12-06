package main

import (
	"bufio"
	"errors"
	"fmt"
	"os"
)

type Position struct {
	x int
	y int
}

type Direction struct {
	dx int
	dy int
}

type Visit struct {
	pos Position
	dir Direction
}

type Grid [][]byte
type Row []byte
type PositionSet map[Position]bool

var DOWN Direction = Direction{0, -1}
var UP Direction = Direction{0, 1}
var LEFT Direction = Direction{-1, 0}
var RIGHT Direction = Direction{1, 0}
var OBSTACLE byte = '#'
var START_POSITION byte = '^'
var EMPTY byte = '.'

func (v *Visit) step() Visit {
	return Visit{Position{v.pos.x + v.dir.dx, v.pos.y + v.dir.dy}, v.dir}
}

func (v *Visit) rotate() Visit {
	dir := v.dir
	switch dir {
	case DOWN:
		dir = RIGHT
	case UP:
		dir = LEFT
	case LEFT:
		dir = DOWN
	case RIGHT:
		dir = UP
	}
	return Visit{v.pos, dir}
}

func (grid *Grid) start() (*Visit, error) {
	for y, row := range *grid {
		for x, cell := range row {
			if cell == START_POSITION {
				return &Visit{Position{x, y}, DOWN}, nil
			}
		}
	}
	return nil, errors.New("No start")
}

func (grid *Grid) outside(pos *Position) bool {
	if pos.x < 0 || pos.x >= len((*grid)[0]) {
		return true
	} else if pos.y < 0 || pos.y >= len(*grid) {
		return true
	}
	return false
}

func (grid *Grid) step(visit *Visit) (*Visit, bool) {
	nextVisit := visit.step()
	nextPos := nextVisit.pos
	if grid.outside(&nextPos) {
		return nil, true
	}
	for (*grid)[nextPos.y][nextPos.x] == OBSTACLE {
		nextVisit = visit.rotate()
		nextPos = nextVisit.pos
	}
	return &nextVisit, false
}

func (grid *Grid) traverse() (*PositionSet, bool) {
	visitedPositions := PositionSet{}
	visits := map[Visit]bool{}
	visit, _ := grid.start()
	var exited bool
	for visit != nil {
		if visits[*visit] {
			break
		}
		visitedPositions[visit.pos] = true
		visits[*visit] = true
		visit, exited = grid.step(visit)
	}
	return &visitedPositions, exited
}

func (grid *Grid) createObstacle(pos *Position) {
	(*grid)[pos.y][pos.x] = OBSTACLE
}

func (grid *Grid) removeObstacle(pos *Position) {
	(*grid)[pos.y][pos.x] = EMPTY
}

func findLoops(grid *Grid, visited *PositionSet) int {
	loopCount := 0
	start, _ := grid.start()
	delete(*visited, start.pos) // Exclude starting position
	for pos := range *visited {
		grid.createObstacle(&pos)
		_, exited := grid.traverse()
		grid.removeObstacle(&pos)
		if !exited {
			loopCount += 1
		}
	}
	return loopCount
}

func parseInput() *Grid {
	grid := Grid{}
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		grid = append(grid, Row(scanner.Text()))
	}
	return &grid
}

func main() {
	grid := parseInput()
	visitedPositions, _ := grid.traverse()
	fmt.Println(len(*visitedPositions))
	fmt.Println(findLoops(grid, visitedPositions))
}
