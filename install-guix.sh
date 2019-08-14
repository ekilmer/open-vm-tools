#!/usr/bin/expect -f
set timeout -1
spawn ./guix-install.sh
expect "Press return to continue..."
send -- "\n"
expect "Permit downloading pre-built package binaries from the project's build farm? (yes/no) "
send -- "y\n"
expect eof
