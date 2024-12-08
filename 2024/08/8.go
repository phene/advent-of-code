package main

import (
	"bufio"
	"os"
)

type Position struct {
	x int
	y int
}

func (this *Position) resonate(other Position, resonant int) Position {
	return Position{this.x + resonant*(this.x-other.x), this.y + resonant*(this.y-other.y)}
}

type Grid []Row
type Row []byte
type Antennas map[byte][]Position

var EMPTY byte = '.'

func parseInput() *Grid {
	grid := Grid{}
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		grid = append(grid, Row(scanner.Text()))
	}
	return &grid
}

func findAntennas(grid *Grid) Antennas {
	positions := Antennas{}
	for y, row := range *grid {
		for x, cell := range row {
			if cell != EMPTY {
				positions[cell] = append(positions[cell], Position{x, y})
			}
		}
	}
	return positions
}

func inBounds(p *Position, xmax, ymax int) bool {
	return p.x >= 0 && p.x <= xmax && p.y >= 0 && p.y <= ymax
}

func findAntinodeCount(antennas Antennas, xmax int, ymax int, resonants []int) int {
	antinodes := map[Position]bool{}
	for _, locations := range antennas {
		for i := 0; i < len(locations)-1; i++ {
			l1 := locations[i]
			for j := i + 1; j < len(locations); j++ {
				l2 := locations[j]

				for _, r := range resonants {
					r1 := l1.resonate(l2, r)
					if inBounds(&r1, xmax, ymax) {
						antinodes[r1] = true
					} else {
						break
					}
				}
				for _, r := range resonants {
					r2 := l2.resonate(l1, r)
					if inBounds(&r2, xmax, ymax) {
						antinodes[r2] = true
					} else {
						break
					}
				}
			}
		}
	}
	return len(antinodes)
}

func main() {
	grid := parseInput()
	antennas := findAntennas(grid)
	xmax, ymax := len((*grid)[0])-1, len(*grid)-1

	println(findAntinodeCount(antennas, xmax, ymax, []int{1}))

	// Resonants will always be less than the size of the grid
	resonants := make([]int, max(xmax, ymax))
	for i := 0; i < len(resonants); i++ {
		resonants[i] = i
	}

	println(findAntinodeCount(antennas, xmax, ymax, resonants))
}
