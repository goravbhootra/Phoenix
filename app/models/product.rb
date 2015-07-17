class Product < ActiveRecord::Base
  belongs_to :product_group, inverse_of: :products
  belongs_to :category, inverse_of: :products
  belongs_to :core_level, inverse_of: :products
  belongs_to :author, inverse_of: :products
  belongs_to :distribution_type, inverse_of: :products
  belongs_to :language, inverse_of: :products
  belongs_to :publisher, inverse_of: :products
  belongs_to :uom, inverse_of: :products
  belongs_to :focus_group, inverse_of: :products
  has_many :inventory_txn_line_items, inverse_of: :product, dependent: :restrict_with_exception
  has_many :invoice_line_items, inverse_of: :product, dependent: :restrict_with_exception
  has_many :invoice_line_items, inverse_of: :product, dependent: :restrict_with_exception
  has_many :order_line_items, class_name: 'Order::LineItem', inverse_of: :product, dependent: :restrict_with_exception
  # has_many :inventory_voucher_line_items, class_name: 'InventoryVoucherLineItem', inverse_of: :product, dependent: :restrict_with_exception
  has_many :business_entity_location_inventory_levels, inverse_of: :product, dependent: :restrict_with_exception

  validates :category, presence: true
  validates :distribution_type, presence: true
  validates :publisher, presence: true
  validates :uom, presence: true
  validates :sku, presence: true, length: { in: 1..7 }, uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { in: 3..100 }, uniqueness: { scope: [:category, :language, :selling_price], case_sensitive: false}
  validates :alias_name, presence: true, length: { in: 3..40 }, uniqueness: { scope: [:category, :language, :selling_price], case_sensitive: false}
  validates :mrp, :selling_price, numericality: { less_than_or_equal_to: 999999 }
  validates :active, inclusion: { in: [true, false] }

  before_validation :strip_fields

  scope :active, -> { where active: true }

  delegate :code, to: :language, prefix: true, allow_nil: true
  delegate :code, to: :category, prefix: true, allow_nil: true

  def voucher_label
    "#{name} : #{alias_name} : #{language_code} : #{category_code} : #{selling_price}"
  end

  def self.product_details_by_ids(product_ids)
    result = {}
    includes(:category, :language).where(id: product_ids).find_each do |product|
      result[product.id] = { sku: product.sku, name: product.name, category_code: product.category_code, language_code: product.language_code }
    end
    result
  end

  def print_name
    alias_name
  end

  def voucher_print_name
    language_code.present? ? "#{alias_name}:#{language_code}" : alias_name
  end

  def strip_fields
    name = self.name.strip if self.name.present?
    alias_name = self.alias_name.strip if self.alias_name.present?
  end

  def sku_name
    "#{sku} : #{voucher_label}"
  end

  def self.active_and_current_collection(current_element)
    result = Product.includes([:category, :language]).order(:sku).inject({}) {|hash,x| hash[x.id]=x.sku_name; hash}
    # result = active.pluck(:id, :name).to_h
    unless result.keys.include? (current_element)
      current_record = find(current_element)
      result[current_record.id] = current_record.sku_name
    end
    result
  end

  def self.sort_skus_by_parentcat_lang(skus)
    products = Product.includes(:language).where(sku: skus).pluck(:sku, :name, :category_id, :language_id)
    parent_cat = Hash.new
    Category.where(id: products.map {|row| row[2]}.uniq.compact).each { |cat| parent_cat[cat.id] = cat.root_node_name }
    lang_codes = Language.where(id: products.map {|row| row[3]}.uniq.compact).pluck(:id, :name).to_h
    result = Hash.new
    products.each { |p| result[p[0]] = [p[1], parent_cat[p[2]], lang_codes[p[3]].to_s] }
    result
    # products = products.sort_by { |p| [p[3], p[3]] }
  end
end
