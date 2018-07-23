dir = File.dirname(__FILE__)
root = File.expand_path(File.join(dir, '..'))
lib = File.expand_path(File.join(root, 'lib'))
ext = File.expand_path(File.join(root, 'ext', 'libxml-io'))

$LOAD_PATH << lib
$LOAD_PATH << ext

require 'nokogiri'
require 'libxml/io'
require 'minitest/autorun'
