# PersistentWindows-cn

基于开源项目 [PersistentWindows](https://github.com/kangyu-california/PersistentWindows)（作者 kangyu-california，原始作者 Min Yong Kim）的 **5.76 版本**修改而来的中文增强版。

**本仓库仅供个人学习使用。所有修改均遵循上游的 GPL-3.0 许可证开源（见 LICENSE 文件）。请前往[原仓库](https://github.com/kangyu-california/PersistentWindows)获取官方版本与最新更新。**

## 在原版基础上做了哪些改动

### 1. 界面全面中文化

将托盘菜单、气泡通知、启动画面、各类弹窗的用户可见文本全部替换为简体中文，包括：

- 托盘右键菜单（保存窗口布局、恢复窗口布局、暂停自动恢复等）
- 气泡通知（"快照 '0' 已保存"、"正在恢复窗口布局，请稍候"等）
- 启动画面、单实例提示、快照命名对话框等

> 注意：为使菜单状态切换逻辑与中文菜单文字匹配，同步修改了 `SystrayForm.cs` 中 4 处以菜单文字内容作为状态判断的 `Contains(...)` 条件。全部文本替换对照见仓库根目录的 `translate.pl`（它同时就是一个可重放的翻译脚本，上游出新版本后可对新代码重跑一次再编译）。

### 2. 数据存储位置固定为程序目录（真正的便携化）

原版默认把窗口位置数据写到 `C:\Users\<用户名>\AppData\Local\PersistentWindows`，只有带 `-portable_mode` 参数启动才存到程序目录。

本版本修改了 `SystrayShell/Program.cs` 中的默认值：**无论是否带参数、从哪里启动，数据永远存放在 exe 所在目录的 `user_data` 子文件夹**。整个文件夹拷贝到任何位置（包括其他电脑）都可以直接使用，不产生任何 C 盘数据。

### 3. 附带"一键拉回离屏窗口"应急脚本

串流虚拟屏断开后，个别程序的窗口（如微信）会滞留在已消失的虚拟屏坐标上，连 PersistentWindows 的自动恢复也可能漏掉。`拉回离屏窗口.ps1`（配套 bat 启动器）会枚举所有完全跑出可见屏幕范围的窗口并拉回，弹窗报告结果。此脚本为本仓库新增，与上游无关。

## 编译方法

环境要求：Windows 10/11 + [.NET SDK 8](https://dotnet.microsoft.com/download/dotnet/8.0)。

```powershell
cd Ninjacrab.PersistentWindows.Solution/Common
dotnet build Common.net48.csproj -c Release

cd ../SystrayShell
dotnet build SystrayShell.net48.csproj -c Release
```

产物在 `SystrayShell/bin/Release/net48/` 下，连同 `LiteDB.dll`、`PersistentWindows.Common.dll` 及若干 `System.*.dll` 一起部署即可（Release 页面提供打包好的版本）。

> 说明：上游使用老式 .NET Framework 4.5 项目格式，需要完整版 VS/MSBuild 才能编译。本仓库在 `Common/` 和 `SystrayShell/` 下各新增了一个 SDK 风格的 `.net48.csproj`（不动上游原项目文件），用 .NET SDK 8 即可独立编译，图片资源通过 `System.Resources.Extensions` 预序列化方案处理。

## 使用说明

1. 双击 `PersistentWindows.exe` 启动，程序常驻系统托盘；
2. 开机自启：以管理员身份运行 `Ninjacrab.PersistentWindows.Solution/auto_start_pw.bat`（注册计划任务，无需任何参数）；
3. 窗口跑丢时：运行仓库根目录的 `拉回离屏窗口.bat`；
4. 所有数据保存在程序目录的 `user_data` 文件夹内，删除该文件夹即恢复出厂状态。

## 鸣谢

- 原项目：https://github.com/kangyu-california/PersistentWindows
- 上游英文说明文档：见 [README-upstream.md](README-upstream.md) 与 [Help.md](Help.md)
- 感谢原作者 Min Yong Kim 与维护者 Kang Yu
