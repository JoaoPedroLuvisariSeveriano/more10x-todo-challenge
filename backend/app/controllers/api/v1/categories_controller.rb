module Api
  module V1
    class CategoriesController < ApplicationController
      before_action :set_category, only: %i[show update destroy]

      def index
        render json: Category.order(:name)
      end

      def show
        render json: @category
      end

      def create
        category = Category.new(category_params)

        if category.save
          render json: category, status: :created
        else
          render_unprocessable(category)
        end
      end

      def update
        if @category.update(category_params)
          render json: @category
        else
          render_unprocessable(@category)
        end
      end

      def destroy
        @category.destroy
        head :no_content
      end

      private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name)
      end
    end
  end
end

