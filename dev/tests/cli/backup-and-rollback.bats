#!/usr/bin/env bats

export MOCK=1

@test "Test backup without input " {
	run bin/magento setup:backup
	[ "$status" = 0 ]
	[ "${lines[1]}" = "Not enough information provided to take backup." ]
}

@test "Test backup without installation" {
	run bin/magento setup:backup --db
	[ "$status" = 0 ]
	[ "${lines[0]}" = "No information is available: the Magento application is not installed." ]
}

@test "Test Install" {
    run bin/magento setup:install --db-host=localhost --db-name=magento_integration_tests --db-user=root --admin-user=admin --admin-password=123123q --admin-email=admin@example.com --admin-firstname=John --admin-lastname=Smith
    [ "$status" = 0 ]
}

@test "Test backup db" {
	run bin/magento setup:backup --db
	[ "$status" = 0 ]
	[ "${lines[0]}" = "Enabling maintenance mode" ]
	[ "${lines[1]}" = "DB backup is starting..." ]
	[ $(expr "${lines[2]}" : "DB backup filename*") -ne 0 ]
	[ $(expr "${lines[3]}" : "DB backup path*") -ne 0 ]
	[ "${lines[4]}" = "[SUCCESS]: DB backup completed successfully." ]
	[ "${lines[5]}" = "Disabling maintenance mode" ]

}

@test "Test backups info list and rollback db" {
    run bin/magento info:backups:list
    [ "$status" = 0 ]
    [ $(expr "${lines[0]}" : "Showing backup files in *") -ne 0]
    [ $(expr "${lines[2]}" : "| Backup Filename  | Backup Type |") -ne 0]
    [ $(expr "${lines[4]}" : "*| db          |") -ne 0]
    lineFour = "${lines[4]}"

    run bin/magento setup:rollback -d  $(lineFour/| //) -n
    [ "$status" = 0 ]
    [ "${lines[0]}" = "Enabling maintenance mode" ]
    [ "${lines[1]}" = "DB rollback is starting..." ]
    [ $(expr "${lines[2]}" : "DB rollback filename: *") -ne 0 ]
    [ $(expr "${lines[3]}" : "DB rollback path: *") -ne 0 ]
    [ "${lines[4]}" = "[SUCCESS]: DB rollback completed successfully." ]
    [ "${lines[5]}" = "Please set file permission of bin/magento to executable" ]
    [ "${lines[6]}" = "Disabling maintenance mode" ]
}
