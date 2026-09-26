# PersistentWindows-cn

PersistentWindows 的增强发行版，基于 [kangyu-california/PersistentWindows](https://github.com/kangyu-california/PersistentWindows) 5.76，遵循其 GPL-3.0 许可证开源。

**它是什么：** 一款 Windows 窗口位置记忆与恢复工具。Windows 有个老毛病——显示器配置一变（休眠唤醒、接拔显示器、远程桌面重连、虚拟屏断开），所有窗口的位置就乱套：有的跑出屏幕外、有的挤在一块、有的干脆"消失"。PersistentWindows 在后台实时记住每个窗口的位置，一旦显示器配置发生变化，自动把整个桌面布局（包括任务栏位置）恢复成你上次调好的样子。

本版本在上游全部功能之上，为中文用户和便携使用场景做了增强：中英双语界面、翻译外置可编辑、数据完全便携、中文路径完整支持。

## 功能特性

- **窗口位置自动记忆**：实时跟踪每个窗口的位置和大小变化，随时保存最新布局
- **按显示器配置分别记忆**：单屏、双屏、三屏各记一套布局，接回哪套显示器就恢复哪套，互不干扰
- **显示器变化自动恢复**：休眠唤醒、分辨率改变、远程会话重连、虚拟屏（串流）断开重连等场景自动触发恢复
- **离屏窗口自动纠正**：窗口跑到屏幕可见范围外时自动拉回
- **恢复时重启程序**：可以连被捕捉的程序本身一起重新启动（路径含中文也支持）
- **布局快照**：手动保存/恢复多个命名布局，一键切换不同工作场景
- **任务栏位置恢复**：连任务栏在哪个屏、什么状态都一起恢复
- **多语言界面**：内置英文与简体中文，托盘菜单一键切换、即时生效；翻译外置为可编辑文件，改措辞、加语言无需重新编译
- **完全便携**：所有数据保存在程序目录内，整个文件夹拷到其他电脑直接能用
- **丰富的命令行参数**：可定制恢复延迟、匹配阈值、进程过滤等行为，详见 [Help.md](Help.md)

**典型场景：** 笔记本外接显示器经常拔插、KVM 切换器多机共用、用 Parsec/ToDesk/UU 远程等工具的虚拟屏串流（断开重连后窗口不再跑丢）、远程办公 RDP 重连。

## 下载与使用

前往 [Releases](https://github.com/xuanmossdx/PersistentWindows-cn/releases) 下载打包好的版本，解压到任意文件夹：

1. 双击 `PersistentWindows.exe` 启动，程序常驻系统托盘（右下角），右键托盘图标操作
2. **切换语言**：右键托盘图标 → **语言 / Language**，立即生效；选择保存在 `user_data/lang.txt`
3. **自定义翻译**：编辑 `user_data/translations.json`（见下），保存后重启程序生效
4. **开机自启**：以管理员身份运行 `Ninjacrab.PersistentWindows.Solution/auto_start_pw.bat`
5. **窗口"消失"时**：运行根目录的 `拉回离屏窗口.bat`，一键把所有跑出屏幕的窗口拉回来

### 翻译文件 translations.json

所有界面文字都存放在 `user_data/translations.json`，每个词条一张"语言名 → 文本"的表，一种语言一行：

```json
"menu.captureDisk": {
  "en": "Capture windows to disk",
  "zh": "保存窗口布局(&C)"
}
```

- 代码只按词条 ID 取值（`Lang.T("menu.captureDisk")`），**所有翻译与代码分离**——改措辞、加词条、加语言（如 `"jp": "..."`）都只需编辑这个文件并重启程序，无需重新编译
- 带 `{0}` 占位符的词条支持参数格式化（如 `"Upgrade to {0}"`）
- 某语言缺失的词条自动回退英文；文件损坏或丢失时自动回退内置默认值或重新生成，程序不会因此出错

## 与上游的主要差异

- **多语言界面 + 翻译外置文件**（如上）
- **数据便携化**：窗口位置、快照、设置、翻译文件等全部保存在程序目录的 `user_data` 子文件夹，AppData 零写入；老版本升级时 AppData 数据自动迁移
- **中文路径修复**：恢复布局时重启程序所生成的 bat 文件按系统 ANSI 编码写入（上游 issue [#428](https://github.com/kangyu-california/PersistentWindows/issues/428)），中文路径不再乱码，无需开启系统"UTF-8 Beta"选项
- **内置应急脚本**：`拉回离屏窗口.bat` 一键拉回所有跑出屏幕的窗口
- **版本固定**：基于上游 5.76，不跟随上游自动更新

## 从源码编译

环境要求：Windows 10/11 + [.NET SDK 8](https://dotnet.microsoft.com/download/dotnet/8.0)。

```powershell
cd Ninjacrab.PersistentWindows.Solution/Common
dotnet build Common.net48.csproj -c Release

cd ../SystrayShell
dotnet build SystrayShell.net48.csproj -c Release
```

产物在 `SystrayShell/bin/Release/net48/` 下，连同 `LiteDB.dll`、`PersistentWindows.Common.dll` 及若干 `System.*.dll` 一起部署即可（Releases 页面提供打包好的版本）。

> 说明：上游使用老式 .NET Framework 项目格式（VS/MSBuild 编译，项目文件未改动，翻译机制所需的 `System.Web.Extensions` 引用已加入）。本仓库另附两个 SDK 风格的 `.net48.csproj`（不影响上游项目文件），方便用 .NET SDK 8 直接编译；图片资源通过 `System.Resources.Extensions` 预序列化方案处理。

## 鸣谢与许可

- 原项目：https://github.com/kangyu-california/PersistentWindows （原作者 Min Yong Kim，维护者 Kang Yu）
- 上游英文说明文档：见 [README-upstream.md](README-upstream.md) 与 [Help.md](Help.md)
- 本仓库遵循上游的 **GPL-3.0** 许可证开源，感谢原作者与社区贡献者
