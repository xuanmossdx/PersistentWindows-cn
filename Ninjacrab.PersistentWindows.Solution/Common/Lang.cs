using System;
using System.Collections.Generic;
using System.IO;

namespace PersistentWindows.Common
{
    /// <summary>
    /// Central translation table for the cn fork.
    ///
    /// Every user-visible string has a key; each key maps to one row of per-language
    /// text. Column 0 is English (the default/fallback), column 1 is Simplified
    /// Chinese. Call sites only reference the key:
    ///
    ///     Lang.T("menu.captureDisk")
    ///     Lang.T("balloon.snapshotCaptured", id)   // rows may contain {0}-style placeholders
    ///
    /// Adding a new language = append one element to every row and extend
    /// LangIndex below. Adding a new feature string = add one row. No other
    /// code changes required.
    /// </summary>
    public static class Lang
    {
        /// <summary>active language column index; 0 = English</summary>
        public static int LangIndex = 0;

        public static string LangFile = null;

        // language columns: 0 = English (default), 1 = 简体中文
        public static readonly Dictionary<string, string[]> Strings = new Dictionary<string, string[]>
        {
            // tray menu
            { "menu.captureDisk",        new[] { "Capture windows to disk", "保存窗口布局(&C)" } },
            { "menu.restoreDisk",        new[] { "Restore windows from disk", "恢复窗口布局(&R)" } },
            { "menu.restoreMinimized",   new[] { "Restore all minimized windows", "展开所有最小化的窗口" } },
            { "menu.captureSnapshot",    new[] { "Capture snapshot", "捕捉布局快照(&S)" } },
            { "menu.restoreSnapshot",    new[] { "Restore snapshot", "恢复布局快照(&N)" } },
            { "menu.pauseAutoRestore",   new[] { "Pause auto restore", "暂停自动恢复(&P)" } },
            { "menu.resumeAutoRestore",  new[] { "Resume auto restore", "继续自动恢复" } },
            { "menu.tryCustomIcon",      new[] { "Try customized icon", "尝试自定义图标" } },
            { "menu.disableCustomIcon",  new[] { "Disable customized icon", "停用自定义图标" } },
            { "menu.enableWebCommander", new[] { "Enable webpage commander", "启用网页控制窗口" } },
            { "menu.disableWebCommander",new[] { "Disable webpage commander", "停用网页控制窗口" } },
            { "menu.enableUpgradeNotice",new[] { "Enable upgrade notice", "启用升级提醒" } },
            { "menu.disableUpgradeNotice",new[] { "Disable upgrade notice", "关闭升级提醒" } },
            { "menu.upgradeTo",          new[] { "Upgrade to {0}", "升级到 {0}" } },
            { "menu.language",           new[] { "Language", "语言 / Language" } },
            { "menu.help",               new[] { "&Help", "帮助(&H)" } },
            { "menu.exit",               new[] { "&Exit", "退出(&X)" } },

            // balloon notifications
            { "balloon.restoring",          new[] { "Please wait while restoring windows", "正在恢复窗口布局，请稍候" } },
            { "balloon.languageSwitched",   new[] { "Language switched", "语言已切换" } },
            { "balloon.languageApplied",    new[] { "The interface language has been applied.", "界面语言已即时生效。" } },
            { "balloon.upgradeAvailable",   new[] { "{0} {1} upgrade is available", "{0} {1} 有新版本可用" } },
            { "balloon.upgradeNoticeHint",  new[] { "The upgrade notice can be disabled in menu", "可在菜单中关闭升级提醒" } },
            { "balloon.snapshotCaptured",   new[] { "snapshot '{0}' is captured", "快照 '{0}' 已保存" } },
            { "balloon.snapshotRestoreHint",new[] { "click icon then immediately press key '{0}' to restore the snapshot", "点击图标后立即按数字键 '{0}' 即可恢复该快照" } },
            { "balloon.webCommanderInvoked",new[] { "webpage commander is invoked via hotkey", "已通过热键呼出网页控制窗口" } },
            { "balloon.webCommanderRevoke", new[] { "Press the hotkey (Alt + W) again to revoke", "再按一次热键 (Alt + W) 即可收回" } },

            // message boxes
            { "msg.alreadyRunning",       new[] { "Another instance is already running.", "程序已经在运行中。" } },
            { "msg.proceedRestore",       new[] { "Proceed to restore windows", "即将恢复窗口布局" } },
            { "msg.switchVirtualDesktop", new[] { "Switch to another virtual desktop to restore windows", "请切换到其他虚拟桌面后再恢复窗口" } },
            { "msg.webCommanderZKey",     new[] { "You may also press Z key to toggle the size of webpage commander window", "也可以按 Z 键来调整网页控制窗口的大小" } },

            // splash screen
            { "splash.infoLabel",    new[] { "info", "关于" } },
            { "splash.info",         new[] { "\n    Persistent Windows\n    Version {0}\n                \n    Author:        Min Yong Kim\n    Contributors:  Kang Yu, Sean Aitken\n    ",
                                              "\n    Persistent Windows\n    版本 {0}\n                \n    作者:        Min Yong Kim\n    贡献者:  Kang Yu, Sean Aitken\n    " } },
            { "splash.contributors", new[] { "Recognize All Contributors", "致谢所有贡献者" } },

            // webpage commander window
            { "webcmd.prevTab",   new[] { "Prev Tab", "上一个标签" } },
            { "webcmd.nextTab",   new[] { "Next Tab", "下一个标签" } },
            { "webcmd.closeTab",  new[] { "Close Tab", "关闭标签" } },
            { "webcmd.newTab",    new[] { "New  Tab", "新建标签" } },
            { "webcmd.home",      new[] { "Home", "主页" } },
            { "webcmd.end",       new[] { "End", "末页" } },
            { "webcmd.prevUrl",   new[] { "Prev Url", "上一个网址" } },
            { "webcmd.nextUrl",   new[] { "Next Url", "下一个网址" } },

            // dialogs / message boxes with buttons
            { "dlg.ok",            new[] { "OK", "确定" } },
            { "dlg.cancel",        new[] { "Cancel", "取消" } },
            { "dlg.selectLayout",  new[] { "Select a desktop layout to restore", "请选择要恢复的桌面布局" } },
            { "dlg.snapshotDigitName", new[] { "Enter one digit or a letter to name the snapshot", "输入一个数字或字母作为快照名称" } },
            { "dlg.snapshotName",  new[] { "Enter the name of snapshot", "请输入快照名称" } },
            { "dlg.captureDiskName", new[] { "Enter the name of capture on disk", "请输入磁盘布局存档名称" } },
            { "dlg.captureName",   new[] { "Enter the name of capture", "请输入布局存档名称" } },
        };

        /// <summary>look up a row by key; args fill {0}-style placeholders when given</summary>
        public static string T(string key, params object[] args)
        {
            string[] row;
            string text = key;
            if (Strings.TryGetValue(key, out row))
            {
                text = LangIndex > 0 && LangIndex < row.Length ? row[LangIndex] : row[0];
            }
            if (args != null && args.Length > 0)
                text = string.Format(text, args);
            return text;
        }

        /// <summary>load the persisted language choice (called once at startup)</summary>
        public static void Load(string appDataFolder)
        {
            LangFile = Path.Combine(appDataFolder, "lang.txt");
            try
            {
                if (File.Exists(LangFile))
                {
                    string v = File.ReadAllText(LangFile).Trim();
                    LangIndex = v == "zh" ? 1 : 0;
                }
            }
            catch (Exception)
            {
                // fall back to English on any read problem
            }
        }

        /// <summary>switch language and persist the choice</summary>
        public static void Set(int index)
        {
            LangIndex = index;
            try
            {
                if (LangFile != null)
                    File.WriteAllText(LangFile, LangIndex == 1 ? "zh" : "en");
            }
            catch (Exception)
            {
                // preference not persisted; session still switches
            }
        }
    }
}
