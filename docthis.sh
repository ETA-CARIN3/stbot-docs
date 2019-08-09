#!/bin/bash
#
# @file docthis
# @brief Generate documentation using sphinx.

# Default values.
# URL to an images repository for replacements, when this variable is empty
# the URL https://raw.githubusercontent.com/username/images/master/project/
# is used.
IMAGES_URL=''

# Wheter to apply stardard or developer configuration, default is standard.
DOCTHIS_DEVEL=false

# Path to the project for which to generate documentation, if not
# especified, the current path will be used.
PROJECT_PATH=$(pwd)

# requirements.txt file contents.
REQUIREMENTS_PIP='sphinxcontrib-restbuilder
sphinxcontrib-globalsubs
sphinx-prompt
Sphinx-Substitution-Extensions
sphinx_rtd_theme'

# conf.py file contents.
CONFIGURATION_CONTENTS='# Configuration file for the Sphinx documentation builder.

import os
import sys

project = "|PROJECT_GENERATED_NAME|"
copyright = "|YEAR_GENERATED_VALUE|, |AUTHOR_GENERATED_NAME|"
author = "|AUTHOR_GENERATED_NAME|"
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

images_url = "|IMAGES_URL_GENERATED_VALUE|"

global_substitutions = {
    "AUTHOR_IMAGE": ".. image:: " + images_url + "/author.png\\n   :alt: author",
    "AUTHOR_SLOGAN": "The travelling vaudeville villain.",
    "GITHUB_REPO_LINK":  "`Github repository <https://github.com/" + author + "/" + project + ">`_.",
    "INGREDIENTS_IMAGE": ".. image:: " + images_url + "/ingredients.png\\n   :alt: ingredients",
    "READTHEDOCS_IMAGE": ".. image:: https://readthedocs.org/projects/" + project + "/badge\\n   :alt: readthedocs",
    "READTHEDOCS_LINK": "`readthedocs <https://" + project + ".readthedocs.io/en/latest/>`_.",
    "TRAVIS_CI_IMAGE":  ".. image:: https://api.travis-ci.org/" + author + "/" + project + ".svg\\n   :alt: travis",
    "TRAVIS_CI_LINK":  "`Travis CI building <https://travis-ci.org/" + author + "/" + project + ">`_.",
}

substitutions = [
    ("|AUTHOR|", author),
    ("|PROJECT|", project)
]'

# .readthedocs.yml file contents.
READTHEDOCS_CONTENTS="version: 2

sphinx:
  configuration: docs/source/conf.py

python:
  version: 3.5
  install:
    - requirements: docs/requirements.txt"

# index.rst file contents.
INDEX_CONTENTS="|PROJECT_GENERATED_NAME| documentation
==============================================================

|TRAVIS_CI_IMAGE|

|READTHEDOCS_IMAGE|

My project short description.

Full documentation on |READTHEDOCS_LINK|.

Source code on |GITHUB_REPO_LINK|.

Contents
========

.. toctree::
   :maxdepth: 2

   |PROJECT_GENERATED_NAME|

"

# myproject.rst file contents.
MYPROJECT_CONTENTS=".. |PROJECT| replace:: |PROJECT_GENERATED_NAME|

.. |DESCRIPTION| replace:: My project long description.

|PROJECT_GENERATED_NAME|
--------------------------------------------------------------

.. include:: description.inc

.. include:: ingredients.inc

.. include:: usage.inc

.. include:: actions.inc

.. include:: variables.inc

.. include:: requirements.inc

.. include:: compatibility.inc

.. include:: license.inc

.. include:: links.inc

.. include:: author.inc"

# description.inc file contents.
DESCRIPTION_CONTENTS='Overview
~~~~~~~~

|DESCRIPTION|'

# ingredients.inc file contents.
INGREDIENTS_CONTENTS='**Ingredients**

|INGREDIENTS_IMAGE|'

# usage.inc file contents
USAGE_CONTENTS="Usage
--------------------------------------------------------------

Download the script, give it execution permissions and execute it:

.. substitution-code-block:: bash

 wget https://raw.githubusercontent.com/|AUTHOR|/|PROJECT|/master/|PROJECT|.sh
 chmod +x |PROJECT|.sh
 ./|PROJECT|.sh -h"

