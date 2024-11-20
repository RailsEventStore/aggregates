# frozen_string_literal: true
module ProjectManagement
  class Repository
    class Record < ActiveRecord::Base
      self.table_name = :issues
    end
    private_constant :Record

    State = Struct.new(:id, :status)

    def initialize(id)
      @id = id
    end

    def store(state)
      Record.where(uuid: @id).update_all(status: state.status)
    end

    def load
      record = Record.find_or_create_by(uuid: @id)
      State.new(record.uuid, record.status)
    end
  end
end
