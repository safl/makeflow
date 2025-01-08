==========================================
 makeflow: Makefile workflow (for Python)
==========================================

This is a project template / skeleton / example of a command-line driven
workflow for Python development. Here is what it does:

* Documentation

  - Sphinx with PyDATA Theme
  - Example text-output from commands are automatically populated using ``kmdo``
  - Is built and published on GHPages
  - Triggered on version-tags e.g. (v0.0.1)

* Format and Linting

  - ruff for code style in a mode like black / isort / flake
  - mypy for type-checking

* Testing and Test coverage Reporting

  - Uses pytest
  - Coverage is combined from multiple sources (Python Version x Platform)
  - Is automated in GHA
  - Available as artifact download
  - Published on `coveralls.io`_
  - Triggers on PR and version-tags e.g. (v0.0.1)

* Package Upload to PyPI

  - Is built, tested, and then published to PyPI
  - Triggers on version-tags e.g. (v0.0.1)

GitHUB Secrets
==============

These repository secrets must be configured for your projects repository on
GitHUB:

* PYPI_USERNAME
* PYPI_PASSWORD

.. _coveralls.io: https://coveralls.io/