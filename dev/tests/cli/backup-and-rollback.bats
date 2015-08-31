#!/usr/bin/env bats

export MOCK=1

@test "Test backup without input " {
	run bin/magento setup:backup
	[ "$status" = 1 ]
	[ "${lines[1]}" = "Not enough information provided to take backup." ]
}

@test "Test backup without installation" {
	run bin/magento setup:backup --db
	[ "$status" = 0 ]
	[ "${lines[0]}" = "No information is available: the Magento application is not installed." ]
}

@test "Test Install" {
    run bin/magento setup:install --db-host=localhost --db-name=magento --db-user=root --admin-user=admin --admin-password=123123q --admin-email=admin@example.com --admin-firstname=John --admin-lastname=Smith
}
