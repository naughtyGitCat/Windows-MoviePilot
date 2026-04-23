# Windows-MoviePilot build scripts

此目录是 CI workflow 编译 Inno Setup 安装包时使用的源文件。

## 文件说明

| 文件 | 作用 |
|---|---|
| `build.iss`              | Inno Setup 主脚本，定义安装/卸载逻辑 |
| `launcher.bat`           | 不装 service 时桌面图标调用的入口 (前台运行 FastAPI 后端) |
| `restart.bat`            | `SystemUtils.restart()` 触发的重启工具（`RebotMP.bat` 的替身） |
| `nssm.exe`               | NSSM v2.24 (公共领域)，把 python.exe 包装成 Windows service |
| `service-install.ps1`    | 安装 + 启动 service (Inno Setup [Run] 调用，也可手动跑) |
| `service-uninstall.ps1`  | 停止 + 删除 service ([UninstallRun] 调用) |
| `ChineseSimplified.isl`  | 可选：中文向导语言文件。放入此目录后在 `build.iss` 取消 `chinesesimp` 注释 |

## 本地编译（需要 Windows + Inno Setup 6）

```powershell
# 准备 build 源文件同级的相对路径：
#   ..\..\MoviePilot\           (server src)
#   ..\..\MoviePilot-Frontend\  (frontend dist)
#   ..\..\Python3.11\           (python runtime)
iscc /DMyAppVersion=2.6.7.abcdef build.iss
# 输出：exe\MoviePilot-V2-Setup-<version>.exe
```

## 插件策略

**安装包不预装任何插件**。MoviePilot 原版会在 workflow 里把 `MoviePilot-Plugins/plugins.v2/*`
全部打包 + `pip install` 每个插件的 `requirements.txt`，这是 400+ MB 体积的主因
(playwright 96MB, googleapiclient 89MB, spacy 86MB, jieba 41MB 等)。

MoviePilot 本身已经有完整的**运行时插件管理**：

- `app/startup/plugins_initializer.sync_plugins()` 启动时检查
- `PluginManager.install_plugin_missing_dependencies()` pip install 缺失依赖
- `PluginHelper.install()` 从插件市场下载代码 + pip install

用户在 Web UI 点"安装插件"时，MoviePilot 会自动从插件市场下载代码并 pip install
依赖。**我们不需要在 CI 里预装**，只为了用户还没启用的插件占硬盘。

## 与原版 `developer-wlj/Inno-Setup-MoviePilot` 的区别

原版打包脚本是私仓，此目录是从 0 重写的公开版本。相对原版简化：

- **不安装 Nginx** — FastAPI StaticFiles 直接托管前端
- **不安装 portable Git** — 不做安装后 `git pull` 升级（全走安装器重装）
- **安装目录结构**：`{app}\MoviePilot\`, `\MoviePilot-Frontend\`, `\Python3.11\`
- **单入口 `MoviePilot.bat`**（原版是 `[启动]MoviePilot.bat` + `windows_start.cmd` 两层）
- **重启工具改用 `RebotMP.bat`**（后端代码已兼容 `.bat` 和 `.exe`）
- **向导默认英文**（app UI 仍为中文）
- **支持安装为 Windows Service**（NSSM 内嵌，向导里勾选即可）

## 服务模式 (默认)

安装向导第一步会让你选 "Install as Windows service"（默认勾选）。勾选后:

- 注册一个名为 `MoviePilot-V2` 的 Windows 服务，开机自启
- 进程崩溃自动重启 (5 秒延迟)
- stdout/stderr 写到 `{app}\service-logs\`，10MB 自动轮转
- 默认以 LocalSystem 身份运行 (看不到映射的网络盘 → 如需，用 services.msc 改"登录"账户)

不勾选则安装包同样可用，桌面双击 `MoviePilot.bat` 前台启动。

服务管理：
```powershell
net start MoviePilot-V2
net stop MoviePilot-V2
Restart-Service MoviePilot-V2
```

升级安装时：[Code] PrepareToInstall 会先 `net stop` 服务释放文件锁，再覆盖；新版装完后 [Run] 重新装+启动 service，配置/数据库零丢失。

卸载时：[UninstallRun] 自动停止并删除 service。
