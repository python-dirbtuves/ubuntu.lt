from setuptools import setup, find_packages
setup(
    name='ubuntu-lt',
    version='0.1.dev1',  # https://www.python.org/dev/peps/pep-0440/
    packages=find_packages(),
    install_requires=[
        'misago==0.5.5a1',
        'psycopg2',
    ],
)
