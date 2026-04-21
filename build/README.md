# Windows-MoviePilot build scripts

此目录是 CI workflow 编译 Inno Setup 安装包时使用的源文件。

## 文件说明

| 文件 | 作用 |
|---|---|
| `build.iss`     | Inno Setup 主脚本，定义安装/卸载逻辑 |
| `launcher.bat`  | 安装后桌面图标调用的入口，启动 FastAPI 后端（端口 3111） |
| `restart.bat`   | `SystemUtils.restart()` 触发的重启工具（`RebotMP.bat` 的替身） |
| `ChineseSimplified.isl` | 可选：中文向导语言文件。放入此目录后在 `build.iss` 取消 `chinesesimp` 注释 |

## 本地编译（需要 Windows + Inno Setup 6）

```powershell
# 准备 build 源文件同级的相对路径：
#   ..\..\MoviePilot\           (server src)
#   ..\..\MoviePilot-Frontend\  (frontend dist)
#   ..\..\Python3.11\           (python runtime)
iscc /DMyAppVersion=2.6.7.abcdef build.iss
# 输出：exe\MoviePilot-V2-Setup-<version>.exe
```

## 与原版 `developer-wlj/Inno-Setup-MoviePilot` 的区别

原版打包脚本是私仓，此目录是从 0 重写的公开版本。相对原版简化：

- **不安装 Nginx** — FastAPI StaticFiles 直接托管前端
- **不安装 portable Git** — 不做安装后 `git pull` 升级（全走安装器重装）
- **安装目录结构**：`{app}\MoviePilot\`, `\MoviePilot-Frontend\`, `\Python3.11\`
- **单入口 `MoviePilot.bat`**（原版是 `[启动]MoviePilot.bat` + `windows_start.cmd` 两层）
- **重启工具改用 `RebotMP.bat`**（后端代码已兼容 `.bat` 和 `.exe`）
- **向导默认英文**（app UI 仍为中文）
