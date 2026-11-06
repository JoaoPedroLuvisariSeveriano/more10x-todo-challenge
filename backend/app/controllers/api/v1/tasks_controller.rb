module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: %i[show update destroy]

      # GET /api/v1/tasks?category_id=1&status=pending&priority=high
      def index
        tasks = Task.includes(:category)
                    .by_category(params[:category_id])
                    .by_status(params[:status])
                    .by_priority(params[:priority])
                    .order(created_at: :desc)

        render json: tasks.map { |task| task_json(task) }
      end

      def show
        render json: task_json(@task)
      end

      def create
        task = Task.new(task_params)

        if task.save
          render json: task_json(task), status: :created
        else
          render_unprocessable(task)
        end
      end

      def update
        if @task.update(task_params)
          render json: task_json(@task)
        else
          render_unprocessable(@task)
        end
      end

      def destroy
        @task.destroy
        head :no_content
      end

      private

      def set_task
        @task = Task.includes(:category).find(params[:id])
      end

      def task_params
        params.require(:task).permit(:title, :description, :status, :priority, :due_date, :category_id)
      end

      def task_json(task)
        task.as_json(include: { category: { only: %i[id name] } })
      end
    end
  end
end
