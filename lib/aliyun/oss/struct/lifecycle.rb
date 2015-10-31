module Aliyun
  module Oss
    module Struct
      class LifeCycle < Base
        # Rule ID, auto set when not set. [String]
        attr_accessor :id

        # Used for filter objects. [String]
        attr_accessor :prefix

        # Used for set rule status. [Boolean]
        attr_accessor :enabled

        # Set auto delete objects after days since last modified, at least exist one with date [Integer]
        attr_accessor :days

        # Set auto auto delete object at given time, at least exist one with days, [Time]
        attr_accessor :date

        def status=(status)
          @enabled = (status == 'Enabled')
        end

        def date=(date)
          @date = date.is_a?(String) ? Time.parse(date) : date
        end

        def days=(days)
          @days = days.to_i
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

        def expiration=(expiration)
          if expiration.is_a?(Hash)
            if expiration.key?('Days')
              self.days = expiration['Days']
            elsif expiration.key?('Date')
              self.date = expiration['Date']
            end
          end
        end

        def valid?
          prefix && (days || date)
        end

        private

        def status
          enabled ? 'Enabled' : 'Disabled'
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