# actions.inc file contents
ACTIONS_CONTENTS='Actions
--------------------------------------------------------------

When executed this project performs the following actions:

\- Description of action 1 executed.

\- Description of action 2 executed.

\- Description of action 3 executed:
    
\- Description of subaction 3.1 executed.
 
\- Description of subaction 3.2 executed.'

# variables.inc file contents.
VARIABLES_CONTENTS="Variables
--------------------------------------------------------------

The following variables are supported:

\- *-h* (help): Show help message and exit.

 .. substitution-code-block:: bash

  ./|PROJECT|.sh -h

\- *-p* (path): Optional path to project root folder.

 .. substitution-code-block:: bash

  ./|PROJECT|.sh -p /home/username/myproject"

# requirements.inc file contents.
REQUIREMENTS_CONTENTS='Requirements
--------------------------------------------------------------

\- Python 3.'

# compatibility.inc file contents.
COMPATIBILITY_CONTENTS='Compatibility
--------------------------------------------------------------

\- Debian buster.

\- Debian stretch.

\- Raspbian stretch.

\- Ubuntu xenial.'

# license.inc file contents.
LICENSE_CONTENTS='License
--------------------------------------------------------------

MIT. See the LICENSE file for more details.'

# links.inc file contents.
LINKS_CONTENTS='Links
--------------------------------------------------------------

|GITHUB_REPO_LINK|

|TRAVIS_CI_LINK|'

# author.inc file contents.
AUTHOR_CONTENTS='Author
--------------------------------------------------------------

|AUTHOR_IMAGE|

|AUTHOR_SLOGAN|'

# @description Shows help message.
#
# @noargs
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
function help() {

    echo 'Uses Sphinx to generate html and rst documentation.'
    echo 'Parameters:'
    echo '-h (help): Show this help message.'
    echo '-i (images url): Url to use when replacing images, default is
             http://raw.githubusercontent.com/username/images/master/project/.'
    echo '-d (developer): Applies developer configuration for a new project,
             see https://parts.readthedocs.io.'
    echo '-p <file_path> (project path): Optional absolute file path to the
             root directory of the project to generate documentation. If this
             parameter is not espeficied, the current path will be used.'
    echo 'Example:'
    echo "./docthis.sh -p /home/username/my_project -d -i https://i.imgur.com/project/"
    return 0

}

# @description Escape especial characters.
#
# The escaped characters are:
#
#  - Period.
#  - Slash.
#  - Double dots.
#
# @arg $1 string Text to scape.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Escaped input.
function escape() {
    [[ -z $1 ]] && echo '' && return 0
    local escaped=$(sanitize "$1")
    # Escape.
    escaped="${escaped//\./\\.}"
    escaped="${escaped//\//\\/}"
    escaped="${escaped//\:/\\:}"
    echo "$escaped"
    return 0
}

# @description Escape URLs.
#
# @arg $1 string URL to scape.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout The escaped URL plus ending slash if needed.
function escape_url() {
    [[ -z $1 ]] && echo '' && return 0
    local escaped=$(escape "$1")
    ! [[ "${escaped: -1}" == '/' ]] && escaped="$escaped\/"
    echo "$escaped"
    return 0
}

