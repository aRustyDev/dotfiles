root := `git rev-parse --show-toplevel`
rootn := `git rev-parse --show-toplevel | wc -c`
justd := root + "/.build/just"

# Extracts TODOs from SRC and puts them in .docs/src/todos/<cat>/todo-xxx.md
# todos src:
#     @cp {{src}} $root/.docs/src/todos/<cat>/todo-xxx.md

# _cat src:
#     @echo ""

# _dest src:
#     @echo ""

test:
    for file in $(just --justfile {{justfile()}} _non_todomd); do \
        echo {{root}}/$file; \
        rg -i 'todo' {{root}}/$file; \
    done

_non_todomd:
    @just --justfile {{justfile()}} _find_todos | rg -v -i 'todo.md'

# Finds the files
_find_todos:
    @rg --sort=path --ignore-file="{{justd}}/todos.rg.ignore" -c -i 'todo' {{root}}/** \
    | sed "s|$(git rev-parse --show-toplevel)/||; s/:[0-9]*$//"
