package main

import (
  "bufio"
  "fmt"
  "os"
  "regexp"
  "strconv"
)

type partLocation struct {
  part string
  x    int
  y    int
}

func parse_input() ([]string, [][]string) {
  scanner := bufio.NewScanner(os.Stdin)
  schematic := []string{}
  part_coords := [][]string{}
  re := regexp.MustCompile(`[\d.]`)
  y := -1

  for scanner.Scan() {
    y += 1
    line := scanner.Text()
    schematic = append(schematic, line)
    part_coords = append(part_coords, make([]string, len(line)))

    for x, c := range line {
      s := []byte{byte(c)}
      if !re.Match(s) {
        part_coords[y][x] = string(s[:])
      }
    }
  }

  return schematic, part_coords
}

func clamp(v int, lo int, hi int) int {
  if v < lo {
    return lo
  } else if v > hi {
    return hi
  }
  return v
}

func is_part_number(part_coords [][]string, x1 int, x2 int, y1 int, y2 int) bool {
  return len(search_parts(part_coords, x1, x2, y1, y2)) > 0
}

func search_parts(part_coords [][]string, x1 int, x2 int, y1 int, y2 int) []partLocation {
  x1, x2 = clamp(x1, 0, len(part_coords[0])-1), clamp(x2, 0, len(part_coords[0])-1)
  y1, y2 = clamp(y1, 0, len(part_coords)-1), clamp(y2, 0, len(part_coords)-1)
  parts := []partLocation{}

  for x := x1; x <= x2; x++ {
    for y := y1; y <= y2; y++ {
      if len(part_coords[y][x]) > 0 {
        parts = append(parts, partLocation{part_coords[y][x], x, y})
      }
    }
  }
  return parts
}

func part1(schematic []string, part_coords [][]string) int {
  part_finder := regexp.MustCompile(`\d+`)
  part_number_sum := 0

  for y, line := range schematic {
    part_locations := part_finder.FindAllStringIndex(line, -1)

    for _, xs := range part_locations {
      x1, x2 := xs[0], xs[1]
      part := line[x1:x2]

      if is_part_number(part_coords, x1-1, x2, y-1, y+1) {
        part_number, _ := strconv.Atoi(part)
        part_number_sum += part_number
      }
    }
  }
  return part_number_sum
}

func part2(schematic []string, part_coords [][]string) int {
  part_finder := regexp.MustCompile(`\d+`)

  gear_parts := make([][][]int, len(part_coords))
  for y := range len(part_coords) {
    gear_parts[y] = make([][]int, len(part_coords[y]))
  }

  for y, line := range schematic {
    part_locations := part_finder.FindAllStringIndex(line, -1)

    for _, xs := range part_locations {
      x1, x2 := xs[0], xs[1]
      part := line[x1:x2]
      part_number, _ := strconv.Atoi(part)

      for _, part_location := range search_parts(part_coords, x1-1, x2, y-1, y+1) {
        if part_location.part == "*" {
          gear_parts[part_location.y][part_location.x] = append(gear_parts[part_location.y][part_location.x], part_number)
        }
      }
    }
  }

  part2_sum := 0

  for _, ys := range gear_parts {
    for _, part_numbers := range ys {
      if len(part_numbers) > 1 {
        p := 1
        for _, n := range part_numbers {
          p = p * n
        }
        part2_sum += p
      }
    }
  }

  return part2_sum
}

func main() {
  schematic, part_coords := parse_input()
  fmt.Println(part1(schematic, part_coords))
  fmt.Println(part2(schematic, part_coords))
}
