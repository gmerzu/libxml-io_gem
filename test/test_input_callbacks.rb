require 'test_helper'

class TestInputCallbacks < Minitest::Test
  XML = <<-'EOS'.gsub(/^\s*/, '')
    <?xml version="1.0" encoding="UTF-8"?>
    <root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="test.xsd">
      <name>test</name>
      <num>12345</num>
    </root>
  EOS

  XSD_COMMON = <<-'EOS'.gsub(/^\s*/, '')
    <?xml version="1.0" encoding="utf-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xs:simpleType name="NumType">
        <xs:restriction base="xs:string">
          <xs:pattern value="([0-9]{5,10})"/>
        </xs:restriction>
      </xs:simpleType>
      <xs:simpleType name="NameType">
        <xs:restriction base="xs:string">
          <xs:minLength value="1"/>
        </xs:restriction>
      </xs:simpleType>
    </xs:schema>
  EOS

  XSD = <<-'EOS'.gsub(/^\s*/, '')
    <?xml version="1.0" encoding="utf-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xs:include schemaLocation="test_common.xsd"/>
      <xs:element name="root" type="RootContent"/>
      <xs:complexType name="RootContent">
        <xs:sequence>
          <xs:element name="name" type="NameType"/>
          <xs:element name="num" type="NumType"/>
        </xs:sequence>
      </xs:complexType>
    </xs:schema>
  EOS

  class InputCbc
    def initialize
      @xsd = ['test_common.xsd']
    end

    def match filename
      @xsd.include? filename
    end

    def query filename
      case filename
      when 'test_common.xsd'
        XSD_COMMON
      end
    end
  end

  def test_input_callbacks
    LibXML::IO::InputCallbacks.register
    LibXML::IO::InputCallbacks.add_handler InputCbc.new

    xsd = Nokogiri::XML::Schema(XSD)
    xml = Nokogiri::XML.parse(XML)

    errors = xsd.validate(xml).map(&:message)

    LibXML::IO::InputCallbacks.clear_handlers
    LibXML::IO::InputCallbacks.pop

    assert(errors.empty?)
  end
end
