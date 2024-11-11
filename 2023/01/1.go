package main

import (
	"bufio"
	"fmt"
	"regexp"
	"slices"
	"strings"
	"strconv"
	"os"
)

func sanitize(line string, replacements map[string]string) (string) {
	for old, new := range replacements {
		line = strings.ReplaceAll(line, old, new)
	}
	return line
}

func convert(digit string, digits []string) (string) {
	idx := slices.Index(digits, digit)
	if idx > -1 {
		return strconv.Itoa(idx)
	} else {
		return digit
	}
}

func main() {
  scanner := bufio.NewScanner(os.Stdin)
  sum := 0

	replacements := map[string]string {
		"oneight": "oneeight",
	  "twone": "twoone",
	  "threeight": "threeeight",
	  "fiveight": "fiveeight",
	  "sevenine": "sevinnine",
	  "eightwo": "eighttwo",
	  "eighthree": "eightthree",
	  "nineight": "nineeight",
	}

	digit_strings := []string{"zero","one","two","three","four","five","six","seven","eight","nine"}

  re := regexp.MustCompile(`\d|zero|one|two|three|four|five|six|seven|eight|nine`)

  for scanner.Scan() {
  	text := sanitize(scanner.Text(), replacements)
  	digits := re.FindAllString(text, -1)
  	value, _ := strconv.Atoi(convert(digits[0], digit_strings) + convert(digits[len(digits) - 1], digit_strings))
  	sum = sum + value
  }

  fmt.Println(sum)
}
