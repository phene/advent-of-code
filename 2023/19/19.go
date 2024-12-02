package main

import (
	"bufio"
	"errors"
	"fmt"
	"maps"
	"os"
	"regexp"
	"slices"
	"strconv"
	"strings"
)

type Rule struct {
	attrType    string
	gt          bool
	threshold   int
	destination string
}

func (r *Rule) satisfied(part *Part) bool {
	if len(r.attrType) == 0 {
		return true
	}
	var ruleAttr Attribute
	for _, attr := range part.attrs {
		if r.attrType == attr.t {
			ruleAttr = attr
		}
	}

	if r.gt {
		return ruleAttr.r > r.threshold
	}
	return ruleAttr.r < r.threshold
}

func (r *Rule) negate() Rule {
	if r.gt {
		return Rule{r.attrType, false, r.threshold + 1, r.destination}
	} else {
		return Rule{r.attrType, true, r.threshold - 1, r.destination}
	}
}

func (r *Rule) toRange() Range {
	if r.gt {
		return Range{r.threshold + 1, RANGE_MAX}
	} else {
		return Range{RANGE_MIN, r.threshold - 1}
	}
}

type Workflow struct {
	name  string
	rules []Rule
}

func (w Workflow) process(p *Part) string {
	for _, r := range w.rules {
		if r.satisfied(p) {
			return r.destination
		}
	}
	return w.rules[len(w.rules)-1].destination
}

type Part struct {
	attrs []Attribute
}

func (p Part) value() int {
	sum := 0
	for _, attr := range p.attrs {
		sum += attr.r
	}
	return sum
}

type Attribute struct {
	t string
	r int
}

type Path struct {
	rules   []Rule
	next_wf string
}

var RANGE_MIN int = 1
var RANGE_MAX int = 4000
var ATTR_TYPES []string = []string{"x", "m", "a", "s"}

type Range struct {
	min int
	max int
}

func (r Range) size() int {
	return r.max - r.min + 1
}

func (r Range) intersection(or Range) (*Range, error) {
	if r.max < or.min || r.min > or.max {
		return nil, errors.New("no intersection")
	}
	return &Range{max(r.min, or.min), min(r.max, or.max)}, nil
}

func (r Range) merge(or Range) (*Range, error) {
	if r.max < or.min || r.min > or.max {
		return nil, errors.New("no intersection")
	}
	return &Range{min(r.min, or.min), max(r.max, or.max)}, nil
}

type RangeSet map[string]Range

func (rs1 RangeSet) merge(rs2 RangeSet) (*RangeSet, error) {
	nsr := RangeSet{}
	for _, attrType := range ATTR_TYPES {
		ir, err := rs1[attrType].merge(rs2[attrType])
		if err != nil {
			return nil, errors.New("no intersection")
		}
		nsr[attrType] = *ir
	}
	return &nsr, nil
}

func ParseInput() (map[string]Workflow, []Part) {
	scanner := bufio.NewScanner(os.Stdin)
	workflows, parts := map[string]Workflow{}, []Part{}
	partAttributeRe := regexp.MustCompile(`\w+=\d+`)

	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			continue
		}

		if line[0] == '{' { // part
			attr_strs := partAttributeRe.FindAllString(line, 4)
			attrs := []Attribute{}
			for _, attr_str := range attr_strs {
				type_and_rating := strings.Split(attr_str, "=")
				r, _ := strconv.Atoi(type_and_rating[1])
				attrs = append(attrs, Attribute{type_and_rating[0], r})
			}
			parts = append(parts, Part{attrs})
		} else { // workflow
			wf_parts := strings.Split(line[:len(line)-1], "{")
			workflow_name, rules_str := wf_parts[0], wf_parts[1]
			rules := []Rule{}
			for _, rule_str := range strings.Split(rules_str, ",") {
				rule_parts := strings.Split(rule_str, ":")
				if len(rule_parts) == 1 {
					rules = append(rules, Rule{destination: rule_parts[0]})
				} else {
					cond, dest := rule_parts[0], rule_parts[1]
					if strings.Contains(cond, "<") {
						cond_parts := strings.Split(cond, "<")
						attr_t, threshold_s := cond_parts[0], cond_parts[1]
						threshold, _ := strconv.Atoi(threshold_s)
						rules = append(rules, Rule{attr_t, false, threshold, dest})
					} else { // >
						cond_parts := strings.Split(cond, ">")
						attr_t, threshold_s := cond_parts[0], cond_parts[1]
						threshold, _ := strconv.Atoi(threshold_s)
						rules = append(rules, Rule{attr_t, true, threshold, dest})
					}
				}
			}

			workflows[workflow_name] = Workflow{workflow_name, rules}
		}
	}
	return workflows, parts
}

