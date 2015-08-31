#!/usr/bin/env bats

export MOCK=1

@test "info command" {
	run bin/magento info
	[ "$status" = 1 ]
}

@test "currency info command" {
	run bin/magento info:currency:list
	[ "$status" = 0 ]
}