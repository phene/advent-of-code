package main

import (
	"bufio"
	"image"
	"os"
	"regexp"
	"strconv"
)

type P struct {
	image.Point
}

var BOUNDS = P{image.Point{101, 103}}
var DIRECTIONS = []image.Point{{0, -1}, {1, 0}, {0, 1}, {-1, 0}}

func (p P) Modulo(bounds P) P {
	x, y := p.X%bounds.X, p.Y%bounds.Y
	// Go does not give postive modulus for negative numbers
	x, y = (x+bounds.X)%bounds.X, (y+bounds.Y)%bounds.Y
	return P{image.Point{x, y}}
}

func (p P) Quadrant() int {
	if p.X == BOUNDS.X/2 || p.Y == BOUNDS.Y/2 {
		return 0
	}
	x_lower, y_lower, q := p.X < BOUNDS.X/2, p.Y < BOUNDS.Y/2, 0
	if !x_lower {
		q += 2
	}
	if y_lower {
		return q + 1
	} else {
		return q + 2
	}
}

type Robot struct {
	p P
	v P
}

func (robot *Robot) Travel(time int) P {
	return P{robot.p.Add(robot.v.Mul(time))}.Modulo(BOUNDS)
}

func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func create_p(x, y string) P {
	return P{image.Point{atoi(x), atoi(y)}}
}

func parseInput() []Robot {
	scanner := bufio.NewScanner(os.Stdin)
	re := regexp.MustCompile(`p=(-?\d{1,3}),(-?\d{1,3}) v=(-?\d{1,3}),(-?\d{1,3})`)
	robots := []Robot{}
	for scanner.Scan() {
		matches := re.FindStringSubmatch(scanner.Text())
		robot := Robot{
			create_p(matches[1], matches[2]),
			create_p(matches[3], matches[4]),
		}
		robots = append(robots, robot)
	}
	return robots
}

func pointSet(robots []Robot, time int) map[P]bool {
	points := map[P]bool{}
	for _, robot := range robots {
		points[robot.Travel(time)] = true
	}
	return points
}

func quadrantProduct(robots []Robot, time int) int {
	quadrantSums := map[int]int{}
	for _, robot := range robots {
		quadrantSums[robot.Travel(time).Quadrant()]++
	}
	product := 1
	for q, s := range quadrantSums {
		if q != 0 {
			product *= s
		}
	}
	return product
}

// Do at least a quarter of the points create a contiguous block?
func hasLargeGroup(points map[P]bool) bool {
	for point := range points {
		positions := []P{point}
		visited := map[P]bool{}
		var p P
		for len(positions) > 0 {
			p, positions = positions[0], positions[1:]
			if visited[p] {
				continue
			}
			visited[p] = true

			for _, d := range DIRECTIONS {
				if points[P{p.Add(d)}] {
					positions = append(positions, P{p.Add(d)})
				}
			}
		}
		if len(visited) >= len(points)/4 {
			return true
		}
	}
	return false
}

func main() {
	robots := parseInput()
	println(quadrantProduct(robots, 100))

	for t := 0; true; t++ {
		points := pointSet(robots, t)
		// Assumption is that input was constructed by putting on robots on unique
		// points then stepping in reverse by the target time. Robots being on unique
		// points is not sufficient to give a unique answer, so finding a large
		// group of them is also required to identify the target time.
		if len(points) == len(robots) && hasLargeGroup(points) {
			println(t)
			break
		}
	}
}
