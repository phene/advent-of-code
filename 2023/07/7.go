package main

import (
	"bufio"
	"cmp"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

type Hand struct {
	cards []int
	bid   int
	score int
}

func CardTallies(cards []int) [][]int {
	tally_map := map[int]int{}
	for _, card := range cards {
		tally_map[card] += 1
	}
	tallies := [][]int{}
	for card, count := range tally_map {
		tallies = append(tallies, []int{card, count})
	}
	slices.SortFunc(tallies, func(c1 []int, c2 []int) int {
		return cmp.Compare(c2[1], c1[1])
	})
	return tallies
}

func Score(cards []int) int {
	tallies := CardTallies(cards)
	switch tallies[0][1] {
	case 5:
		return 7
	case 4:
		return 6
	case 3:
		if tallies[1][1] == 2 {
			return 5
		} else {
			return 4
		}
	case 2:
		if tallies[1][1] == 2 {
			return 3
		} else {
			return 2
		}
	}
	return 1
}

func GenerateCardCombos(n int, highest_card int, cards []int, out chan<- []int) {
	if len(cards) == 0 {
		defer close(out)
	}
	for c := 1; c <= highest_card; c++ {
		if n == 0 {
			out <- append(cards, c)
		} else {
			GenerateCardCombos(n-1, c, append(cards, c), out)
		}
	}
}

func ScoreWithJokers(cards []int) int {
	jokers := []int{}
	for i, card := range cards {
		if card == 0 {
			jokers = append(jokers, i)
		}
	}

	if len(jokers) == 0 {
		return Score(cards)
	}

	highest_score := 0
	combo := make(chan []int)
	go GenerateCardCombos(len(jokers), 12, []int{}, combo)

	for replacements := range combo {
		for i, j := range jokers {
			cards[j] = replacements[i]
		}
		highest_score = max(highest_score, Score(cards))
	}

	for _, j := range jokers {
		cards[j] = 0
	}

	return highest_score
}

func ParseCard(card_symbol byte, jokers bool) int {
	if jokers {
		return strings.Index("J23456789TQKA", string(card_symbol))
	} else {
		return strings.Index("23456789TJQKA", string(card_symbol))
	}
}

func ParseHand(hand_s string, bid_s string, jokers bool) Hand {
	cards := make([]int, 5)
	for i := range 5 {
		cards[i] = ParseCard(hand_s[i], jokers)
	}
	bid, _ := strconv.Atoi(bid_s)
	if jokers {
		return Hand{cards, bid, ScoreWithJokers(cards)}
	} else {
		return Hand{cards, bid, Score(cards)}
	}
}

func ParseInput() [][]string {
	scanner := bufio.NewScanner(os.Stdin)
	hands := [][]string{}

	for scanner.Scan() {
		parts := strings.Split(scanner.Text(), " ")
		hands = append(hands, []string{parts[0], parts[1]})
	}

	return hands
}

func RankSum(hands_and_bids [][]string, jokers bool) int {
	sum := 0
	hands := make([]Hand, len(hands_and_bids))

	for i, hand_and_bid := range hands_and_bids {
		hands[i] = ParseHand(hand_and_bid[0], hand_and_bid[1], jokers)
	}

	slices.SortFunc(hands, func(h1 Hand, h2 Hand) int {
		if h1.score == h2.score {
			for i := range 5 {
				if h1.cards[i] != h2.cards[i] {
					return cmp.Compare(h1.cards[i], h2.cards[i])
				}
			}
			return 0
		} else {
			return cmp.Compare(h1.score, h2.score)
		}
	})

	for r, hand := range hands {
		sum += (r + 1) * hand.bid
	}
	return sum
}

func main() {
	hands_and_bids := ParseInput()
	fmt.Println(RankSum(hands_and_bids, false))
	fmt.Println(RankSum(hands_and_bids, true))
}
