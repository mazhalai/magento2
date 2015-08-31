#!/usr/bin/env bats

export MOCK=1

@test "info command" {
	bin/magento info
	[ "$status" = 0 ]
	[ "${lines[0]}" = "  [InvalidArgumentException]" ]
}
