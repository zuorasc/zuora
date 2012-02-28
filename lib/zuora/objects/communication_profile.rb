module Zuora::Objects
  class CommunicationProfile < Base
    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :updated_date,
        :description, :profile_name
    end

    # This is a read only record returned from queries
    def save
      false
    end

  end
end
