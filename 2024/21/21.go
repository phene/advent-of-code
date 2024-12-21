package main

import (
	"bufio"
	"image"
	"os"
	"slices"
	"strconv"
)

var DIR_TO_V = map[byte]image.Point{
	'^': {0, -1},
	'>': {1, 0},
	'v': {0, 1},
	'<': {-1, 0},
}
var KEYPAD = map[byte]image.Point{
	'7': {0, 0},
	'8': {1, 0},
	'9': {2, 0},
	'4': {0, 1},
	'5': {1, 1},
	'6': {2, 1},
	'1': {0, 2},
	'2': {1, 2},
	'3': {2, 2},
	'0': {1, 3},
	'A': {2, 3},
}
var KEYPAD_START = KEYPAD['A']
var KEYPAD_DEADSPOT = image.Point{0, 3}
var DPAD = map[byte]image.Point{
	'^': {1, 0},
	'A': {2, 0},
	'<': {0, 1},
	'v': {1, 1},
	'>': {2, 1},
}
var DPAD_START = DPAD['A']
var DPAD_DEADSPOT = image.Point{0, 0}

func xDpadMoves(delta int) string {
	return dpadMoves(delta, '<', '>')
}
func yDpadMoves(delta int) string {
	return dpadMoves(delta, '^', 'v')
}
func dpadMoves(delta int, less byte, more byte) string {
	var arrow byte
	if delta < 0 {
		delta = -delta
		arrow = less
	} else {
		arrow = more
	}
	moves := make([]byte, delta)
	for i := 0; i < delta; i++ {
		moves[i] = arrow
	}
	return string(moves)
}

func uniqueMoves(arr string) []string {
	var helper func([]byte, int)
	res := []string{}
	visits := map[string]bool{}

	helper = func(arr []byte, n int) {
		if n == 1 {
			tmp := string(arr)
			if !visits[tmp] {
				res = append(res, tmp)
				visits[tmp] = true
			}
		} else {
			for i := 0; i < n; i++ {
				helper(arr, n-1)
				if n%2 == 1 {
					tmp := arr[i]
					arr[i] = arr[n-1]
					arr[n-1] = tmp
				} else {
					tmp := arr[0]
					arr[0] = arr[n-1]
					arr[n-1] = tmp
				}
			}
		}
	}
	helper([]byte(arr), len(arr))
	return res
}

func moveSetsToPosition(start image.Point, finish image.Point, deadspot image.Point) []string {
	if start == finish {
		return []string{"A"}
	}
	delta := finish.Sub(start)
	moveSets := []string{}

	for _, moves := range uniqueMoves(xDpadMoves(delta.X) + yDpadMoves(delta.Y)) {
		valid := true
		current := start
		for _, move := range []byte(moves) {
			current = current.Add(DIR_TO_V[move])
			if current == deadspot {
				valid = false
				break
			}
		}
		if valid {
			moveSets = append(moveSets, moves+"A")
		}
	}
	return moveSets
}

type mmCacheKey struct {
	code  string
	depth int
}

var minMovesCache = map[mmCacheKey]int{}

func minMovesForCode(code string, depth int, pad map[byte]image.Point, deadspot image.Point) int {
	cacheKey := mmCacheKey{code, depth}
	cache, exists := minMovesCache[cacheKey]
	if exists {
		return cache
	}
	current := pad['A']
	moveCount := 0

	for _, c := range []byte(code) {
		next := pad[c]
		moveSets := moveSetsToPosition(current, next, deadspot)
		if depth > 0 {
			nextDepthMoves := make([]int, len(moveSets))
			for i, moves := range moveSets {
				nextDepthMoves[i] = minMovesForCode(moves, depth-1, DPAD, DPAD_DEADSPOT)
			}
			moveCount += slices.Min(nextDepthMoves)
		} else {
			moveCount += len(moveSets[0])
		}
		current = next
	}
	minMovesCache[cacheKey] = moveCount
	return moveCount
}

func parseInput() []string {
	scanner := bufio.NewScanner(os.Stdin)
	codes := []string{}
	for scanner.Scan() {
		codes = append(codes, scanner.Text())
	}
	return codes
}

func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func main() {
	codes := parseInput()
	var sum1, sum2 int
	for _, code := range codes {
		codeNumber := atoi(string([]byte(code)[0:3]))
		sum1 += codeNumber * minMovesForCode(code, 2, KEYPAD, KEYPAD_DEADSPOT)
		sum2 += codeNumber * minMovesForCode(code, 25, KEYPAD, KEYPAD_DEADSPOT)
	}
	println(sum1)
	println(sum2)
}
