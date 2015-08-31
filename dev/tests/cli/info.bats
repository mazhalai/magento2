#!/usr/bin/env bats

export MOCK=1

@test "info command" {
	bin/magento info
	[ "$status" = 1 ]
}

@test "currency info command" {
	bin/magento info:currency:list
	[ "$status" = 1 ]
}