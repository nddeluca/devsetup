UV ?= uv
UV_RUN ?= $(UV) run

PYTEST ?= $(UV_RUN) pytest
PYTEST_FLAGS ?= --color=yes

MISE ?= mise
MISE_EXEC ?= $(MISE) exec --

DEBIAN_TEST_IMAGE ?= debian-tester
DEBIAN_TEST_DOCKERFILE ?= Dockerfile.$(DEBIAN_TEST_IMAGE)

DOCKER ?= docker
DOCKER_BUILD ?= $(DOCKER) buildx build
DOCKER_BUILD_EXTRA_ARGS ?= --load

DOCKER_RUN ?= $(DOCKER) run

.PHONY: install-deps
install-deps:
	$(UV) sync --frozen
	$(MISE) trust mise.toml
	$(MISE) install
	$(UV_RUN) ansible-galaxy install -r requirements.yml

.PHONY: test-local
test-local:
	$(PYTEST) $(PYTEST_FLAGS)

.PHONY: test-docker
test-docker:
	$(DOCKER_BUILD) $(DOCKER_BUILD_EXTRA_ARGS) \
		-t $(DEBIAN_TEST_IMAGE) \
		-f $(DEBIAN_TEST_DOCKERFILE) .

	$(DOCKER_RUN) --rm \
		$(DEBIAN_TEST_IMAGE) \
		bash -lc 'cd devsetup && make test-local'

.PHONY: test
test: test-docker

.PHONY: fmt
fmt:
	$(UV_RUN) ruff format .

.PHONY: lint-python
lint-python:
	$(UV_RUN) ruff check .

.PHONY: lint-ansible
lint-ansible:
	$(UV_RUN) ansible-lint

.PHONY: lint
lint: lint-python lint-ansible

.PHONY: check
check: fmt lint test
