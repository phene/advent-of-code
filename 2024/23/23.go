package main

import (
	"bufio"
	"os"
	"slices"
	"strings"
)

type Connections map[string][]string

type Pair struct {
	a string
	b string
}
type Triple struct {
	a string
	b string
	c string
}

func parseInput() Connections {
	connections := Connections{}
	scanner := bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		pair := strings.Split(scanner.Text(), "-")
		a, b := pair[0], pair[1]
		connections[a] = append(connections[a], b)
		connections[b] = append(connections[b], a)
	}

	return connections
}

func findTriplesWithT(connections Connections) []Triple {
	triples := map[Triple]bool{}
	visited := map[Pair]bool{}

	for a, bs := range connections {
		for _, b := range bs {
			if visited[Pair{a, b}] {
				continue
			}
			visited[Pair{a, b}] = true

			for _, c := range connections[b] {
				if a == c {
					continue
				}
				if slices.Contains(bs, c) {
					t := []string{a, b, c}
					slices.Sort(t)
					triples[Triple{t[0], t[1], t[2]}] = true
				}
			}
		}
	}
	triplesWithT := []Triple{}
	for triple := range triples {
		if triple.a[0] == 't' || triple.b[0] == 't' || triple.c[0] == 't' {
			triplesWithT = append(triplesWithT, triple)
		}
	}
	return triplesWithT
}

func isClique(connections Connections, clique []string) bool {
	is := true
	for i, a := range clique {
		for j, b := range clique {
			if i == j {
				continue
			}
			if !slices.Contains(connections[a], b) {
				is = false
			}
		}
	}
	return is
}

func combos(arr []string, size int) [][]string {
	if len(arr) == size {
		return [][]string{arr}
	} else if size == 0 {
		return [][]string{}
	}
	assume_with_first := combos(arr[1:], size-1)
	with_first := make([][]string, len(assume_with_first))
	for i, item := range assume_with_first {
		with_first[i] = slices.Concat([]string{arr[0]}, item)
	}
	without_first := combos(arr[1:], size)
	return slices.Concat(with_first, without_first)
}

func largestCliqueWith(connections Connections, a string) []string {
	largest := []string{}
	for i := len(connections[a]) + 1; i >= 1; i-- {
		for _, clique := range combos(append(slices.Clone(connections[a]), a), i) {
			if isClique(connections, clique) && len(clique) > len(largest) {
				largest = clique
			}
			if len(largest) == i {
				break
			}
		}
		if len(largest) == i {
			break
		}
	}
	return largest
}

func findLargestClique(connections Connections) []string {
	largest := []string{}
	for a := range connections {
		clique := largestCliqueWith(connections, a)
		if len(clique) > len(largest) {
			largest = clique
		}
	}
	slices.Sort(largest)
	return largest
}

func main() {
	connections := parseInput()

	triplesWithT := findTriplesWithT(connections)
	println(len(triplesWithT))

	clique := findLargestClique(connections)
	println(strings.Join(clique, ","))
}
