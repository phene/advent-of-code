package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func ParseInput() []string {
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	return strings.Split(scanner.Text(), ",")
}

func hashCode(str string) int {
	hsh := 0
	for _, c := range str {
		hsh += int(c)
		hsh = (hsh * 17) % 256
	}
	return hsh
}

func part1(sequences []string) int {
	sum := 0
	for _, seq := range sequences {
		sum += hashCode(seq)
	}
	return sum
}

type Lens struct {
	label string
	focal int
}

func buildBoxes(sequences []string) map[int][]Lens {
	boxes := map[int][]Lens{}
	for _, seq := range sequences {
		if strings.Contains(seq, "-") {
			label := strings.Split(seq, "-")[0]
			box := hashCode(label)
			i := slices.IndexFunc(boxes[box], func(lens Lens) bool {
				return lens.label == label
			})
			if i >= 0 {
				boxes[box] = slices.Delete(boxes[box], i, i+1)
			}
		} else {
			parts := strings.Split(seq, "=")
			label, num := parts[0], parts[1]
			box := hashCode(label)
			focal, _ := strconv.Atoi(num)
			i := slices.IndexFunc(boxes[box], func(lens Lens) bool {
				return lens.label == label
			})
			if i >= 0 {
				boxes[box][i].focal = focal
			} else {
				boxes[box] = append(boxes[box], Lens{label, focal})
			}
		}
	}
	return boxes
}

func part2(sequences []string) int {
	boxes := buildBoxes(sequences)
	sum := 0
	for box, lenses := range boxes {
		for slot, lens := range lenses {
			sum += (box + 1) * lens.focal * (slot + 1)
		}
	}
	return sum
}

func main() {
	sequences := ParseInput()
	fmt.Println(part1(sequences))
	fmt.Println(part2(sequences))
}
