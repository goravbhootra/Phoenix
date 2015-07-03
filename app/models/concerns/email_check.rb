class EmailCheck
  def self.validate(email)
      (email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i).present?
  end
end