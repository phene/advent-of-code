package main

import (
	"bufio"
	"image"
	"os"
	"slices"
)

type Grid []Row
type Row []rune
type Path struct {
	ps    []image.Point
	score int
}
type Visit struct {
	p image.Point
	d image.Point
}
type Travel struct {
	v    Visit
	path Path
}

func (grid Grid) UpdateCell(p image.Point, item rune) {
	grid[p.Y][p.X] = item
}

func (grid Grid) GetCell(p image.Point) rune {
	return grid[p.Y][p.X]
}

func (grid Grid) Start() (image.Point, image.Point) {
	var s, e image.Point
	for y, row := range grid {
		for x, cell := range row {
			if cell == 'S' {
				s = image.Point{x, y}
			} else if cell == 'E' {
				e = image.Point{x, y}
			}
		}
	}
	return s, e
}

func (grid Grid) Traverse() []Path {
	s, e := grid.Start()
	queue := []Travel{
		{Visit{s, image.Point{1, 0}}, Path{[]image.Point{}, 0}},
		{Visit{s, image.Point{0, -1}}, Path{[]image.Point{}, 1000}}, // initial turn
	}
	visited := map[Visit]int{}
	paths := []Path{}
	var curr Travel
	for len(queue) > 0 {
		curr, queue = queue[0], queue[1:]
		v := curr.v
		if visited[v] > 0 && visited[v] < curr.path.score {
			continue
		}
		if grid.GetCell(v.p) == '#' {
			continue
		}

		newPath := append(slices.Clone(curr.path.ps), v.p)
		visited[v] = curr.path.score
		if v.p == e {
			paths = append(paths, Path{newPath, curr.path.score})
			continue
		}

		cw := image.Point{v.d.Y, -v.d.X}
		ccw := image.Point{-v.d.Y, v.d.X}

		queue = append(
			queue,
			Travel{
				Visit{v.p.Add(v.d), v.d}, // straight
				Path{newPath, curr.path.score + 1}},
			Travel{
				Visit{v.p.Add(cw), cw}, // clockwise
				Path{newPath, curr.path.score + 1001}},
			Travel{
				Visit{v.p.Add(ccw), ccw}, // counter-clockwise
				Path{newPath, curr.path.score + 1001}},
		)
	}

	return paths
}

func (grid Grid) Draw() {
	for _, row := range grid {
		for _, cell := range row {
			print(string(cell))
		}
		print("\n")
	}
}

func parseInput() Grid {
	grid := Grid{}
	scanner := bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		line := scanner.Text()
		grid = append(grid, Row(line))
	}
	return grid
}

func bestScore(paths []Path) int {
	score := paths[0].score
	for _, path := range paths {
		score = min(score, path.score)
	}
	return score
}

func main() {
	grid := parseInput()

	paths := grid.Traverse()
	best := bestScore(paths)
	println(best)

	points := map[image.Point]bool{}
	for _, path := range paths {
		if path.score == best {
			for _, p := range path.ps {
				grid.UpdateCell(p, 'O')
				points[p] = true
			}
		}
	}
	println(len(points))
}
