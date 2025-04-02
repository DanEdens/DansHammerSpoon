# MCP Server Tools Makefile
# This file provides examples and shortcuts for interacting with the MCP todo server

# Default variables
SERVER_URL ?= http://localhost:8000
TODO_ID ?= replace_with_todo_id
LESSON_ID ?= replace_with_lesson_id
QUERY ?= example_query
DESCRIPTION ?= "Example task description"
PRIORITY ?= medium
TARGET_AGENT ?= user
LANGUAGE ?= en
TOPIC ?= "Example Topic"
LESSON_LEARNED ?= "Example lesson content"
STATUS ?= pending

.PHONY: help list-todos query-todos search-todos add-todo update-todo delete-todo mark-todo-complete \
        list-lessons add-lesson update-lesson delete-lesson search-lessons get-todo get-lesson

help:
	@echo "MCP Server Tools Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make <target> [VARIABLE=value]"
	@echo ""
	@echo "Targets:"
	@echo "  help                    Show this help message"
	@echo "  list-todos              List todos by status (STATUS=pending)"
	@echo "  query-todos             Query all todos"
	@echo "  search-todos            Search todos with text query (QUERY=search_term)"
	@echo "  add-todo                Add a new todo (DESCRIPTION=\"Task description\" PRIORITY=medium)"
	@echo "  update-todo             Update an existing todo (TODO_ID=id DESCRIPTION=\"New description\")"
	@echo "  delete-todo             Delete a todo (TODO_ID=id)"
	@echo "  mark-todo-complete      Mark a todo as complete (TODO_ID=id)"
	@echo "  get-todo                Get a specific todo by ID (TODO_ID=id)"
	@echo "  list-lessons            List all lessons"
	@echo "  add-lesson              Add a new lesson (TOPIC=\"Topic\" LESSON_LEARNED=\"Content\")"
	@echo "  update-lesson           Update an existing lesson (LESSON_ID=id)"
	@echo "  delete-lesson           Delete a lesson (LESSON_ID=id)"
	@echo "  search-lessons          Search lessons with text query (QUERY=search_term)"
	@echo "  get-lesson              Get a specific lesson by ID (LESSON_ID=id)"
	@echo ""
	@echo "Example:"
	@echo "  make add-todo DESCRIPTION=\"Implement feature X\" PRIORITY=high"

# Todo related commands
list-todos:
	@echo "Listing todos with status: $(STATUS)"
	curl -s -X GET "$(SERVER_URL)/todos/status/$(STATUS)?limit=100" | jq

query-todos:
	@echo "Querying all todos"
	curl -s -X GET "$(SERVER_URL)/todos?limit=100" | jq

search-todos:
	@echo "Searching todos for: $(QUERY)"
	curl -s -X GET "$(SERVER_URL)/todos/search?query=$(QUERY)" | jq

add-todo:
	@echo "Adding new todo: $(DESCRIPTION)"
	curl -s -X POST "$(SERVER_URL)/todos" \
		-H "Content-Type: application/json" \
		-d "{\"description\": $(DESCRIPTION), \"priority\": \"$(PRIORITY)\", \"target_agent\": \"$(TARGET_AGENT)\"}" | jq

update-todo:
	@echo "Updating todo: $(TODO_ID)"
	curl -s -X PUT "$(SERVER_URL)/todos/$(TODO_ID)" \
		-H "Content-Type: application/json" \
		-d "{\"description\": $(DESCRIPTION), \"priority\": \"$(PRIORITY)\"}" | jq

delete-todo:
	@echo "Deleting todo: $(TODO_ID)"
	curl -s -X DELETE "$(SERVER_URL)/todos/$(TODO_ID)" | jq

mark-todo-complete:
	@echo "Marking todo as complete: $(TODO_ID)"
	curl -s -X PUT "$(SERVER_URL)/todos/$(TODO_ID)/complete" | jq

get-todo:
	@echo "Getting todo: $(TODO_ID)"
	curl -s -X GET "$(SERVER_URL)/todos/$(TODO_ID)" | jq

# Lesson related commands
list-lessons:
	@echo "Listing lessons"
	curl -s -X GET "$(SERVER_URL)/lessons?limit=100" | jq

add-lesson:
	@echo "Adding new lesson: $(TOPIC)"
	curl -s -X POST "$(SERVER_URL)/lessons" \
		-H "Content-Type: application/json" \
		-d "{\"language\": \"$(LANGUAGE)\", \"topic\": $(TOPIC), \"lesson_learned\": $(LESSON_LEARNED)}" | jq

update-lesson:
	@echo "Updating lesson: $(LESSON_ID)"
	curl -s -X PUT "$(SERVER_URL)/lessons/$(LESSON_ID)" \
		-H "Content-Type: application/json" \
		-d "{\"topic\": $(TOPIC), \"lesson_learned\": $(LESSON_LEARNED)}" | jq

delete-lesson:
	@echo "Deleting lesson: $(LESSON_ID)"
	curl -s -X DELETE "$(SERVER_URL)/lessons/$(LESSON_ID)" | jq

search-lessons:
	@echo "Searching lessons for: $(QUERY)"
	curl -s -X GET "$(SERVER_URL)/lessons/search?query=$(QUERY)" | jq

get-lesson:
	@echo "Getting lesson: $(LESSON_ID)"
	curl -s -X GET "$(SERVER_URL)/lessons/$(LESSON_ID)" | jq 
