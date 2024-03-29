.PHONY: all install-dev test docs clean-pyc

all: test

install-dev:
	pip install -q -e .[dev]

test: clean-pyc install-dev
	pytest

docs: clean-pyc install-dev
	$(MAKE) -C docs html

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
