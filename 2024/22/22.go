package main

import (
	"bufio"
	"os"
	"strconv"
)

type Sequence struct {
	a int
	b int
	c int
	d int
}

func parseInput() []int {
	scanner := bufio.NewScanner(os.Stdin)
	secrets := []int{}
	for scanner.Scan() {
		secrets = append(secrets, atoi(scanner.Text()))
	}
	return secrets
}

func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

var PRUNE int = 16777216

func lastDigit(n int) int {
	s := strconv.Itoa(n)
	return atoi(string(s[len(s)-1]))
}

func nextSecret(s int) int {
	a := ((s << 6) ^ s) % PRUNE
	b := ((a >> 5) ^ a) % PRUNE
	return ((b << 11) ^ b) % PRUNE
}

func generateSecrets(init int) ([]int, []int, int) {
	secrets := make([]int, 2001)
	changes := make([]int, 2000)
	secret := init
	secrets[0] = lastDigit(secret)
	for i := 1; i <= 2000; i++ {
		secret = nextSecret(secret)
		secrets[i] = lastDigit(secret)
		changes[i-1] = secrets[i] - secrets[i-1]
	}
	return secrets, changes, secret
}

func sequenceAt(list []int, i int) Sequence {
	return Sequence{list[i], list[i+1], list[i+2], list[i+3]}
}

func fetchSequenceIndexes(changes []int) map[Sequence]int {
	indexes := map[Sequence]int{}
	for i := 0; i < len(changes)-3; i++ {
		seq := sequenceAt(changes, i)
		_, found := indexes[seq]
		if !found {
			indexes[seq] = i + 4
		}
	}
	return indexes
}

func sequenceSum(histories map[int][]int, sequenceIndexes map[int]map[Sequence]int, seq Sequence) int {
	sum := 0
	for init, history := range histories {
		idx, found := sequenceIndexes[init][seq]
		if found {
			sum += history[idx]
		}
	}
	return sum
}

func findSumWithBestSequence(histories map[int][]int, sequenceIndexes map[int]map[Sequence]int) int {
	visited := map[Sequence]bool{}
	best := 0
	for _, indexes := range sequenceIndexes {
		for seq := range indexes {
			if visited[seq] {
				continue
			}
			visited[seq] = true
			sum := sequenceSum(histories, sequenceIndexes, seq)
			best = max(sum, best)
		}
	}
	return best
}

func main() {
	initialSecrets := parseInput()
	histories := map[int][]int{}
	sequenceIndexes := map[int]map[Sequence]int{}
	lastSecretSum := 0
	for _, secret := range initialSecrets {
		history, changes, lastSecret := generateSecrets(secret)
		histories[secret] = history
		sequenceIndexes[secret] = fetchSequenceIndexes(changes)
		lastSecretSum += lastSecret
	}
	println(lastSecretSum)
	println(findSumWithBestSequence(histories, sequenceIndexes))
}
