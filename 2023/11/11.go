package main

import (
	"bufio"
	"fmt"
	"os"
)

type Coord struct {
	x int
	y int
}

func Emptiness(space [][]bool) (map[int]bool, map[int]bool) {
	xs, ys := map[int]bool{}, map[int]bool{}

	for y := range len(space) {
		empty := true
		for x := range len(space[y]) {
			if space[y][x] {
				empty = false
			}
		}
		if empty {
			ys[y] = true
		}
	}

	for x := range len(space[0]) {
		empty := true
		for y := range len(space) {
			if space[y][x] {
				empty = false
			}
		}
		if empty {
			xs[x] = true
		}
	}

	return xs, ys
}

func ParseInput() ([][]bool, []Coord) {
	scanner := bufio.NewScanner(os.Stdin)
	space, coords, y := [][]bool{}, []Coord{}, 0
	for scanner.Scan() {
		line := scanner.Text()
		row := make([]bool, len(line))
		for x, loc := range line {
			if loc == '#' {
				row[x] = true
				coords = append(coords, Coord{x, y})
			}
		}
		space = append(space, row)
		y += 1
	}
	return space, coords
}

func CountEmpty(c1 int, c2 int, empty map[int]bool) int {
	e := 0
	for c := c1; c <= c2; c++ {
		if empty[c] {
			e += 1
		}
	}
	return e
}

func Distance(g1 Coord, g2 Coord, empty_x map[int]bool, empty_y map[int]bool, expansion int) int {
	gx1, gx2 := min(g1.x, g2.x), max(g1.x, g2.x)
	gy1, gy2 := min(g1.y, g2.y), max(g1.y, g2.y)
	exx, exy := CountEmpty(gx1, gx2, empty_x), CountEmpty(gy1, gy2, empty_y)
	return (gx2 - gx1 - exx) + (exx * expansion) + (gy2 - gy1 - exy) + (exy * expansion)
}

func IterateCoordPairs(coords []Coord, out chan<- []Coord) {
	for i := range len(coords) {
		for j := i + 1; j < len(coords); j++ {
			out <- []Coord{coords[i], coords[j]}
		}
	}
	close(out)
}

func main() {
	space, galaxy_coords := ParseInput()
	empty_x, empty_y := Emptiness(space)

	pairs := make(chan []Coord)
	sum_1, sum_2 := 0, 0
	go IterateCoordPairs(galaxy_coords, pairs)
	for pair := range pairs {
		sum_1 += Distance(pair[0], pair[1], empty_x, empty_y, 2)
		sum_2 += Distance(pair[0], pair[1], empty_x, empty_y, 1000000)
	}
	fmt.Println(sum_1)
	fmt.Println(sum_2)
}
