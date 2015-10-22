require 'gyoku'

module Aliyun
  module Oss
    class XmlBuilder

      def self.to_xml(hash)
        %Q[<?xml version="1.0" encoding="UTF-8"?>#{Gyoku.xml(hash)}]
      end

    end
  end
end
