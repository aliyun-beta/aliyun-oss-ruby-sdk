module Aliyun
  module Owner
    attr_reader :id, :display_name

    def initialize(id, display_name)
      @id = id
      @display_name = display_name
    end
  end
end
