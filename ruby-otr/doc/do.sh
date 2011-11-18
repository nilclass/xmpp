#!/bin/bash
cd ../ext/
ruby extconf.rb && make && cd .. && ruby ./doc/jabber_echo_example.rb
