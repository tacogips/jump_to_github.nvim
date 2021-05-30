
init-project:
	curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore
	python3 -m venv venv

init-venv:
	python3 -m venv venv

install-common-tools:
	source venv/bin/activate && pip install flake8 black pep8-naming pytest
	source venv/bin/activate && pip freeze > requirements.txt

save-dep:
	source venv/bin/activate && pip freeze > requirements.txt

install-dep:
	source venv/bin/activate && pip install -r requirements.txt

test-all:
	source venv/bin/activate && pytest
