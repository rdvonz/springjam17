#!/bin/bash
openssl s_client -showcerts -connect $1:443 </dev/null 2>/dev/null|openssl x509 -outform CRT >$1.crt
