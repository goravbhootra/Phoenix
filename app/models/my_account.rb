class MyAccount < ActiveType::Object
  def initialize(attributes={})
    @current_user = attributes[:current_user]
  end
end
