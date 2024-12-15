package main

import (
	"bufio"
	"image"
	"os"
	"slices"
)

type Grid []Row
type Row []rune

var ROBOT = '@'
var BOX = 'O'
var WALL = '#'
var EMPTY = '.'
var LEFTBOX = '['
var RIGHTBOX = ']'

var MOVES = map[rune]image.Point{
	'^': {0, -1},
	'>': {1, 0},
	'v': {0, 1},
	'<': {-1, 0},
}

func (grid Grid) UpdateCell(p image.Point, item rune) {
	grid[p.Y][p.X] = item
}

func (grid Grid) GetCell(p image.Point) rune {
	return grid[p.Y][p.X]
}

func (grid Grid) Score() int {
	score := 0
	for y, row := range grid {
		for x, cell := range row {
			if cell == BOX || cell == LEFTBOX {
				score += x + y*100
			}
		}
	}
	return score
}

func (grid Grid) Start() image.Point {
	for y, row := range grid {
		for x, cell := range row {
			if '@' == cell {
				return image.Point{x, y}
			}
		}
	}
	panic("Did not find Robot")
}

func (grid Grid) Move(p1, p2 image.Point) image.Point {
	thing := grid.GetCell(p1)
	switch grid.GetCell(p2) {
	case EMPTY:
		grid.UpdateCell(p2, thing)
		grid.UpdateCell(p1, EMPTY)
		return p2
	case WALL:
		return p1
	case BOX:
		if p2 != grid.Move(p2, p2.Add(p2.Sub(p1))) {
			grid.UpdateCell(p2, thing)
			grid.UpdateCell(p1, EMPTY)
			return p2
		} else {
			return p1
		}
	default: // LEFTBOX, RIGHTBOX
		d := p2.Sub(p1)
		if d == MOVES['<'] || d == MOVES['>'] {
			if p2 != grid.Move(p2, p2.Add(d)) {
				grid.UpdateCell(p2, thing)
				grid.UpdateCell(p1, EMPTY)
				return p2
			} else {
				return p1
			}
		} else {
			otherHalf := grid.OtherHalf(p2)
			if grid.CanMove(p2, p2.Add(d)) && grid.CanMove(otherHalf, otherHalf.Add(d)) {
				grid.Move(p2, p2.Add(d))
				grid.Move(otherHalf, otherHalf.Add(d))
				grid.UpdateCell(p1, EMPTY)
				grid.UpdateCell(p2, thing)
				grid.UpdateCell(otherHalf, EMPTY)
				return p2
			} else {
				return p1
			}
		}
	}
}

func (grid Grid) OtherHalf(p image.Point) image.Point {
	if grid.GetCell(p) == LEFTBOX {
		return p.Add(MOVES['>'])
	} else {
		return p.Add(MOVES['<'])
	}
}

func (grid Grid) CanMove(p1, p2 image.Point) bool {
	switch grid.GetCell(p2) {
	case EMPTY:
		return true
	case WALL:
		return false
	default: // LEFTBOX, RIGHTBOX
		d := p2.Sub(p1)
		if d == MOVES['<'] || d == MOVES['>'] {
			return grid.CanMove(p2, p2.Add(d))
		} else {
			otherHalf := grid.OtherHalf(p2)
			return grid.CanMove(p2, p2.Add(d)) && grid.CanMove(otherHalf, otherHalf.Add(d))
		}
	}
}

func (grid Grid) Traverse(movements []rune) {
	p := grid.Start()
	for _, movement := range movements {
		p = grid.Move(p, p.Add(MOVES[movement]))
	}
}

func (grid Grid) Transform() Grid {
	newGrid := make(Grid, len(grid))
	for y, row := range grid {
		newGrid[y] = make(Row, len(row)*2)
		for x, cell := range row {
			switch cell {
			case '.':
				newGrid[y][x*2] = '.'
				newGrid[y][x*2+1] = '.'
			case 'O':
				newGrid[y][x*2] = '['
				newGrid[y][x*2+1] = ']'
			case '#':
				newGrid[y][x*2] = '#'
				newGrid[y][x*2+1] = '#'
			case '@':
				newGrid[y][x*2] = '@'
				newGrid[y][x*2+1] = '.'
			}
		}
	}
	return newGrid
}

func (grid Grid) Draw() {
	for _, row := range grid {
		for _, cell := range row {
			print(string(cell))
		}
		print("\n")
	}
}

func (grid Grid) Copy() Grid {
	newGrid := make(Grid, len(grid))
	for i, row := range grid {
		newRow := make(Row, len(row))
		copy(newRow, row)
		newGrid[i] = newRow
	}
	return newGrid
}

func parseInput() (Grid, []rune) {
	grid := Grid{}
	movements := []rune{}
	gridEnd := false
	scanner := bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		if !gridEnd {
			line := scanner.Text()
			if len(line) == 0 {
				gridEnd = true
			} else {
				grid = append(grid, Row(line))
			}
		} else {
			movements = slices.Concat(movements, []rune(scanner.Text()))
		}
	}
	return grid, movements
}

func main() {
	grid, movements := parseInput()

	part1Grid := grid.Copy()
	part1Grid.Traverse(movements)
	println(part1Grid.Score())

	part2Grid := grid.Transform()
	part2Grid.Traverse(movements)
	println(part2Grid.Score())
}
