#!/usr/bin/expect  

set timeout 10  
spawn redis 
expect {
            "Can I set the above configuration? (type 'yes' to accept):" {
            send "yes\r"
            }
        }
expect eof
