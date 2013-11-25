module Zuora::Objects
  class Export < Base
  	validates_presence_of :query, :zip
  	define_attributes do
      read_only  :created_by_id, :created_date, :updated_by_id, :updated_date
    end
  end
end
