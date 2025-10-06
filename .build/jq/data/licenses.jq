# formats SPDX license identifiers objects in .data/licenses.json
(.[].name |= ascii_downcase) | (.[].id |= ascii_downcase) | sort_by(.id) | unique_by(.id)
