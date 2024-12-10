package main

import (
	"bufio"
	"os"
	"slices"
)

func checksum(disk []int) int {
	sum := 0
	for i, fileId := range disk {
		if fileId != -1 {
			sum += (fileId * i)
		}
	}
	return sum
}

func emptySpace(disk []int, location, size int) bool {
	for i := 0; i < size; i++ {
		if disk[location+i] != -1 {
			return false
		}
	}
	return true
}

func compact(disk []int, whole_chunk bool) []int {
	newDisk := make([]int, len(disk))
	copy(newDisk, disk)
	for chunkIndex := len(newDisk) - 1; chunkIndex > 0; chunkIndex-- {
		if newDisk[chunkIndex] == -1 {
			continue
		}
		chunkSize := 1
		fileId := newDisk[chunkIndex]

		if whole_chunk {
			for chunkIndex > 0 && newDisk[chunkIndex-1] == fileId {
				chunkSize++
				chunkIndex--
			}
			if chunkIndex == 0 {
				break
			}
		}

		for spaceIndex := range chunkIndex - 1 {
			if emptySpace(newDisk, spaceIndex, chunkSize) {
				for offset := range chunkSize {
					newDisk[spaceIndex+offset] = fileId
					newDisk[chunkIndex+offset] = -1
				}
				break
			}
		}
	}
	return newDisk
}

func parseInput() []int {
	disk := []int{}
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	for i, d := range scanner.Text() {
		size := int(d - '0')
		chunk := make([]int, size)
		var fileId int

		if i%2 == 0 {
			fileId = i / 2
		} else {
			fileId = -1
		}

		for l := range size {
			chunk[l] = fileId
		}
		disk = slices.Concat(disk, chunk)
	}
	return disk
}

func main() {
	disk := parseInput()
	newDisk := compact(disk, false)
	println(checksum(newDisk))

	newDisk = compact(disk, true)
	println(checksum(newDisk))
}
