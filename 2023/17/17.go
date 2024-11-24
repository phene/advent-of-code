package main

import (
	"bufio"
	"container/heap"
	"fmt"
	"math"
	"os"
	"strconv"
)

// A PriorityQueue implements heap.Interface and holds Items.
type PriorityQueue []*Item

func (pq PriorityQueue) Len() int { return len(pq) }

func (pq PriorityQueue) Less(i, j int) bool {
	return pq[i].distance < pq[j].distance
}

func (pq PriorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
	pq[i].index = i
	pq[j].index = j
}

func (pq *PriorityQueue) Push(x any) {
	n := len(*pq)
	item := x.(*Item)
	item.index = n
	*pq = append(*pq, item)
}

func (pq *PriorityQueue) Pop() any {
	old := *pq
	n := len(old)
	item := old[n-1]
	old[n-1] = nil  // don't stop the GC from reclaiming the item eventually
	item.index = -1 // for safety
	*pq = old[0 : n-1]
	return item
}

type Item struct {
	v        V
	index    int
	distance int
}

type V struct {
	p  P
	dx int
	dy int
}

type P struct {
	x int
	y int
}

type R struct {
	begin int
	end   int
}

func abs(n int) int {
	return int(math.Abs(float64(n)))
}

func canChangeDirection(dx int, dy int, r R) bool {
	d := abs(dx) + abs(dy)
	return r.begin <= d && r.end >= d
}

func ParseInput() [][]int {
	scanner := bufio.NewScanner(os.Stdin)
	grid := [][]int{}
	for scanner.Scan() {
		line := scanner.Text()
		row := make([]int, len(line))
		for i, d := range line {
			n, _ := strconv.Atoi(string(d))
			row[i] = n
		}
		grid = append(grid, row)
	}
	return grid
}

func fetchNeighbors(v V, xmax int, ymax int, r R) []V {
	neighbors := []V{}
	for _, n := range []P{{1, 0}, {-1, 0}, {0, -1}, {0, 1}} {
		ndx, ndy := n.x, n.y
		nx, ny := v.p.x+ndx, v.p.y+ndy
		neighbor := V{P{nx, ny}, ndx, ndy}

		if nx < 0 || nx > xmax || ny < 0 || ny > ymax {
			continue
		} else if v.dy*ndy < 0 || v.dx*ndx < 0 { // no back-tracking
			continue
		} else if v.dy*ndy == 0 && v.dx*ndx == 0 { // changing direction
			if canChangeDirection(v.dx, v.dy, r) {
				neighbors = append(neighbors, neighbor)
			}
			continue
			// Check for exceeding direction limit
		} else if ndx == 0 && abs(v.dy+ndy) <= r.end {
			neighbors = append(neighbors, neighbor)
		} else if abs(v.dx+ndx) <= r.end {
			neighbors = append(neighbors, neighbor)
		}
	}
	return neighbors
}

func traverse(grid [][]int, start P, r R) int {
	ymax, xmax := len(grid)-1, len(grid[0])-1
	finish := P{xmax, ymax}
	positions := make(PriorityQueue, 2)
	positions[0] = &Item{V{start, 1, 0}, 0, 0}
	positions[1] = &Item{V{start, 0, 1}, 0, 0}
	heap.Init(&positions)
	visited := map[V]int{}

	for len(positions) > 0 {
		position := heap.Pop(&positions).(*Item)
		v := position.v
		vd, exists := visited[v]

		if exists && vd <= position.distance {
			continue
		} else if position.v.p == finish {
			if canChangeDirection(position.v.dx, position.v.dy, r) {
				return position.distance
			} else {
				continue
			}
		}

		for _, neighbor := range fetchNeighbors(v, xmax, ymax, r) {
			if v.dx == 0 && neighbor.dx == 0 {
				neighbor.dy += v.dy
			} else if v.dy == 0 && neighbor.dy == 0 {
				neighbor.dx += v.dx
			}
			heap.Push(&positions, &Item{
				v:        neighbor,
				distance: position.distance + grid[neighbor.p.y][neighbor.p.x],
			})
		}

		visited[v] = position.distance
	}

	return 0
}

func main() {
	grid := ParseInput()

	fmt.Println(traverse(grid, P{0, 0}, R{1, 3}))
	fmt.Println(traverse(grid, P{0, 0}, R{4, 10}))
}
