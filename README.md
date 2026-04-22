# Windows-MoviePilot (naughtyGitCat fork)

基于 [developer-wlj/Windows-MoviePilot](https://github.com/developer-wlj/Windows-MoviePilot) 重构的精简版 Windows 安装包，主要差异：

- **去掉 Nginx**：FastAPI 直接通过 StaticFiles 托管前端（后端端口同时服务 UI + API）
- **去掉便携版 Git**：不走 git pull 在线更新，升级统一走安装包重装
- **Python embeddable 分发**：替代完整 Python 安装，体积大幅缩减
- **不预装插件**：插件按需从 Web UI 的插件市场在线安装（MoviePilot 本身就支持）
- **后端代码开源**：对应 MoviePilot fork 在 [naughtyGitCat/MoviePilot@v2-static](https://github.com/naughtyGitCat/MoviePilot/tree/v2-static)，Inno Setup 打包脚本在 [`build/`](./build/) 目录公开

预计安装包大小从原版的 ~1GB 降至 **~150-200MB**。

## 安装

1. 下载 [Releases](https://github.com/naughtyGitCat/Windows-MoviePilot/releases) 页最新 `.exe`
2. **安装路径要求**（和原版一致）：
   - 系统必须是 64 位
   - 系统必须有 Visual C++ Redistributable（[下载](https://aka.ms/vs/17/release/VC_redist.x64.exe)）
   - 安装目录的完整路径**不能超过 260 字符**
   - 安装目录**不能包含空格**
   - 不建议装到 `C:\Program Files*` 下（需管理员才能写，可能看不到用户挂载盘）
3. 双击桌面 `MoviePilot-V2` 图标启动
4. 浏览器访问 `http://127.0.0.1:3111`
   - 用户名：`admin`
   - 密码：首次启动随机生成，写入到 `config\logs\` 日志中

## 升级

直接下载新版 `.exe` 覆盖安装即可。**以下数据会保留**：

- 用户配置 `app.env`（TMDB key、下载器凭证、认证信息等）
- 分类规则 `category.yaml`（即使你改过）
- 站点 Cookie、日志、缓存
- 订阅 / 下载 / 刮削历史（`user.db` SQLite 数据库）
- 从 Web UI 安装的插件代码和插件配置

**会被替换**：

- MoviePilot 核心代码 `MoviePilot\app\`
- Python 运行时 `Python3.11\`
- 前端资源 `MoviePilot-Frontend\`

升级后**首次启动可能需要几分钟**：
- 核心依赖刷成新版本
- 数据库 schema 自动迁移（MoviePilot 内建 Alembic）
- 已安装插件检测到依赖变动时会自动 pip install

### 对比原版

原版 README 说：
> 升级安装, 会覆盖 category.yaml

我们的 installer 用 `onlyifdoesntexist` 标记 `category.yaml`，**不会覆盖**，用户自定义的分类规则安全。

## 卸载

用控制面板或开始菜单的 `Uninstall MoviePilot-V2`。默认**保留 `config\` 目录**（含你的数据库和设置），重装或迁移时可直接恢复。如果要彻底清除，手动删除安装目录。

## 疑难

### 启动后浏览器打不开 / 502

- 检查托盘区是否有 MoviePilot 图标（把鼠标放在托盘上触发刷新）
- 图标存在但未响应：服务可能还在启动。第一次启动要初始化数据库，等 1-2 分钟
- 无图标：启动失败。打开安装目录 → `MoviePilot\` 下右键 → 在终端打开 → 运行：
  ```powershell
  ..\Python3.11\python.exe .\app\main.py
  ```
  看错误输出。常见问题：`Permission denied` 需要管理员身份

### 插件启用后报 ModuleNotFound

插件依赖自动安装在后台进行，可能还没跑完。等几分钟再刷新页面；或重启 MoviePilot。

### 看不到网络挂载盘

Windows 把映射的网络盘符绑定到用户会话。如果 MoviePilot 以管理员身份运行（装在 `Program Files*` 下时会被提示），会看不到普通用户挂载的盘。解决：装到非系统盘，普通权限运行。

## 端口

| 端口 | 用途 |
|---|---|
| **3111** | 后端 API + 前端 UI（单端口，FastAPI + StaticFiles） |

原版的 `3000` (Nginx) / `3333` (Nginx 前端) 端口本版本**不再使用**。

## 相关仓库

| 仓库 | 内容 |
|---|---|
| [naughtyGitCat/Windows-MoviePilot](https://github.com/naughtyGitCat/Windows-MoviePilot) | 本仓库（CI + Inno Setup 打包脚本） |
| [naughtyGitCat/MoviePilot@v2-static](https://github.com/naughtyGitCat/MoviePilot/tree/v2-static) | 后端代码 fork，含 FastAPI StaticFiles 补丁 |
| [jxxghp/MoviePilot](https://github.com/jxxghp/MoviePilot) | 上游原版 MoviePilot |
| [developer-wlj/Windows-MoviePilot](https://github.com/developer-wlj/Windows-MoviePilot) | 本 fork 的来源 |

## 交流群

- 原版 TG 群：https://t.me/+o7RfmjHOf183OGM1
- 本 fork 问题请走 [Issues](https://github.com/naughtyGitCat/Windows-MoviePilot/issues)
