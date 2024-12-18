package main

import (
	"bufio"
	"image"
	"os"
	"slices"
	"strconv"
	"strings"
)

var XMAX, YMAX = 70, 70
var DIRECTIONS = []image.Point{{0, -1}, {1, 0}, {0, 1}, {-1, 0}}

type Visit struct {
	pos  image.Point
	path []image.Point
}

func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func parseInput() []image.Point {
	positions := []image.Point{}
	scanner := bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		pair := strings.Split(scanner.Text(), ",")
		positions = append(positions, image.Point{atoi(pair[0]), atoi(pair[1])})
	}
	return positions
}

func inBounds(pos image.Point) bool {
	return pos.X >= 0 && pos.X <= XMAX && pos.Y >= 0 && pos.Y <= YMAX
}

func findPath(falling_bytes []image.Point) []image.Point {
	start, end := image.Point{0, 0}, image.Point{XMAX, YMAX}
	positions := []Visit{{start, []image.Point{}}}
	visited := map[image.Point]bool{}
	fallen := map[image.Point]bool{}
	for _, f := range falling_bytes {
		fallen[f] = true
	}

	var visit Visit

	for len(positions) > 0 {
		visit, positions = positions[0], positions[1:]

		if visit.pos == end {
			return append(visit.path, visit.pos)
		}
		if visited[visit.pos] {
			continue
		}
		visited[visit.pos] = true

		for _, d := range DIRECTIONS {
			np := visit.pos.Add(d)
			if inBounds(np) && !fallen[np] {
				positions = append(positions, Visit{np, append(slices.Clone(visit.path), visit.pos)})
			}
		}
	}
	return []image.Point{}
}

func searchFirstBrokenPath(positions []image.Point) image.Point {
	min, max := 1024, len(positions)-1
	for min < max-1 {
		center := (min + max) / 2
		path := findPath(positions[0 : center+1])
		if len(path) > 0 {
			min = center + 1
		} else {
			max = center - 1
		}
	}
	return positions[max]
}

func main() {
	positions := parseInput()

	path := findPath(positions[0:1024])
	println(len(path) - 1)

	brokenPathByte := searchFirstBrokenPath(positions)
	println(strconv.Itoa(brokenPathByte.X) + "," + strconv.Itoa(brokenPathByte.Y))
}
