# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html
import makeflow
from datetime import datetime

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "makeflow"
year = datetime.now().year
author = "Simon A. F. Lund"
copyright = f"{year}, {author}"

version = f"v{makeflow.__version__}"
release = version

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx.ext.extlinks",
    "sphinx_copybutton",
    "sphinx_tabs.tabs",
]
pygments_style = "sphinx"

templates_path = ["_templates"]
exclude_patterns = []

extlinks = {
    "xref-sphinxdoc": ("https://www.sphinx-doc.org/%s", None),
}

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_static_path = ["_static"]
html_theme = "pydata_sphinx_theme"

html_theme_options = {
    "collapse_navigation": False,
    "navigation_depth": 4,
    "navigation_with_keys": False,
    "navbar_align": "left",
    "navbar_end": ["version-switcher"],
    "header_links_before_dropdown": 8,
    "secondary_sidebar_items": {
        "**": ["page-toc"],
        "index": [],
    },
    "show_prev_next": False,
    "show_nav_level": 2,
    "icon_links": [
        {
            "name": "GitHub",
            "url": "https://github.com/safl/{project}",
            "icon": "fa-brands fa-square-github",
            "type": "fontawesome",
        },
    ],
    "switcher": {
        "json_url": f"https://safl.dk/{project}/versions.json",
        "version_match": version,
    },
    "show_version_warning_banner": True,
    "check_switcher": False,
}

html_context = {
    "default_mode": "light",
}

html_show_sourcelink = False

linkcheck_report_timeouts_as_broken = False
