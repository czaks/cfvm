#!/usr/bin/ruby
require "./cfvm.rb"

vm = CFVM.new
vm.basic_lib
File.open("stdlib.cf") { |f| vm.append f.read, "stdlib.cf" }
File.open(ARGV[0])     { |f| vm.append f.read, $0 }
vm.exec
