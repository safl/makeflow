PROJECT_NAME=makeflow
PROJECT_VERSION=$(shell cd src; python3 -c "import makeflow;print(makeflow.__version__)")

# Everything below this line is reusable without modification.
#
# Simply update the  project name above, and everything below will automatically
# adjust to it. Of course, you can modify, add, or delete any targets as needed,
# but the key point is that you don't have to.
#
# NOTE: the MAKEFLOW_USAGE below should not be renamed, it is an actual script
# which you should copy to your projects root as it provides the ability of
# docstrings for the targets in this Makefile

# It is assumed that pipx is available, installed using your preferred method
# - typically through your system's package manager or any other approach you
# prefer.
PIPX=pipx -q

# The build-tool, pre-commit and twine are executed via "pipx"
BUILD=pipx run -q --python python3 build
PCF=pipx run -q --python python3 pre-commit
TWINE=pipx run -q --python python3 twine

# Pytest and Sphinx are "special" and are not invoked using 'pipx run'. 
# They require access to the installed packages and modules in the project's 
# virtual environment. Without this access, Pytest cannot import and run the 
# project, and Sphinx cannot generate API documentation or perform other 
# tasks that depend on accessing project files.
COVERAGE="$(shell pipx environment --value PIPX_LOCAL_VENVS)/${PROJECT_NAME}/bin/coverage"
PYTEST="$(shell pipx environment --value PIPX_LOCAL_VENVS)/${PROJECT_NAME}/bin/pytest"
SPHINXBUILD="$(shell pipx environment --value PIPX_LOCAL_VENVS)/${PROJECT_NAME}/bin/sphinx-build"

MAKEFLOW_USAGE="./.makeflow/usage.py"
MAKEFLOW_VERSION_BUMP="./.makeflow/version_bump.py"

BUILD_DIR=dist
BUILD_TARGET_PKG_TGZ=$(BUILD_DIR)/$(PROJECT_NAME)-$(PROJECT_VERSION).tar.gz

define help-help
# Print the description of every target in the Makefile
endef
.PHONY: help
help:
	@$(MAKEFLOW_USAGE) --repos . --colorize

define help-verbose-help
# Print the verbose description of target in the Makefile
endef
.PHONY: help-verbose
help-verbose:
	@$(MAKEFLOW_USAGE) --repos . --colorize --verbose

define common-help
# Execute the common development flow (clean/build/install/test/docs)
endef
.PHONY: common
common: clean install test docs-build
	@echo "## ${PROJECT_NAME}: common [DONE]"

define bump-help
# Bump the project version number
endef
.PHONY: bump
bump:
	@$(MAKEFLOW_VERSION_BUMP)
	@echo "## ${PROJECT_NAME}: bump [DONE]"

define docs-build-help
# Build documentation in HTML format
endef
.PHONY: docs-build
docs-build:
	cd docs; make clean html SPHINXBUILD=${SPHINXBUILD}
	@echo "## ${PROJECT_NAME}: docs-build [DONE]"

define docs-open-help
# Open the Documentation
endef
.PHONY: docs-open
docs-open:
	xdg-open docs/build/html/index.html || open docs/build/html/index.html || true
	@echo "## ${PROJECT_NAME}: docs-open [DONE]"

define docs-help
# Geneate documentation and open it
endef
.PHONY: docs
docs: docs-build docs-open
	@echo "## ${PROJECT_NAME}: docs [DONE]"

define info-help
# Print tooling information
endef
.PHONY: info
info:
	@echo "PROJECT_NAME(${PROJECT_NAME})"
	@echo "PROJECT_VERSION(${PROJECT_VERSION})"
	@echo "PATH(${PATH})"
	${PIPX} environment || true
	${PIPX} --version || true
	${BUILD} --version || true
	${PCF} --version || true
	${PYTEST} --version || true
	${TWINE} --version || true
	${COVERAGE} --version || true
	@echo "## ${PROJECT_NAME}: info [DONE]"

