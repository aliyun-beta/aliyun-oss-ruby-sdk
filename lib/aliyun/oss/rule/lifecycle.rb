module Aliyun
  module Oss
    module Rule
      class LifeCycle
        # [Integer] optional, Rule ID, auto set when not set
        attr_accessor :id

        # [String] Used for filter objects
        attr_accessor :prefix

        # [Boolean] Used for set rule status
        attr_accessor :enable

        # [Integer] Set auto delete objects after days since last modified, at least exist one with date
        attr_accessor :days

        # [Time] Set auto auto delete object at given time, at least exist one with days
        attr_accessor :date

        def initialize(options = {})
          @id = options[:id]
          @prefix = options[:prefix]
          @enable = options[:enable]
          @days = options[:days]
          @date = options[:date]
        end

        def to_hash
          if valid?
            {
              'ID' => id || '',
              'Prefix' => prefix,
              'Status' => status,
              'Expiration' => expiration
            }
          else
            {}
          end
        end

        private

        def valid?
          prefix && (days || date)
        end

        def status
          enable ? 'Enabled' : 'Disabled'
        end

        def expiration
          if date && date.is_a?(Time)
            { 'Date' => date.utc.strftime('%Y-%m-%dT00:00:00.000Z') }
          elsif days && days.is_a?(Integer)
            { 'Days' => days.to_i }
          end
        end
      end
    end
  end
end
