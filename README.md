# fixdep

优化由 `gcc -MD` 产生的依赖列表，用于内核构建等场景。

## 简介

`gcc -MD` 会生成正确且完整的依赖列表，但若直接使用，几乎所有文件都会依赖 `autoconf.h`。一旦用户重新执行 `make *config` 并重新生成 `autoconf.h`，make 会认为所有包含该头的文件都需要重编，即使只改了一个配置项（如 `CONFIG_FOO` 从 `n` 改为 `m`）。

fixdep 的做法与过去的 `mkdep` 类似：把对 `autoconf.h` 的依赖替换为对各个实际用到的配置符号的依赖（对应 `include/config/...` 下的空文件）。这样只有真正用到被修改配置的源文件才会被重编。

## 用法

```text
fixdep <depfile> <target> <cmdline>
```

- **depfile**：依赖文件（如 gcc -MD 的输出）
- **target**：目标名（如 `foo.o`）
- **cmdline**：用于编译该目标的完整命令行

转换后的依赖片段会写到标准输出，通常被重定向到 `.*.cmd` 等文件。

## 构建

### Meson

```bash
meson setup build
meson compile -C build
meson install -C build
```

### Nix

```bash
nix build
# 或进入开发环境
nix develop
```

## 在其他项目的 Makefile 中使用

构建得到单个可执行文件 `fixdep`，安装到 `PATH` 或在 Makefile 中指定路径即可使用。

```makefile
# 指定 fixdep（未安装时可用绝对路径或 Nix 提供）
FIXDEP ?= fixdep

# 示例：先由 gcc -MD 生成 .*.d，再用 fixdep 生成 .*.cmd
%.o: %.c
	$(CC) -c $(CFLAGS) -MD -MF .$@.d -o $@ $<
	$(FIXDEP) .$@.d $@ '$(CC) -c $(CFLAGS) -o $@ $<' > .$@.cmd
```

若希望由 Nix 提供 `fixdep`，可在该项目的 flake 中将本仓库加入 inputs，并在 `devShell.nativeBuildInputs` 中加入 `fixdep.packages.${system}.default`，Makefile 里用 `fixdep` 或 `$(FIXDEP)` 即可。

## 许可

GPL-2.0-only。详见源码头部注释。

## 出处

源自 Linux 内核构建系统中的 fixdep，作者 Kai Germaschewski。设计思路可追溯至 Michael E. Chastain 等人。
