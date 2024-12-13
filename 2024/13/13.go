package main

import (
	"bufio"
	"image"
	"os"
	"strconv"
	"strings"
)

type Game struct {
	a image.Point
	b image.Point
	p image.Point
}

var CostA int = 3
var CostB int = 1
var Part2Delta int = 10000000000000

func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func readNumbers(line string) (int, int) {
	parts := strings.Split(strings.Split(line, ": ")[1], ", ")
	return atoi(parts[0][2:]), atoi(parts[1][2:])
}

func parseInput() []Game {
	scanner := bufio.NewScanner(os.Stdin)
	games := []Game{}
	for scanner.Scan() {
		x1, y1 := readNumbers(scanner.Text())
		scanner.Scan()
		x2, y2 := readNumbers(scanner.Text())
		scanner.Scan()
		p1, p2 := readNumbers(scanner.Text())
		if scanner.Scan() {
			scanner.Text() // burn empty line
		}
		games = append(games, Game{image.Point{x1, y1}, image.Point{x2, y2}, image.Point{p1, p2}})
	}
	return games
}

func calculateCost(game *Game) int {
	a, b, p := game.a, game.b, game.p
	ad := (b.Y*p.X - b.X*p.Y) / (a.X*b.Y - a.Y*b.X)
	bd := (a.Y*p.X - a.X*p.Y) / (a.Y*b.X - a.X*b.Y)
	if a.Mul(ad).Add(b.Mul(bd)) == p {
		return ad*CostA + bd*CostB
	}
	return 0
}

func main() {
	games := parseInput()

	var sum1, sum2 int = 0, 0
	for _, game := range games {
		sum1 += calculateCost(&game)
		game.p.X += Part2Delta
		game.p.Y += Part2Delta
		sum2 += calculateCost(&game)
	}
	println(sum1)
	println(sum2)
}
