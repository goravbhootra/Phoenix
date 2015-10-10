class ProductsController < ApplicationController
  power :products
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.includes(:product_group, :category, :core_level, :author, :distribution_type, :language).all
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, flash: { success: 'Product was successfully created.' }}
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, flash: { success: 'Product was successfully updated.' }}
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, flash: { success: 'Product was successfully destroyed.' }}
      format.json { head :no_content }
    end
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:sku, :name, :alias_name, :selling_price, :active, :product_group_id, :category_id, :core_level_id, :author_id, :distribution_type_id, :language_id, :uom_id, :focus_group_id, :summary, :synopsis, :publication_date, :mrp, :isbn, :notes, :details)
    end
end
