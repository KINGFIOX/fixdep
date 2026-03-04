# fixdep Usage

## Invocation

```text
fixdep <depfile> <target> <cmdline>
```

## Arguments

| Argument | Description |
|----------|-------------|
| depfile  | Path to the dependency file, usually the `.d` file produced by gcc `-MD` / `-MMD` |
| target   | Target name (e.g. `source.o`), used to form make variable names like `cmd_<target>`, `deps_<target>` |
| cmdline  | Full command line used to compile that target; written into `cmd_<target>` |

## Output

The program writes to **stdout**:

1. **cmd line**: `cmd_<target> = <cmdline>`
2. **Source variable**: `source_<target> := <first dependency>`
3. **Dependency list**: `deps_<target> := \` and subsequent dependency lines
4. **Rules**: `<target>: $(deps_<target>)` and `$(deps_<target>):`

Typical use is to redirect stdout to a file such as `.foo.o.cmd`, then include it from the main Makefile.

## Behavior

- **Ignores** dependencies on these files (they are not written to deps):
  - `include/generated/autoconf.h`
  - `include/generated/autoksyms.h`
- **Scans** remaining dependency file contents for `CONFIG_*` symbols and emits a dependency on the corresponding header under `include/config/...` (`$(wildcard include/config/...)`) for each, so that fine-grained config dependencies replace the single dependency on `autoconf.h`.
- If a dependency file contains `CONFIG_FOO_MODULE`, it is treated as `CONFIG_FOO` (the `_MODULE` suffix is dropped when generating the include/config dependency).

## Example

```bash
# Given a .foo.o.d produced by gcc -MD, produce .foo.o.cmd
fixdep .foo.o.d foo.o 'gcc -c foo.c -o foo.o ...' > .foo.o.cmd
```

## Errors and exit codes

- Wrong number of arguments: usage printed to stderr, exit 1.
- No target found while parsing: exit 1.
- Failed to open or read depfile or any listed dependency: exit 2.
- Memory allocation or writing to stdout fails: exit 1.
