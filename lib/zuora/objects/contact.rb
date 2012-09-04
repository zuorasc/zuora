module Zuora::Objects
  class Contact < Base
    belongs_to :account

    validates_presence_of :first_name, :last_name
    validates_presence_of :account_id, :unless => Proc.new { |contact| contact.new_record? }
    validates_length_of :first_name, :maximum => 100
    validates_length_of :last_name, :maximum => 100
    validates_length_of :nick_name, :maximum => 100, :allow_nil => true
    validates_length_of :address1, :maximum => 255, :allow_nil => true
    validates_length_of :address2, :maximum => 255, :allow_nil => true
    validates_length_of :city, :maximum => 40, :allow_nil => true
    validates_length_of :state, :maximum => 40, :allow_nil => true
    validates_length_of :postal_code, :maximum => 20, :allow_nil => true
    validates_length_of :country, :maximum => 32, :allow_nil => true
    validates_length_of :fax, :maximum => 40, :allow_nil => true
    validates_length_of :home_phone, :maximum => 40, :allow_nil => true
    validates_length_of :work_phone, :maximum => 40, :allow_nil => true
    validates_length_of :mobile_phone, :maximum => 40, :allow_nil => true
    validates_length_of :other_phone, :maximum => 40, :allow_nil => true
    validates_inclusion_of :other_phone_type, :in => ['Work','Mobile','Home','Other'], :if => :other_phone
    validates_length_of :personal_email, :maximum => 80, :allow_nil => true
    validates_length_of :work_email, :maximum => 80, :allow_nil => true

    define_attributes do
      read_only :created_by_id, :created_date, :updated_by_id, :updated_date
    end
  end
end