define info-bin-help
# Print paths for tool; see 'make help-verbose' for details and examples
#
# This taps into the Python venv which is set up by pipx, via this, then the
# tool locations can conveniently be exported to be used outside the Makefile.
#
# You can extend PATH with the location provided by:
#
#  make info-bin
#
# Or you can get individual tool paths with:
#
#  COVERAGE_BIN=$(make info-bin NAME=COVERAGE)
#  $(COVERAGE_BIN) report ...
#
# Do note that some of the tools are executed via "pipx run", while others are
# executed via their venv path as above
#
# This should avoid duplicating or having to re-voodoo / resolve these paths
endef
.PHONY: info-bin
info-bin:
ifeq ($(strip $(NAME)),)
	@echo $(shell pipx environment --value PIPX_LOCAL_VENVS)/${PROJECT_NAME}/bin
else
	@echo $($(NAME))
endif

define format-help
# Run code format and linting via the pre-commit framework
endef
.PHONY: format
format:
	${PCF} run --all
	@echo "## ${PROJECT_NAME}: format [DONE]"

define clean-help
# Remove the build artifacts
endef
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) *.egg-info
	@echo "## ${PROJECT_NAME}: clean [DONE]"

$(BUILD_TARGET_PKG_TGZ): $(shell find src/ -type f) pyproject.toml
	${BUILD}
	@echo "## ${PROJECT_NAME}: pkg_tgz [DONE]"

define build-help
# Build the project (see pyproject.toml for build-system)
#
# This uses the awesome Makefile logic, checking for changes on the
# pyproject.toml, and any changes in the src/ folder
endef
.PHONY: build
build: $(BUILD_TARGET_PKG_TGZ)

define _inject-packages-help
# Inject Python packages for development and testing into pipx-provided venv
endef
.PHONY: _inject-packages
_inject-packages:
	@cat requirements.dev.txt | xargs -I{} ${PIPX} inject ${PROJECT_NAME} {} --force
	${PIPX} inject ${PROJECT_NAME} coverage --force --include-deps --include-apps
	@echo "## ${PROJECT_NAME}: _inject-packages [DONE]"

define _install-using-package-help
# pipx install the package
#
# This is the installation method to use for testing, since this is how end-user
# will be installing it.
endef
.PHONY: _install-using-package
_install-using-package:
	@${PIPX} install dist/*.tar.gz --force
	@echo "## ${PROJECT_NAME}: _install-using-package [DONE]"

define _install-using-source-help
# pipx install using source in editable mode
#
# This is the installation method to use for development, since you do not have
# to go through re-installation of the project while making changes, which is
# very convenient. since this is how end-user will be installing it.
endef
.PHONY: _install-using-source
_install-using-source:
	@${PIPX} install . --force --editable
	@echo "## ${PROJECT_NAME}: _install-using-source [DONE]"

define install-help
# install for development (using source and --editable) and inject packages
endef
.PHONY: install
install: _install-using-source _inject-packages
	@echo "## ${PROJECT_NAME}: install [DONE]"

define install-for-testing-help
# install for testing (using package) with packages injected
endef
.PHONY: install-for-testing
install-for-testing: _install-using-package _inject-packages
	@echo "## ${PROJECT_NAME}: install [DONE]"

define test-help
# Run pytest using 'tests/'
endef
.PHONY: test
test:
	${PYTEST} --cov --cov-branch tests -s -v
	@echo "## ${PROJECT_NAME}: test [DONE]"

define release-help
# Upload the project package to PyPI
#
# Assuming a .tar.gz and wheel is available in "dist/". The intent here is that
# this very same package is the exact same which have been installed and user
# for testing.
#
# Which is also why this target does not do a build and release in one go, it is
# expected that it would need to go through multiple stages of testing in some
# CI/CD system such as GitHUB Actions.
endef
.PHONY: release
release:
	@echo -n "# rel: "; date
	@${TWINE} upload dist/*
	@echo "## ${PROJECT_NAME}: make release"