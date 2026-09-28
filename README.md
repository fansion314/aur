# fansion314/aur

统一维护的 **paru PKGBUILD 仓库**，同时提供非 `-bin` 配方和下载 GitHub
预构建资产的 `-bin` 配方。当前目标为 Arch Linux / CachyOS x86_64。
不需要 AUR 注册账号，也不需要修改 `AurUrl` 或 pacman 官方软件源。

## 配置一次

在已有的 `~/.config/paru/paru.conf` 或 `/etc/paru.conf` 末尾添加：

```ini
[fansion314]
Url = https://github.com/fansion314/aur.git
Path = packages
```

如果原来没有用户级配置，希望继续使用系统配置，可以创建用户配置：

```ini
Include = /etc/paru.conf

[fansion314]
Url = https://github.com/fansion314/aur.git
Path = packages
```

不要覆盖已有配置。使用了 `Mode` 选项时，确保包含 `pkgbuilds`；不要打开
`SkipReview`，保留 paru 的配方审阅步骤。

```sh
# 正常刷新并升级；后续也使用这一命令获取新版本
paru -Syu

# 推荐下载预构建应用，在本机完成 pacman 打包
paru -S fansion314/dnr-bin fansion314/pi-dnr-bin fansion314/etcher-dnr-bin
paru -S fansion314/motrix2-bin fansion314/dsh-electron-bin
paru -S fansion314/bitwarden-electron-bin fansion314/obsidian-electron-bin

# 需要独立应用打包器
paru -S fansion314/dnc-bin

# 选择非 bin 版本的示例（同一应用只选一种变体）
paru -S fansion314/motrix2
```

`-bin` 不会编译应用，但仍会执行已审阅的 PKGBUILD、校验下载、生成本机
`.pkg.tar.zst` 并调用 pacman 安装。非 bin 版本保留各项目自己的构建方式；
Bitwarden/Obsidian 的非 bin 配方也是从官方应用重新整理打包，并非编译其全部源码。
配置这个仓库不会在后台无人值守升级；运行 `paru -Syu` 才执行升级。

## 包清单

| 项目 | 非 bin 配方 | 预构建配方 |
| --- | --- | --- |
| [dnr](https://github.com/fansion314/dnr) | `dnr`、`dnr-cef`、`dnr-webview`、`dnc` | `dnr-bin`、`dnr-cef-bin`、`dnr-webview-bin`、`dnc-bin` |
| [Pi](https://github.com/fansion314/pi) | `pi-dnr` | `pi-dnr-bin` |
| [Etcher](https://github.com/fansion314/etcher) | `etcher-dnr` | `etcher-dnr-bin` |
| [Motrix](https://github.com/fansion314/Motrix) | `motrix2` | `motrix2-bin` |
| [DeepSeek Harness](https://github.com/fansion314/deepseek-harness) | `dsh-electron` | `dsh-electron-bin` |
| [Bitwarden](https://github.com/fansion314/bitwarden) | `bitwarden-electron` | `bitwarden-electron-bin` |
| [Obsidian](https://github.com/fansion314/obsidian) | `obsidian-electron` | `obsidian-electron-bin` |
| 松间 Songjian | 仅本地维护，不公开同步 | 不发布 |

共 7 个公开项目、20 个配方。松间仅作范围说明，不包含它的源码、构建文件或资产。
包名、`provides`、`conflicts` 和系统 Electron/dnr 依赖保持源仓库定义。
dnr 默认是双后端，两个单后端版本为可选项，不能同时安装。

## 自动同步

`.github/workflows/sync.yml` 每小时检查一次，也可手动运行。Actions 使用本仓库
的 `GITHUB_TOKEN` 读取公开来源并写入本仓库，无跨仓库 PAT、AUR SSH 密钥或账号。

1. `sources.json` 显式限定仓库、配方目录及例外。普通项目固定到读取时的提交，
   复制 PKGBUILD、`.SRCINFO` 和辅助文件。Motrix 读取正式 Release 中生成的
   `*-aur.tar.gz`，避免默认分支尚未回写时使用过期配方。
2. 验证本地辅助文件和所有 bin 输入的校验和，核对 GitHub asset digest；有
   独立 `.sha256` 文件时也交叉验证。源配方中的 bin `SKIP` 会替换为真实 SHA-256。
   预构建内容继续从原项目 GitHub Release 下载，不复制到本仓库。
3. 在 Arch x86_64 中用非 root 用户运行 `makepkg --printsrcinfo`，核对全部配方，
   使用 pacman 的 `vercmp` 拒绝降级。构建发生变化的 bin 包并核对包名、版本、架构和
   非空应用文件。dnr/dnc/Pi 同时构建时还运行基础运行时烟雾检查。
4. 全部通过后才提交 `packages/` 和 `state/`。没有配方变更时跳过打包，不产生空提交。
   失败保留上一版，日志在 Actions；普通分支推送或手动运行会验证所有 bin 配方。

Motrix beta 与 DeepSeek rc 是这些项目当前维护的发布通道，按其配方与正式发布资产同步。
只有提交 `pkgver`/`pkgrel` 更新并发布所需资产后，用户的 `paru -Syu` 才会看到升级；
单纯修改应用源码不会直接改变仓库版本。发布过程尚未上传全部资产时，本轮同步会失败，
下一次定时运行可自动重试。不会用较旧的包覆盖新包。

源码版在此验证语法、元数据与辅助文件；完整应用编译/GUI 验证由各源项目负责，
此同步任务不冒充对每个大型应用做了完整源码重建或 GUI 验收。

## 维护

```sh
python3 -m unittest discover -s tests -v
python3 scripts/sync.py             # 需要 gh 登录及网络
python3 scripts/sync.py motrix      # 单项目同步
# Arch Linux 非 root 用户：
python3 scripts/validate.py --build-bins
gh workflow run sync.yml -R fansion314/aur
```

`packages/` 与 `state/` 为自动生成；修复优先提交到对应源仓库，再同步。同步状态记录
源仓库提交或 Release tag、配方版本、文件哈希及预构建资产哈希。辅助文件保持原许可，
应用许可证以源项目和安装包中的声明为准。

参考：[paru 官方 PKGBUILD repository 文档](https://github.com/Morganamilo/paru/blob/master/man/paru.conf.5#L371)。
