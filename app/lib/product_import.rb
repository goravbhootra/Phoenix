class ProductImport < ActiveImporter::Base
  imports Product

  product_group_master = ProductGroup.pluck(:name, :id).to_h
  category_master = Category.pluck(:name, :id).to_h
  core_level_master = CoreLevel.pluck(:name, :id).to_h
  author_master = Author.pluck(:name, :id).to_h
  distribution_type_master = DistributionType.pluck(:name, :id).to_h
  language_master = Language.pluck(:name, :id).to_h
  focus_group_master = FocusGroup.pluck(:name, :id).to_h

  column 'Sku', :sku do |sku|
    sku.to_i.to_s
  end
  column 'product_group', :product_group_id do |product_group_name|
    product_group_master[product_group_name]
  end
  column 'category', :category_id do |category_name|
    category_master[category_name]
  end
  column 'core_level', :core_level_id do |core_level_name|
    core_level_master[core_level_name]
  end
  column 'author', :author_id do |author_name|
    author_master[author_name]
  end
  column 'distribution_type', :distribution_type_id do |distribution_type_name|
    distribution_type_master[distribution_type_name]
  end
  column 'language', :language_id do |language_name|
    language_master[language_name]
  end
  column 'uom', :uom_id
  column 'focus_group', :focus_group_id do |focus_group_name|
    focus_group_master[focus_group_name]
  end
  column 'name', :name
  column 'alias_name', :alias_name
  column 'publication_date', :publication_date
  column 'mrp', :mrp
  column 'selling_price', :selling_price
  column 'isbn', :isbn
end
