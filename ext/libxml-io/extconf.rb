#!/usr/bin/env ruby

require 'mkmf'

def crash(str)
  printf(" extconf failure: %s\n", str)
  exit 1
end

xc = with_config('xml2-config')
if xc
  cflags = `#{xc} --cflags`.chomp
  if $CHILD_STATUS
    libs = `#{xc} --libs`.chomp
    if $CHILD_STATUS
      $CFLAGS += ' ' + cflags
      $libs = libs + ' ' + $libs
    end
  end
else
  dir_config('xml2')
end

unless find_header('libxml/xmlversion.h',
                   '/opt/include/libxml2',
                   '/opt/local/include/libxml2',
                   '/usr/local/include/libxml2',
                   '/usr/include/libxml2') &&
       find_library('xml2', 'xmlParseDoc',
                    '/opt/lib',
                    '/opt/local/lib',
                    '/usr/local/lib',
                    '/usr/lib')
  crash(<<EOL)
need libxml2.

    Install the library or try one of the following options to extconf.rb:

      --with-xml2-config=/path/to/xml2-config
      --with-xml2-dir=/path/to/libxml2
      --with-xml2-lib=/path/to/libxml2/lib
      --with-xml2-include=/path/to/libxml2/include
EOL
end

$INCFLAGS << ' -I/usr/local/include'
$CFLAGS << ' ' << $INCFLAGS

create_header
create_makefile('libxml_io')
