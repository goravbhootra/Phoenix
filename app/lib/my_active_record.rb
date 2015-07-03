class MyActiveRecord < ActiveRecord::Base
  self.abstract_class = true

  def custom_default_object_label_method
    self.new_record? ? "new #{self.class}" : "#{self.class} ##{self.id}"
  end

  def custom_object_label_method
    [:display_name, :name, :title].detect { |label| self.send(label) if self.class.new.respond_to? label }
  end

  def custom_object_label
    return self.send(custom_object_label_method) if custom_object_label_method.present?
    self.custom_default_object_label_method
  end
end
