package main

import (
	"bufio"
	"cmp"
	"errors"
	"fmt"
	"os"
	"regexp"
	"slices"
	"strconv"
	"strings"
)

type transformation struct {
	to   Range
	from Range
}

type Range struct {
	min int
	max int
}

func parseNumbers(str string) []int {
	number_re := regexp.MustCompile(`\d+`)
	numbers := []int{}
	for _, s := range number_re.FindAllString(str, -1) {
		n, _ := strconv.Atoi(s)
		numbers = append(numbers, n)
	}
	return numbers
}

func intersection(r1 *Range, r2 *Range) (*Range, error) {
	if r1.max < r2.min || r1.min > r2.max {
		return nil, errors.New("no intersection")
	}
	return &Range{max(r1.min, r2.min), min(r1.max, r2.max)}, nil
}

func transform_ranges(tfms []transformation, ranges []Range) []Range {
	tfm_ranges := []Range{}
	for _, rng := range ranges {
		uncovered_ranges := []Range{rng}
		for _, tfm := range tfms {
			urs := []Range{}
			for _, ur := range uncovered_ranges {
				ir, err := intersection(&ur, &tfm.from)
				if err != nil {
					urs = append(urs, ur)
					continue
				}
				if ur.min < ir.min {
					urs = append(urs, Range{ur.min, ir.min - 1})
				}
				if ir.max < ur.max {
					urs = append(urs, Range{ir.max, ur.max - 1})
				}

				begin_offset := ir.min - tfm.from.min
				end_offset := tfm.from.max - ir.max
				tfm_ranges = append(tfm_ranges, Range{tfm.to.min + begin_offset, tfm.to.max - end_offset})
			}
			uncovered_ranges = urs
		}
		tfm_ranges = slices.Concat(tfm_ranges, uncovered_ranges)
	}

	return tfm_ranges
}

func parse_input() ([][]transformation, []int) {
	scanner := bufio.NewScanner(os.Stdin)
	transformation_groups := [][]transformation{}
	tfmg_number := -1

	scanner.Scan()
	seeds := parseNumbers(scanner.Text())

	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, ":") {
			tfmg_number += 1
			transformation_groups = append(transformation_groups, []transformation{})
			continue
		} else if len(strings.TrimSpace(line)) == 0 {
			continue
		}
		parts := parseNumbers(line)
		tfm := transformation{Range{parts[0], parts[0] + parts[2] - 1}, Range{parts[1], parts[1] + parts[2] - 1}}
		transformation_groups[tfmg_number] = append(transformation_groups[tfmg_number], tfm)
	}

	return transformation_groups, seeds
}

func process_transformations(tfm_groups [][]transformation, seed Range) []Range {
	ranges := []Range{seed}
	for _, tfms := range tfm_groups {
		ranges = transform_ranges(tfms, ranges)
	}
	return ranges
}

func min_from_ranges(tfm_groups [][]transformation, seed_ranges []Range) int {
	minimums := []int{}
	for _, sr := range seed_ranges {
		ranges := process_transformations(tfm_groups, sr)
		min_range := slices.MinFunc(ranges, func(r1 Range, r2 Range) int {
			return cmp.Compare(r1.min, r2.min)
		})
		minimums = append(minimums, min_range.min)
	}
	return slices.Min(minimums)
}

func part1(tfm_groups [][]transformation, seeds []int) int {
	seed_ranges := make([]Range, len(seeds))
	for i, s := range seeds {
		seed_ranges[i] = Range{s, s}
	}
	return min_from_ranges(tfm_groups, seed_ranges)
}

func part2(tfm_groups [][]transformation, seeds []int) int {
	seed_ranges := make([]Range, len(seeds)/2)
	for i := 0; i < len(seeds)-1; i += 2 {
		seed_ranges[i/2] = Range{seeds[i], seeds[i] + seeds[i+1] - 1}
	}
	return min_from_ranges(tfm_groups, seed_ranges)
}

func main() {
	transformation_groups, seeds := parse_input()
	fmt.Println(part1(transformation_groups, seeds))
	fmt.Println(part2(transformation_groups, seeds))
}
