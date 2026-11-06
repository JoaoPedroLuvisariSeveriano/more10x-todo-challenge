# More10x - Task Manager Challenge

Gerenciador de tarefas (To-Do List) full stack desenvolvido para o **desafio técnico da More10x**: API REST em **Ruby on Rails 7** e interface em **Vue 3**, organizados em monorepo e prontos para subir com **um único comando**.

## Destaques

- **CRUD completo** de Categorias e Tarefas.
- **Filtros combinados** (categoria + status + prioridade) integrados aos *query params* da API, com botão de limpar filtros.
- **Contadores de status** que funcionam como atalhos de navegação (ignoram o filtro de status ativo para mostrar o panorama real).
- **Sem N+1:** `includes(:category)` na listagem de tarefas, com teste automatizado garantindo uma única consulta de categorias.
- **Ambiente "Zero Atrito":** o container cria, migra e popula o banco automaticamente.
- **Testes automatizados** (Minitest) para models e endpoints.

## Arquitetura e Stack

```text
more10x-todo-challenge/
├── backend/             # API Rails 7.2 (API-only) + PostgreSQL
├── frontend/            # SPA Vue 3 (Composition API) + Vite + TailwindCSS
└── docker-compose.yml   # PostgreSQL + backend + frontend
```

| Camada | Tecnologias |
| --- | --- |
| Backend | Ruby 3.3, Ruby on Rails 7.2 (API-only), PostgreSQL 16, `rack-cors`, Minitest |
| Frontend | Vue 3 (`<script setup>`), Vite, TailwindCSS 3, Axios |
| Infra | Docker e Docker Compose |

**Modelo de dados**

- `Category`: `name` (obrigatório, único sem diferenciar maiúsculas/minúsculas) — `has_many :tasks, dependent: :destroy`.
- `Task`: `title` (obrigatório), `description`, `status` (`pending`, `in_progress`, `completed`), `priority` (`low`, `medium`, `high`), `due_date` e `category_id` (chave estrangeira).

**Decisões de projeto**

- Rotas versionadas em `/api/v1`.
- Filtros implementados como *scopes* encadeáveis no model (`by_category`, `by_status`, `by_priority`); filtros vazios são ignorados.
- Erros padronizados: `422` com os erros do model, `404` com JSON amigável e `400` para parâmetros ausentes.
- Valores inválidos de enum geram erro de validação (`422`), não exceção.

## Como Rodar com Docker

Pré-requisito: [Docker](https://docs.docker.com/get-docker/) com Docker Compose.

```bash
git clone https://github.com/JoaoPedroLuvisariSeveriano/more10x-todo-challenge.git
cd more10x-todo-challenge
docker compose up --build
```

Pronto. O `bin/docker-entrypoint` do backend executa `db:prepare` automaticamente: **cria o banco, roda as migrations e popula os dados de exemplo (seeds)** na primeira execução. Nenhum comando manual é necessário.

| Serviço | URL |
| --- | --- |
| Frontend | http://localhost:5173 |
| API | http://localhost:3000/api/v1 |
| Healthcheck | http://localhost:3000/up |

As *seeds* criam 3 categorias (Trabalho, Casa, Faculdade) e 9 tarefas com status, prioridades e vencimentos variados, para testar os filtros logo de início.

Para recomeçar do zero (apaga o banco): `docker compose down -v`.

## Como Rodar Localmente (Sem Docker)

Pré-requisitos: Ruby 3.3, PostgreSQL em execução e Node.js 20+.

**Backend**

```bash
cd backend
bundle install
# Opcional: ajuste se o seu PostgreSQL usa outras credenciais (padrão: postgres/postgres em localhost:5432)
export DB_HOST=localhost DB_USERNAME=postgres DB_PASSWORD=postgres
bin/rails db:prepare     # cria, migra e popula o banco
bin/rails server         # http://localhost:3000
```

**Frontend** (em outro terminal)

```bash
cd frontend
npm install
npm run dev              # http://localhost:5173
```

Por padrão o frontend usa `http://localhost:3000/api/v1`. Para alterar, defina `VITE_API_URL` (veja `frontend/.env.example`). Para liberar outra origem no CORS do backend, use `CORS_ORIGINS` (lista separada por vírgulas).

## Como Rodar os Testes

Com Docker (banco já disponível no Compose):

```bash
docker compose run --rm backend bin/rails db:test:prepare
docker compose run --rm backend bin/rails test
```

Sem Docker:

```bash
cd backend
bin/rails db:test:prepare
bin/rails test
```

A suíte cobre validações e scopes dos models, enums, os endpoints de categorias e tarefas, as respostas de erro (404/422/400), a combinação de filtros e a ausência de N+1.

## API REST

Base URL: `http://localhost:3000/api/v1`

| Método | Rota | Descrição |
| --- | --- | --- |
| GET | `/categories` | Lista as categorias (ordem alfabética) |
| GET | `/categories/:id` | Detalha uma categoria |
| POST | `/categories` | Cria uma categoria |
| PUT/PATCH | `/categories/:id` | Atualiza uma categoria |
| DELETE | `/categories/:id` | Remove a categoria e suas tarefas |
| GET | `/tasks` | Lista tarefas, com filtros opcionais |
| GET | `/tasks/:id` | Detalha uma tarefa |
| POST | `/tasks` | Cria uma tarefa |
| PUT/PATCH | `/tasks/:id` | Atualiza uma tarefa |
| DELETE | `/tasks/:id` | Remove uma tarefa |

**Filtros de `GET /tasks`** (combináveis): `category_id`, `status` (`pending` \| `in_progress` \| `completed`) e `priority` (`low` \| `medium` \| `high`).

```bash
curl "http://localhost:3000/api/v1/tasks?category_id=1&status=pending&priority=high"
```

**Exemplo de corpo (`POST /tasks`)**

```json
{
  "task": {
    "title": "Entregar relatório",
    "description": "Versão final para o time",
    "status": "pending",
    "priority": "high",
    "due_date": "2026-12-01",
    "category_id": 1
  }
}
```

**Exemplo de resposta** (a categoria vem aninhada)

```json
{
  "id": 1,
  "title": "Entregar relatório",
  "description": "Versão final para o time",
  "status": "pending",
  "priority": "high",
  "due_date": "2026-12-01",
  "category_id": 1,
  "category": { "id": 1, "name": "Trabalho" }
}
```

**Erros**

| Status | Quando | Exemplo |
| --- | --- | --- |
| 404 | Recurso inexistente | `{ "error": "Task not found" }` |
| 422 | Falha de validação | `{ "errors": { "title": ["can't be blank"] } }` |
| 400 | Parâmetro raiz ausente | `{ "error": "param is missing or the value is empty: task" }` |

## Fluxo de Trabalho (Git)

O projeto foi construído com **Git Flow** e **Conventional Commits**: cada etapa em sua própria branch (`chore/`, `feat/`, `docs/`), mesclada na `develop` com `--no-ff`, e a `develop` mesclada na `main` na release.