module Spree
  class ProductsController < BaseController
    before_filter :load_product, :only => :show
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/taxons'

    respond_to :html

    def index
      @searcher = Config.searcher_class.new(params)
      @products = @searcher.retrieve_products
      respond_with(@products)
    end

    def show
      return unless @product

      @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
      @product_properties = ProductProperty.includes(:property).where(:product_id => @product.id)

      referer = request.env['HTTP_REFERER']
      if referer
        referer_path = URI.parse(request.env['HTTP_REFERER']).path
        if referer_path && referer_path.match(/\/t\/(.*)/)
          @taxon = Taxon.find_by_permalink($1)
        end
      end

      respond_with(@product)
    end

    private
      def accurate_title
        @product ? @product.name : super
      end

      def load_product
        @product = Product.active.find_by_permalink!(params[:id])
      end
  end
end
