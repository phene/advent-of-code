package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type Step struct {
	direction byte
	distance  int
}

type V struct {
	x int
	y int
}

func ParseInput() ([]Step, []Step) {
	scanner := bufio.NewScanner(os.Stdin)
	part1Path, part2Path := []Step{}, []Step{}
	directions := []byte{'R', 'D', 'L', 'U'}
	for scanner.Scan() {
		path_parts := strings.Split(scanner.Text(), " ")
		directionStr, distanceStr, color := path_parts[0], path_parts[1], path_parts[2]
		part1Dist, _ := strconv.Atoi(distanceStr)
		part1Path = append(part1Path, Step{directionStr[0], part1Dist})
		part2Dist, _ := strconv.ParseInt(color[2:7], 16, 64)
		part2DirInt, _ := strconv.Atoi(string(color[7]))
		part2Dir := directions[part2DirInt]
		part2Path = append(part2Path, Step{part2Dir, int(part2Dist)})
	}
	return part1Path, part2Path
}

func runStep(x int, y int, step Step) (int, int) {
	switch step.direction {
	case 'R':
		return x + step.distance, y
	case 'D':
		return x, y + step.distance
	case 'L':
		return x - step.distance, y
	case 'U':
		return x, y - step.distance
	}
	return 0, 0
}

func findVertices(path []Step) []V {
	x, y := 0, 0
	vertices := []V{{x, y}}

	for _, step := range path {
		x, y = runStep(x, y, step)
		vertices = append(vertices, V{x, y})
	}

	return vertices
}

func area(vertices []V, path []Step) int {
	sum := 0
	lastVIndex := len(vertices) - 1
	for i := range lastVIndex {
		v1, v2 := vertices[i], vertices[i+1]
		sum += (v1.x * v2.y) - (v1.y * v2.x)
	}
	sum += (vertices[lastVIndex].x * vertices[0].y) - (vertices[lastVIndex].y * vertices[0].x)
	sum = int(math.Abs(float64(sum)))
	for _, s := range path {
		sum += s.distance
	}
	return sum/2 + 1
}

func main() {
	part1Path, part2Path := ParseInput()

	fmt.Println(area(findVertices(part1Path), part1Path))
	fmt.Println(area(findVertices(part2Path), part2Path))
}
