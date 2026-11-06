# Idempotent seeds: safe to run multiple times (db:prepare / db:seed).
today = Date.current

categories = %w[Trabalho Casa Faculdade].index_with do |name|
  Category.find_or_create_by!(name: name)
end

tasks = [
  { title: "Preparar apresentação do sprint", description: "Slides com métricas e demo das entregas.", status: :in_progress, priority: :high, due_date: today + 2, category: "Trabalho" },
  { title: "Responder e-mails pendentes", description: "Limpar a caixa de entrada.", status: :pending, priority: :low, due_date: today + 1, category: "Trabalho" },
  { title: "Revisar pull requests do time", description: "Revisar os PRs abertos no repositório.", status: :completed, priority: :medium, due_date: today - 1, category: "Trabalho" },
  { title: "Pagar conta de luz", description: "Vencimento no fim da semana.", status: :pending, priority: :high, due_date: today + 3, category: "Casa" },
  { title: "Fazer compras do mês", description: "Lista no app de notas.", status: :completed, priority: :medium, due_date: today - 3, category: "Casa" },
  { title: "Consertar torneira da cozinha", description: nil, status: :in_progress, priority: :low, due_date: today + 7, category: "Casa" },
  { title: "Entregar trabalho de Banco de Dados", description: "Modelagem relacional e consultas SQL.", status: :pending, priority: :high, due_date: today + 5, category: "Faculdade" },
  { title: "Estudar para a prova de Algoritmos", description: "Grafos e programação dinâmica.", status: :in_progress, priority: :medium, due_date: today + 10, category: "Faculdade" },
  { title: "Ler artigo sobre arquitetura de software", description: nil, status: :pending, priority: :low, due_date: nil, category: "Faculdade" }
]

tasks.each do |attrs|
  category = categories.fetch(attrs[:category])
  Task.find_or_create_by!(title: attrs[:title], category: category) do |task|
    task.assign_attributes(attrs.except(:category, :title))
  end
end

puts "Seeded #{Category.count} categories and #{Task.count} tasks."
