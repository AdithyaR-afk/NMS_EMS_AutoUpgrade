#!/bin/bash
/usr/bin/expect -c "
set timeout -1
spawn ./readthis.sh

expect  {
     \"input 1\"         { send \"hi\r\"
                           exp_continue
                          }
	\"input 2\"         { send \"hi\r\"
                           exp_continue
                          }
eof	{ exit 1 }
}"
