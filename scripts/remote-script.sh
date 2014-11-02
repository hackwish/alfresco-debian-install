#!/usr/bin/expect -f
set force_conservative 0  ;# set to 1 to force conservative mode even if
                          ;# script wasn't run conservatively originally
if {$force_conservative} {
        set send_slow {1 .1}
        proc send {ignore arg} {
                sleep .1
                exp_send -s -- $arg
        }
}
set timeout -1
set remoteip=
set rootpassword=
set filename=
set fullpath=

spawn sftp -oStrictHostKeyChecking=no root@$remoteip
expect "root@$remoteip's password: "
send -- "$rootpassword\r";
expect "sftp>"
send -- "cd /tmp\r"
expect "sftp>"
send -- "put $fullpath\r"
expect "sftp>"
send -- "exit\r"
interact

spawn ssh -oStrictHostKeyChecking=no root@$remoteip
expect "root@$remoteip's password: "
send -- "$rootpassword\r"
expect ":~#"
send -- "chmod a+x /tmp/$filename\r"
expect ":~#"
send -- "/tmp/$filename\r"
expect ":~#"
send -- "exit\r"
interact
