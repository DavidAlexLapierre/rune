package test

import "core:testing"

@(test)
should_run :: proc(t: ^testing.T) {
    result := 2 + 2
    testing.expect(t, result == 4, "The end is nigh")
}