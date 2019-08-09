# Configuration file for the Sphinx documentation builder.

import os
import sys

project = "stobot"
copyright = "2019, vinicio"
author = "vinicio"
version = "0.0.1"
release = "0.0.1"

sys.path.insert(0, os.path.abspath("../.."))

extensions = [
    "sphinxcontrib.restbuilder",
    "sphinxcontrib.globalsubs",
    "sphinx-prompt",
    "sphinx_substitution_extensions"
]

templates_path = ["_templates"]

exclude_patterns = []

html_static_path = ["_static"]

html_theme = "sphinx_rtd_theme"

master_doc = "index"

images_base = "https://github.com"

images_url = images_base + "/cryptoinvestment11/stobot/master/resources/img/"

global_substitutions = {
    "AUTHOR_IMAGE": ".. image:: " + images_url +
    "/author.png\n   :alt: author",
    "AUTHOR_IMAGE_2": ".. image:: " + images_url +
    "/author_2.png\n   :alt: author_2",
    "GITHUB_REPO_LINK":  "`Github repository <https://github.com/" + author +
    "/" + project + ">`_.",
    "READTHEDOCS_IMAGE": ".. image:: https://readthedocs.org/projects/"
    + project + "/badge\n   :alt: readthedocs",
    "READTHEDOCS_LINK": "`readthedocs <https://" + project +
    ".readthedocs.io/en/latest/>`_.",
    "TRAVIS_CI_IMAGE":  ".. image:: https://api.travis-ci.org/" + author +
    "/" + project + ".svg\n   :alt: travis",
    "TRAVIS_CI_LINK":  "`Travis CI building <https://travis-ci.org/" + author +
    "/" + project + ">`_.",
}

substitutions = [
    ("|AUTHOR|", author),
    ("|PROJECT|", project)
]
