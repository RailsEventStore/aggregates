require 'securerandom'

module ProjectManagement
  class Issue
    def initialize(data)
      unless data.class == Data
        raise 'Please use Issue::create to instantiate an Issue'
      end

      @data = data
    end

    def self.create(id:)
      Issue::New.new(Data.new(issue_id: id, title: ''))
    end

    protected

    def data
      @data
    end

    class Data < Dry::Struct
      attribute :issue_id, Types::UUID
      attribute :title, Types::String
    end

    class New < Issue
      def open(title:)
        next_data = data.new(title: title)
        Open.new(next_data)
      end
    end

    class Open < Issue
      def start;   InProgress.new(data) end
      def resolve; Resolved.new(data)   end
      def close;   Closed.new(data)     end
    end

    class InProgress < Issue
      def resolve; Resolved.new(data) end
      def stop;    Open.new(data)     end
      def close;   Closed.new(data)   end
    end

    class Resolved < Issue
      def reopen;  Open.new(data)   end
      def close;   Closed.new(data) end
    end

    class Closed < Issue
      def reopen;  Open.new(data) end
    end
  end
end