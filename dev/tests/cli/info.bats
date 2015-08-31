#!/usr/bin/env bats

export MOCK=1

@test "Test failure of info command" {
	run bin/magento info
	[ "$status" = 1 ]
}

@test "Test currency info command" {
	run bin/magento info:currency:list
	[ "$status" = 0 ]
	[ "${lines[1]}" = "| Currency                                        | Code |" ]
	[ "${lines[3]}" = "| Afghan Afghani (1927-2002) (AFA)                | AFA  |" ]
}

@test "Test timezone info command" {
	run bin/magento info:timezone:list
	[ "$status" = 0 ]
	[ "${lines[1]}" = "| Timezone                                                   | Code                           |" ]
	[ "${lines[3]}" = "| Afghanistan Time (Asia/Kabul)                              | Asia/Kabul                     |" ]
}

@test "Test timezone info command" {
	run bin/magento info:language:list
	[ "$status" = 0 ]
	[ "${lines[1]}" = "| Language                      | Code       |" ]
	[ "${lines[3]}" = "| Afrikaans (South Africa)      | af_ZA      |" ]
}

@test "Test circular dependency info command" {
	run bin/magento info:dependencies:show-modules-circular
	[ "$status" = 0 ]
	[ "${lines[0]}" = "Report successfully processed." ]
	run ls modules-circular-dependencies.csv
	[ "$status" = 0 ]
}

@test "Test circular dependency info command with output" {
	run bin/magento info:dependencies:show-modules-circular -o var/test-circular.csv
	[ "$status" = 0 ]
	[ "${lines[0]}" = "Report successfully processed." ]
	run ls var/test-circular.csv
	[ "$status" = 0 ]
}

@test "Test framework dependency info command" {
	run bin/magento info:dependencies:show-framework
	[ "$status" = 0 ]
	[ "${lines[0]}" = "Report successfully processed." ]
	run ls framework-dependencies.csv
    [ "$status" = 0 ]
}

@test "Test modules dependency info command" {
	run bin/magento info:dependencies:show-modules
	[ "$status" = 0 ]
	[ "${lines[0]}" = "Report successfully processed." ]
	run ls modules-dependencies.csv
    [ "$status" = 0 ]
}
