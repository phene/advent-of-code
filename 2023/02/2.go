package main

import (
	"bufio"
	"fmt"
	"regexp"
	"strings"
	"strconv"
	"os"
)

func main() {
  scanner := bufio.NewScanner(os.Stdin)

  re := regexp.MustCompile(`\d+ \w+`)

  part_1_thresholds := map[string]int {"red": 12,"green": 13,"blue": 14}
  game_id, part1_sum, part2_sum := 1, 0, 0

  for scanner.Scan() {
  	cubes := re.FindAllString(strings.Split(scanner.Text(), ":")[1], -1)
	  max_cubes := map[string]int {"red": 0,"green": 0,"blue": 0}

  	for _, cube := range(cubes) {
  		cube_parts := strings.Split(cube, " ")
  		number, _ := strconv.Atoi(cube_parts[0])
  		color := cube_parts[1]
  		if number > max_cubes[color] {
  			max_cubes[color] = number
  		}
  	}

  	part1_threshold := true
  	p := 1
  	for c, n := range(max_cubes) {
  		p = p * n
  		if part_1_thresholds[c] < n {
  			part1_threshold = false
  		}
  	}

    if part1_threshold {
    	part1_sum = part1_sum + game_id
    }
    part2_sum = part2_sum + p
  	game_id = game_id + 1
  }

  fmt.Println(part1_sum, part2_sum)
}