# @description Setup sphinx and generate html and rst documentation.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout *README-single* rst on project's root directory.
function generate() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local project=$(basename $project_path)

    local project_year=$(date +"%Y")

    local author=$(whoami)

    local images_url="https://raw.githubusercontent.com/$author/images/master/$project"
    ! [[ -z $IMAGES_URL ]] && images_url="$IMAGES_URL"
    images_url=$(escape_url "$images_url")
    
    # Setup everything for new projects.
    if ! [[ -f $project_path/docs/source/conf.py ]]; then

        # Directory layout.
        mkdir -p $project_path/docs/source/_static &>/dev/null
        mkdir -p $project_path/docs/source/_templates &>/dev/null
        mkdir -p $project_path/docs/build/html &>/dev/null
        mkdir -p $project_path/docs/build/rst &>/dev/null
                    
        # Create .readthedocs.yml configuration file.
        if ! [[ -f $project_path/.readthedocs.yml ]]; then
            printf "$READTHEDOCS_CONTENTS" > $project_path/.readthedocs.yml
        fi

        # Copy docthis.sh if not exists.
        if ! [[ -f $project_path/docthis.sh ]]; then
            cp "$( cd "$(dirname "$0")" ; pwd -P )"/docthis.sh $project_path/docthis.sh
        fi

        # If global variable DOCTHIS_DEVEL is true, apply developer configuration.
        if ! [[ -z $DOCTHIS_DEVEL ]] && [[ $DOCTHIS_DEVEL == true ]]; then

            # Directory layout.
            mkdir -p $project_path/example &>/dev/null

            # Create sample package layout.
            wget https://raw.githubusercontent.com/constrict0r/parts/master/example/__init__.py \
                -O $project_path/example/__init__.py
            wget https://raw.githubusercontent.com/constrict0r/parts/master/example/amanita.py \
                -O $project_path/example/amanita.py

            # Create requirements.txt file.
            wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/requirements.txt \
                -O $project_path/docs/requirements.txt

            # Create conf.py file.
            wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/conf.py \
                -O $project_path/docs/source/conf.py

            # Create source files.
            if ! [[ -f $project_path/docs/source/index.rst ]]; then
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/index.rst \
                    -O $project_path/docs/source/index.rst
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/parts.rst \
                    -O $project_path/docs/source/${project}.rst
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/description.inc \
                    -O $project_path/docs/source/description.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/ingredients.inc \
                    -O $project_path/docs/source/ingredients.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage.inc \
                    -O $project_path/docs/source/usage.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-script.inc \
                    -O $project_path/docs/source/usage-script.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-bats-tests.inc \
                    -O $project_path/docs/source/usage-bats-tests.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-role.inc \
                    -O $project_path/docs/source/usage-role.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-role-variables.inc \
                    -O $project_path/docs/source/usage-role-variables.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-role-dependency.inc \
                    -O $project_path/docs/source/usage-role-dependency.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-role-tasks.inc \
                    -O $project_path/docs/source/usage-role-tasks.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-playbook-tests.inc \
                    -O $project_path/docs/source/usage-playbook-tests.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-plugin.inc \
                    -O $project_path/docs/source/usage-plugin.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-plugin-tasks.inc \
                    -O $project_path/docs/source/usage-plugin-tasks.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-script-tests.inc \
                    -O $project_path/docs/source/usage-script-tests.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-package.inc \
                    -O $project_path/docs/source/usage-package.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-package-tests.inc \
                    -O $project_path/docs/source/usage-package-tests.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/actions.inc \
                    -O $project_path/docs/source/actions.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/parameters.inc \
                    -O $project_path/docs/source/parameters.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/parameter-help.inc \
                    -O $project_path/docs/source/parameter-help.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/parameter-path.inc \
                    -O $project_path/docs/source/parameter-path.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/variables.inc \
                    -O $project_path/docs/source/variables.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/variable-validate.inc \
                    -O $project_path/docs/source/variable-validate.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/variable-items.inc \
                    -O $project_path/docs/source/variable-items.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/requirements.inc \
                    -O $project_path/docs/source/requirements.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/requirement-python.inc \
                    -O $project_path/docs/source/requirement-python.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/requirement-ansible.inc \
                    -O $project_path/docs/source/requirement-ansible.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/compatibility.inc \
                    -O $project_path/docs/source/compatibility.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/license.inc \
                    -O $project_path/docs/source/license.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/links.inc \
                    -O $project_path/docs/source/links.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/uml.inc \
                    -O $project_path/docs/source/uml.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/uml-deployment.inc \
                    -O $project_path/docs/source/uml-deployment.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/author.inc \
                    -O $project_path/docs/source/author.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/enjoy.inc \
                    -O $project_path/docs/source/enjoy.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/api.rst \
                    -O $project_path/docs/source/api.rst
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/scripts.inc \
                    -O $project_path/docs/source/scripts.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/script-docthis.inc \
                    -O $project_path/docs/source/script-docthis.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/packages.inc \
                    -O $project_path/docs/source/packages.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/package-example.inc \
                    -O $project_path/docs/source/package-example.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/module-amanita.inc \
                    -O $project_path/docs/source/module-amanita.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-docthis.inc \
                    -O $project_path/docs/source/usage-docthis.inc
                wget https://raw.githubusercontent.com/constrict0r/parts/master/docs/source/usage-testme.inc \
                    -O $project_path/docs/source/usage-testme.inc

                sed -i -E "s/constrict0r/$author/g" $project_path/docs/source/*.*
                sed -i -E "s/parts/$project/g" $project_path/docs/source/*.*
                sed -i -E "s/https\:\/\/raw\.githubusercontent\.com\/$author\/images\/master\/$project/$images_url/g" $project_path/docs/source/*.*

            fi

        # Apply standard configuration.
        else

            # Create requirements.txt file.
            if ! [[ -f $project_path/docs/requirements.txt ]];
            then
                printf "$REQUIREMENTS_PIP" > $project_path/docs/requirements.txt
            fi

            # Create conf.py file.
            if ! [[ -f $project_path/docs/source/conf.py ]];
            then
                printf "$CONFIGURATION_CONTENTS" > $project_path/docs/source/conf.py
            fi

            # Create source files.
            if ! [[ -f $project_path/docs/source/index.rst ]]; then
                printf "$INDEX_CONTENTS" > $project_path/docs/source/index.rst
                printf "$MYPROJECT_CONTENTS" > $project_path/docs/source/${project}.rst
                printf "$DESCRIPTION_CONTENTS" > $project_path/docs/source/description.inc
                printf "$INGREDIENTS_CONTENTS" > $project_path/docs/source/ingredients.inc
                printf "$USAGE_CONTENTS" > $project_path/docs/source/usage.inc
                printf "$ACTIONS_CONTENTS" > $project_path/docs/source/actions.inc
                printf "$VARIABLES_CONTENTS" > $project_path/docs/source/variables.inc
                printf "$REQUIREMENTS_CONTENTS" > $project_path/docs/source/requirements.inc
                printf "$COMPATIBILITY_CONTENTS" > $project_path/docs/source/compatibility.inc
                printf "$LICENSE_CONTENTS" > $project_path/docs/source/license.inc
                printf "$LINKS_CONTENTS" > $project_path/docs/source/links.inc
                printf "$AUTHOR_CONTENTS" > $project_path/docs/source/author.inc
                sed -i -E "s/\|AUTHOR_GENERATED_NAME\|/$author/g" $project_path/docs/source/*.*
                sed -i -E "s/\|PROJECT_GENERATED_NAME\|/$project/g" $project_path/docs/source/*.*
                sed -i -E "s/\|YEAR_GENERATED_VALUE\|/$project_year/g" $project_path/docs/source/*.*
                sed -i -E "s/\|IMAGES_URL_GENERATED_VALUE\|/$images_url/g" $project_path/docs/source/*.*
            fi

        fi # Standard or devel?

        # Install requirements if not already installed.
        local sphinx_requirements=$(python3 -m pip list --format=columns)
        sphinx_requirements="${sphinx_requirements,,}"
        sphinx_requirements="${sphinx_requirements//-/_}"
        local current_line=''
        while read LINE
        do
            current_line=$LINE
            current_line="${current_line,,}"
            current_line="${current_line//-/_}"
            ! [[ $sphinx_requirements == *"$current_line"* ]] && python3 -m pip install $LINE
        done < $project_path/docs/requirements.txt

    fi # New project?.

    # Generate documentation.
    python3 -m sphinx -b html $project_path/docs/source/ $project_path/docs/build/html
    generate_rst $project_path

    return 0
}

# @description Generate rst documentation using sphinx.
#
# This function will extract each filename to include from the index.rst file
# and concatenate all files into a single README-single.rst file.
#
# This function assumes:
#   - The project has a file structure as created by generate().
#   - The index.rst file contains a blank new line at the end.
#   - The names of each file on index.rst does not contains .rst.
#   - The toc on the index.rst file contains the :maxdepth: directive.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout *README-single* rst on project's root directory.
function generate_rst() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # When a line readed from the index.rst file is a menu item,
    # this variable will be setted to true.
    # This is a flag to indicate if we found the items to
    # include on the resulting README file when reading the source index file.
    local items_found=false

    # Clean files first.
    rm -r $project_path/docs/build/rst/*.rst &>/dev/null

    python3 -m sphinx -b rst $project_path/docs/source/ $project_path/docs/build/rst

    # Recreate the file to append content.
    if [[ -f $project_path/docs/build/rst/index.rst ]]; then
       readthedocs_to_rst $project_path/docs/build/rst/index.rst $(basename $project_path)
       cat $project_path/docs/build/rst/index.rst > $project_path/README-single.rst
       printf '\n' >> $project_path/README-single.rst
    fi

    while read LINE
    do
        # The directive :maxdepth: of the index.rst file
        # activates the search for menu item lines within that file.
        [[ $LINE == *':maxdepth:'* ]] && items_found=true && continue

        if [[ $items_found == true ]] && ! [[ -z "$LINE"  ]]; then

            # Apply conversion from readthedocs to common rst.
            readthedocs_to_rst $project_path/docs/build/rst/${LINE}.rst $(basename $project_path)

            if [[ -f $project_path/docs/build/rst/${LINE}.rst ]]; then
                cat $project_path/docs/build/rst/${LINE}.rst >> $project_path/README-single.rst
                printf "\n" >> $project_path/README-single.rst
            fi

        fi

    done < $project_path/docs/source/index.rst

    return 0
}

# @description Get bash parameters.
#
# @arg '$@' string Bash arguments.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
function get_parameters() {

    # Obtain parameters.
    while getopts 'h;i:d;p:' opt; do
        OPTARG=$(sanitize "$OPTARG")
        case "$opt" in
            h) help && exit 0;;
            i) IMAGES_URL="${OPTARG}";;
            d) DOCTHIS_DEVEL=true;;
            p) PROJECT_PATH="${OPTARG}";;
        esac
    done

    return 0
}

# @description Generate documentation using sphinx.
#
# @arg $@ string Bash arguments.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
function main() {

    get_parameters "$@"

    generate "$PROJECT_PATH"
 
    return 0
}

# @description Replace reference from readthedocs format to standard rst.
#
# This function assumes:
#
#  - The author is the current user running the script.
#  - A travis-ci enviroment exists for the current component.
#  - An images repository exists the current user/project.
#
# See `this link <https://github.com/constrict0r/images>`_ for an example images repository.
#
# @arg $1 string Path to file where to apply replacements.
# @arg $2 string Optional project name to use in replacements.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Modified passed file.
function readthedocs_to_rst() {

    ! [[ -f $1 ]] && return 1

    author=$(whoami)

    # If no project name was passed, try to figure out the name.
    local project=''
    if [[ -z $2 ]]; then
        project=$(basename $(pwd))
    else
        project="$2"
    fi

    local images_url="https://raw.githubusercontent.com/$author/images/master/$project"
    ! [[ -z $IMAGES_URL ]] && images_url="$IMAGES_URL"
    images_url=$(escape_url "$images_url")

    # Convert all `<text.rst>`_ references to `<#text>`.
    sed -i -E "s/\<([[:alpha:]]*[[:punct:]]*)+\.rst\>//g" $1
    sed -i -E 's/([[:alpha:]]+)\ <>/\1\ <#\1>/g' $1

    # Replace travis status badge image.
    sed -i -E "s/\[image\:\ travis\]\[image\]/\.\.\ image\:\:\ https\:\/\/api\.travis-ci\.org\/$author\/$project\.svg\\n   :alt: travis/g" $1

    # Replace readthedocs status badge image.
    sed -i -E "s/\[image\:\ readthedocs\]\[image\]/\.\.\ image\:\:\ https\:\/\/readthedocs\.org\/projects\/$project\/badge\\n   :alt: readthedocs/g" $1

    # Replace coverage status badge image.
    sed -i -E "s/\[image\:\ coverage\]\[image\]/\.\.\ image\:\:\ https\:\/\/coveralls\.io\/repos\/github\/$author\/$project\/badge\.svg\\n   :alt: coverage/g" $1

    # Replace rest of images.
    sed -i -E "s/\[image\:\ (.*)+\]\[image\]/\.\.\ image\:\:\ $images_url\1\.png\\n   :alt: \1/g" $1

    return 0
}

# @description Sanitize input.
#
# The applied operations are:
#
#  - Trim.
#
# @arg $1 string Text to sanitize.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Sanitized input.
function sanitize() {
    [[ -z $1 ]] && echo '' && return 0
    local sanitized="$1"
    # Trim.
    sanitized="${sanitized## }"
    sanitized="${sanitized%% }"
    echo "$sanitized"
    return 0
}

# Avoid running the main function if we are sourcing this file.
return 0 2>/dev/null
main "$@"
