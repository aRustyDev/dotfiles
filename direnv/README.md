### direnv Utility Functions
direnv also provides you with a set of utility functions that are available in the context of .envrc file.

As an example, the `PATH_add` function can be used to expand the values of the `$PATH` variable.

So instead of adding a new path using `export PATH=<my-new-path>:$PATH`, you can write `PATH_add my-new-path` and it will be automatically added to your `$PATH` variable.

### Other Utility Functions:

direnv calls these utility functions as stdlib functions. There are other useful functions available such as:

- `source_env` - this function loads up another .envrc by specifying a path or its filename.
- `path_add` - works just like `PATH_add` but can be used to provide a path to another variable such as specifying the **JAVA_HOME** for a directory.
- `dot_env` - loads up a `.env` file into the current environment without the need of installing any dependency. So, your project has less load of a directory.
- `layout node` - adds `$PWD/node_modules/.bin` to the **PATH** environment variable. So you can directly call executable commands present inside your node_modules without the need to refer the path such as calling ./node_modules/bin/lerna bootstrap. You'll be able to directly call lerna bootstrap without the need to prepend the path.
- `use node <version>` - loads the specified NodeJS version from a .node-version or .nvmrc file.
- `watch_file <path> [<path> ...]` - adds one or more files to a watch list. direnv will reload your shell environment on the next prompt, if any of the provided file changes.

You can find a list of all supported stdlib functions at this documentation link.

> Note: It is also possible to create your own extensions by creating a bash file at `~/.config/direnv/direnvrc` or `~/.config/direnv/lib/*.sh`. These files are loaded before your .envrc and thus allow you to make your own customized extensions to direnv.
