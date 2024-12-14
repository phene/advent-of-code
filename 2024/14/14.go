package main

import (
	"bufio"
	//"fmt"
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

//var BOUNDS = P{image.Point{11, 7}}

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
	if p.X < BOUNDS.X/2 {
		if p.Y < BOUNDS.Y/2 {
			return 1
		} else {
			return 2
		}
	} else {
		if p.Y < BOUNDS.Y/2 {
			return 3
		} else {
			return 4
		}
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

func parseInput() []Robot {
	scanner := bufio.NewScanner(os.Stdin)
	re := regexp.MustCompile(`p=(-?\d{1,3}),(-?\d{1,3}) v=(-?\d{1,3}),(-?\d{1,3})`)
	robots := []Robot{}
	for scanner.Scan() {
		matches := re.FindStringSubmatch(scanner.Text())
		robot := Robot{
			P{image.Point{atoi(matches[1]), atoi(matches[2])}},
			P{image.Point{atoi(matches[3]), atoi(matches[4])}},
		}
		robots = append(robots, robot)
	}
	return robots
}

func quadrantProduct(robots []Robot, time int) int {
	quadrantSums := map[int]int{}
	product := 1
	for _, robot := range robots {
		q := robot.Travel(time).Quadrant()
		quadrantSums[q]++
	}
	for q, s := range quadrantSums {
		if q != 0 {
			product *= s
		}
	}
	return product
}

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
		points := map[P]bool{}
		for _, robot := range robots {
			points[robot.Travel(t)] = true
		}
		if hasLargeGroup(points) {
			println(t)
			break
		}
	}
}