func part1ProcessParts(workflows map[string]Workflow, parts []Part) int {
	acceptedPartRatingSum := 0
	for _, part := range parts {
		workflow_name := "in"
		for workflow_name != "A" && workflow_name != "R" {
			workflow_name = workflows[workflow_name].process(&part)
		}
		if workflow_name == "A" {
			acceptedPartRatingSum += part.value()
		}
	}
	return acceptedPartRatingSum
}

func negateRules(rules []Rule) []Rule {
	nRules := make([]Rule, len(rules))
	for i, r := range rules {
		nRules[i] = r.negate()
	}
	return nRules
}

func workflowPaths(workflows map[string]Workflow) ([]Path, []Path) {
	acceptedPaths, rejectedPaths := []Path{}, []Path{}
	partialPaths := []Path{{[]Rule{}, "in"}}
	var path Path

	for len(partialPaths) > 0 {
		path, partialPaths = partialPaths[0], partialPaths[1:]

		if path.next_wf == "A" {
			acceptedPaths = append(acceptedPaths, path)
		} else if path.next_wf == "R" {
			rejectedPaths = append(rejectedPaths, path)
		}

		wf := workflows[path.next_wf]
		for i, rule := range wf.rules {
			nextRules := negateRules(wf.rules[:i])
			partialPaths = append(partialPaths, Path{slices.Concat(path.rules, nextRules, []Rule{rule}), rule.destination})
		}
	}

	return acceptedPaths, rejectedPaths
}

func mergeRangeSets(rangeSets []RangeSet) []RangeSet {
	newRangeSets := []RangeSet{}
	indexesMerged := map[int]bool{}
	var nrs RangeSet

	for i, rs := range rangeSets {
		if indexesMerged[i] {
			continue
		}
		nrs = rs

		for j := i + 1; j < len(rangeSets); j++ {
			if indexesMerged[j] {
				continue
			}

			mrs, err := nrs.merge(rangeSets[j])

			if err == nil {
				nrs = *mrs
				indexesMerged[j] = true
			}
		}

		indexesMerged[i] = true
		newRangeSets = append(newRangeSets, nrs)
	}

	return newRangeSets
}

func intersectRanges(rs []Range) (*Range, error) {
	var nr = rs[0]
	for i := 1; i < len(rs); i++ {
		ir, err := nr.intersection(rs[i])
		if err != nil {
			return nil, errors.New("Failed to intersect ranges")
		}
		nr = *ir
	}
	return &nr, nil
}

func rangeSetsFromPaths(paths []Path) []RangeSet {
	rangeSets := []RangeSet{}
	for _, path := range paths {
		ranges := map[string][]Range{}
		// convert rules to ranges
		for _, rule := range path.rules {
			if len(rule.attrType) >= 0 {
				ranges[rule.attrType] = append(ranges[rule.attrType], rule.toRange())
			}
		}
		rangeSet := RangeSet{}
		// find intersection of ranges
		for _, attrType := range ATTR_TYPES {
			if len(ranges[attrType]) == 0 {
				rangeSet[attrType] = Range{RANGE_MIN, RANGE_MAX}
			} else {
				r, err := intersectRanges(ranges[attrType])
				if err != nil {
					fmt.Println(err)
				}
				rangeSet[attrType] = *r
			}
		}
		rangeSets = append(rangeSets, rangeSet)
	}
	return rangeSets
}

func sumCombinations(rangeSets []RangeSet) int {
	sum := 0
	for _, rangeSet := range rangeSets {
		p := 1
		for r := range maps.Values(rangeSet) {
			p *= r.size()
		}
		sum += p
	}
	return sum
}

func main() {
	workflows, parts := ParseInput()
	fmt.Println(part1ProcessParts(workflows, parts))

	acceptedPaths, _ := workflowPaths(workflows)
	rangeSets := rangeSetsFromPaths(acceptedPaths)
	rangeSets = mergeRangeSets(rangeSets)
	fmt.Println(sumCombinations(rangeSets))
}
