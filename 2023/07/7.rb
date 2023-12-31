#!/usr/bin/env ruby

RANK_MATRIX = [
  # Label            Tie compare method          Rank check
  ['high card',      :highest_card,              :highest_card    ],
  ['one pair',       :highest_kind_largest_set,  :one_pair?       ],
  ['two pairs',      :highest_kind_largest_set,  :two_pair?       ],
  ['3 of a kind',    :highest_kind_largest_set,  :three_of_kind?  ],
  ['full house',     :highest_kind_largest_set,  :full_house?     ],
  ['4 of a kind',    :highest_kind_largest_set,  :four_of_kind?   ],
  ['5 of a kind',    :highest_kind_largest_set,  :five_of_kind?   ],
]

RANK_LABEL = RANK_MATRIX.each_with_index.map { |rank_info, index| [index, rank_info[0]] }.to_h

class Card
  include Comparable
  KINDS = %w[J 2 3 4 5 6 7 8 9 T Q K A]

  attr_reader :kind
  attr_reader :kind_value

  def initialize(card_text)
    @kind = card_text[0]
    @kind_value = KINDS.index(@kind)
  end

  def <=>(other_card)
    kind_value <=> other_card.kind_value
  end

  def joker?
    kind == 'J'
  end

  def to_s
    kind
  end
end

class Hand
  RANK_CHECKLIST = RANK_MATRIX.map { |rank_info| rank_info[2] }
  RANK_COMPARE_METHOD = RANK_MATRIX.each_with_index.map { |rank_info, index| [index, rank_info[1]] }.to_h
  ROYAL_KINDS = %w[T J Q K A]

  include Comparable

  attr_reader :orig_cards
  attr_reader :cards
  attr_reader :bid

  def initialize(cards, bid)
    @orig_cards = cards.map(&:dup)
    @cards = cards.sort
    @bid   = bid
  end

  def highest_card
    cards.last
  end

  def to_s
    orig_cards.join(' ')
  end

  def rank
    @rank ||= begin
      best_r = -1
      replace_jokers do
        r = RANK_CHECKLIST.size - RANK_CHECKLIST.reverse.each_with_index.inject(-1) do |best_rank, (check, index)|
          next index if best_rank == -1 && public_send(check)
          best_rank
        end
        best_r = r if r > best_r
      end
      best_r
    end
  end

  def replace_jokers
    jokers, non_jokers = cards.partition(&:joker?)

    iterate_jokers(jokers) do |replacements|
      @cards = non_jokers + replacements
      clear_cache
      yield
    end

    @cards = @orig_cards.map(&:dup).sort
  end

  def iterate_jokers(jokers, &block)
    yield [] and return if jokers.empty?

    non_jokers = Card::KINDS[1..] * jokers.size
    non_jokers.combination(jokers.size) do |replacements|
      rs = replacements.map { |kind| Card.new(kind) }
      yield rs
    end
  end

  def one_pair?
    pairs.size == 1
  end

  def two_pair?
    pairs.size == 2
  end

  def full_house?
    full_house.compact.size == 2
  end

  def full_house
    @full_house ||= begin
      pair = nil
      triple = nil
      sets_of_kind.each do |kind, cards|
        if cards.size == 3
          triple = cards
        elsif cards.size == 2
          pair = cards
        end
      end
      [triple, pair]
    end
  end

  def pairs # Consider rewriting with tally
    @pairs ||= [].tap do |pairs|
      sets_of_kind.each do |kind, cards|
        pairs << Pair.new(cards) if cards.size == 2
      end
    end.sort
  end

  def three_of_kind?
    largest_set_of_kind.size == 3
  end

  def four_of_kind?
    largest_set_of_kind.size == 4
  end

  def five_of_kind?
    largest_set_of_kind.size == 5
  end

  def largest_set_of_kind
    @largest_set_of_kind ||= sets_of_kind.to_a.inject do |largest_set, next_set|
      next largest_set if largest_set[1].size > next_set[1].size
      next_set
    end.last
  end

  def sets_of_kind
    @set_of_kind ||= Hash.new { |h, k| h[k] = [] }.tap do |sets|
      cards.each do |card|
        sets[card.kind] << card
      end
    end
  end

  def clear_cache
    @largest_set_of_kind = nil
    @set_of_kind = nil
    @pairs = nil
    @full_house = nil
  end

  def <=>(other_hand)
    return rank <=> other_hand.rank if rank != other_hand.rank
    (0...5).each do |idx|
      res = (orig_cards[idx] <=> other_hand.orig_cards[idx])
      return res unless res == 0
    end
    0
  end
end

class Pair
  include Comparable
  attr_reader :cards
  attr_reader :kind_value

  def initialize(cards)
    @cards = cards
    @kind = cards.first.kind
    @kind_value = cards.first.kind_value
  end

  def <=>(other_pair)
    kind_value <=> other_pair.kind_value
  end
end

def parse_hands(io)
  io.readlines.map do |line|
    cards, bid = line.split(' ')
    cards = cards.each_char.map { |char| Card.new(char) }
    Hand.new(cards, bid.to_i)
  end
end

hands = parse_hands($stdin).sort

score = hands.each_with_index.sum do |hand, rank|
  hand.bid * (rank + 1)
end
puts score

