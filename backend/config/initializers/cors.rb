# Be sure to restart your server when you modify this file.
# Handle Cross-Origin Resource Sharing (CORS) so the Vue frontend can call the API.
# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173").split(",").map(&:strip)

    resource "*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: %w[Link X-Total-Count]
  end
end
