# PersistentWindows-cn

PersistentWindows 的中文增强版。基于 [kangyu-california/PersistentWindows](https://github.com/kangyu-california/PersistentWindows) 5.76 修改，遵循其 GPL-3.0 许可证开源。

**它是什么：** 一款 Windows 窗口位置记忆与恢复工具。Windows 有个老毛病——显示器配置一变（休眠唤醒、接拔显示器、远程桌面重连、虚拟屏断开），所有窗口的位置就乱套：有的跑出屏幕外、有的挤在一块、有的干脆"消失"。PersistentWindows 在后台实时记住每个窗口的位置，一旦显示器配置发生变化，自动把整个桌面布局（包括任务栏位置）恢复成你上次调好的样子。

## 功能特性

- **窗口位置自动记忆**：实时跟踪每个窗口的位置和大小变化，随时保存最新布局
- **按显示器配置分别记忆**：单屏、双屏、三屏各记一套布局，接回哪套显示器就恢复哪套，互不干扰
- **显示器变化自动恢复**：休眠唤醒、分辨率改变、远程会话重连、虚拟屏（串流）断开重连等场景自动触发恢复
- **离屏窗口自动纠正**：窗口跑到屏幕可见范围外时自动拉回
- **恢复时重启程序**：可以连被捕捉的程序本身一起重新启动（路径含中文也支持，见下方修改说明）
- **布局快照**：手动保存/恢复多个命名布局，一键切换不同工作场景
- **任务栏位置恢复**：连任务栏在哪个屏、什么状态都一起恢复
- **丰富的命令行参数**：可定制恢复延迟、匹配阈值、进程过滤等行为，详见 [Help.md](Help.md)

**典型场景：** 笔记本外接显示器经常拔插、KVM 切换器多机共用、用 Parsec/ToDesk/UU 远程等工具的虚拟屏串流（断开重连后窗口不再跑丢）、远程办公 RDP 重连。

## 下载与使用

前往 [Releases](https://github.com/xuanmossdx/PersistentWindows-cn/releases) 下载打包好的版本，解压到任意文件夹：

1. 双击 `PersistentWindows.exe` 启动，程序常驻系统托盘（右下角），右键托盘图标操作
2. 所有数据保存在程序目录的 `user_data` 子文件夹内，删除即恢复出厂状态，整个文件夹拷到别的电脑也能直接用
3. 开机自启：以管理员身份运行 `Ninjacrab.PersistentWindows.Solution/auto_start_pw.bat`
4. 窗口"消失"时：运行根目录的 `拉回离屏窗口.bat`，一键把所有跑出屏幕的窗口拉回来

## 相比上游的修改

本版本在上游 5.76 基础上做了以下修改（详细原理见仓库提交记录）：

### 1. 中英双语界面，翻译外置文件，托盘菜单一键切换

全部用户可见文本（托盘菜单、气泡通知、启动画面、各类弹窗，约 45 组词条）存放在**一个独立的外部文件**里：程序目录下 `user_data\translations.json`，每个词条一张"语言名 → 文本"的表，一种语言一行：

```json
"menu.captureDisk": {
  "en": "Capture windows to disk",
  "zh": "保存窗口布局(&C)"
}
```

- 代码中只引用词条 ID：`Lang.T("menu.captureDisk")`，**所有翻译与代码彻底分离**
- **改措辞、加词条、加语言**（如 `"jp": "..."`）全部只需编辑这个 JSON 文件并重启程序，**无需重新编译**；语言缺失自动回退英文；带 `{0}` 占位符的词条支持参数格式化
- **默认英文**，与上游行为完全一致；右键托盘图标 → **语言 / Language** 点击**立即切换**（无需重启），选择持久化保存在 `user_data/lang.txt`
- **容错**：文件被误改/误删时自动回退内置默认值或重新生成，程序永不因翻译文件问题崩溃
- 顺带重构了 `SystrayForm.cs` 中 4 处"用菜单文字内容判断状态"的 `Contains(...)` 逻辑，改为真正的状态变量（这是任何本地化的前置条件，也是一处代码质量改进）

### 2. 数据存储位置固定为程序目录（真正的便携化）

原版默认把数据写到 `C:\Users\<用户名>\AppData\Local\PersistentWindows`，只有带 `-portable_mode` 参数启动才存到程序目录。本版本修改了 `SystrayShell/Program.cs` 中的默认值：**无论是否带参数、从哪里启动，数据永远存放在 exe 所在目录的 `user_data` 子文件夹**。

### 3. 附带"一键拉回离屏窗口"应急脚本

串流虚拟屏断开后，个别程序的窗口（如微信）会滞留在已消失的虚拟屏坐标上，自动恢复也可能漏掉。`拉回离屏窗口.ps1`（配套 bat 启动器）会枚举所有完全跑出可见屏幕范围的窗口并拉回，弹窗报告结果。此脚本为本仓库新增，与上游无关。

### 4. 修复"恢复布局时重启程序"的中文路径乱码问题

上游 issue：[#428 "Please support Chinese"](https://github.com/kangyu-california/PersistentWindows/issues/428)——恢复布局时重启被捕捉的程序，PW 会把启动命令写入 `pw_exec*.bat` 再执行。`File.WriteAllText` 默认以 UTF-8 无 BOM 编码写文件，而 cmd.exe 按系统 ANSI 代码页（中文系统为 GBK）读取 bat，导致中文路径变成乱码、程序无法启动。

上游给出的方案是让用户在系统区域设置中勾选"Beta: 使用 Unicode UTF-8"，属于全局开关，可能影响其他老旧非 Unicode 程序。

本版本将所有 bat 生成点的 `File.WriteAllText` 统一改为 **`Encoding.Default`** 按系统 ANSI 代码页写入（共 6 处：`pw_exec*.bat` 4 处、`pw_restart.bat`、`pw_upgrade.bat`），cmd 按什么读就按什么写——任何语言的 Windows、无论是否开启 UTF-8 Beta 均正常工作，用户无需更改任何系统设置。已实测验证：中文 Windows 上 PowerShell 捕捉管线输出编码与 .NET 默认解码一致，捕捉阶段中文路径无乱码，问题根源确实仅在 bat 写入环节。

### 5. 禁用自动升级检查（版本钉死）

中文版基于上游 5.76 修改，如果跟随上游自动升级会覆盖全部汉化和便携化改动。因此本版本**短路了升级检查逻辑**（不再访问 GitHub 查询新版本、不再自动下载升级包），并隐藏了托盘菜单中的升级提醒入口。本版本将稳定在 5.76-cn，直至主动更新。

## 编译方法

环境要求：Windows 10/11 + [.NET SDK 8](https://dotnet.microsoft.com/download/dotnet/8.0)。

```powershell
cd Ninjacrab.PersistentWindows.Solution/Common
dotnet build Common.net48.csproj -c Release

cd ../SystrayShell
dotnet build SystrayShell.net48.csproj -c Release
```

产物在 `SystrayShell/bin/Release/net48/` 下，连同 `LiteDB.dll`、`PersistentWindows.Common.dll` 及若干 `System.*.dll` 一起部署即可（Releases 页面提供打包好的版本）。

> 说明：上游使用老式 .NET Framework 4.5 项目格式，需要完整版 VS/MSBuild 才能编译。本仓库在 `Common/` 和 `SystrayShell/` 下各新增了一个 SDK 风格的 `.net48.csproj`（不动上游原项目文件），用 .NET SDK 8 即可独立编译，图片资源通过 `System.Resources.Extensions` 预序列化方案处理。

## 鸣谢与许可

- 原项目：https://github.com/kangyu-california/PersistentWindows （原作者 Min Yong Kim，维护者 Kang Yu）
- 上游英文说明文档：见 [README-upstream.md](README-upstream.md) 与 [Help.md](Help.md)
- 本仓库遵循上游的 **GPL-3.0** 许可证开源，感谢原作者与社区贡献者
