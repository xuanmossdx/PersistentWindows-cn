#!/usr/bin/perl
# Translate PersistentWindows UI strings to Simplified Chinese (byte-level, UTF-8 safe)
use strict; use warnings;
foreach my $file (@ARGV) {
    open my $in, '<:raw', $file or die "cannot open $file: $!";
    local $/; my $c = <$in>; close $in;
    my $orig = $c;

    if ($file =~ /Program\.cs$/) {
        $c =~ s/snapshot '\{c\}' is captured/快照 '{c}' 已保存/;
        $c =~ s/click icon then immediately press key '\{c\}' to restore the snapshot/点击图标后立即按数字键 '{c}' 即可恢复该快照/;
    }
    elsif ($file =~ /HotKey\.cs$/) {
        $c =~ s/"webpage commander is invoked via hotkey"/"已通过热键呼出网页控制窗口"/g;
        $c =~ s/"Press the hotkey \(Alt \+ W\) again to revoke"/"再按一次热键 (Alt + W) 即可收回"/g;
    }
    elsif ($file =~ /SystrayForm\.Designer\.cs$/) {
        $c =~ s/"Capture windows to disk"/"保存窗口布局(&C)"/;
        $c =~ s/"Restore windows from disk"/"恢复窗口布局(&R)"/;
        $c =~ s/"Restore all minimized windows"/"展开所有最小化的窗口"/;
        $c =~ s/"Capture snapshot"/"捕捉布局快照(&S)"/;
        $c =~ s/"Restore snapshot"/"恢复布局快照(&N)"/;
        $c =~ s/"Pause auto restore"/"暂停自动恢复(&P)"/;
        $c =~ s/"Try customized icon"/"尝试自定义图标"/;
        $c =~ s/"Disable webpage commander"/"停用网页控制窗口"/;
        $c =~ s/"&Help"/"帮助(&H)"/;
        $c =~ s/"&Exit"/"退出(&X)"/;
        $c =~ s/"Please wait while restoring windows"/"正在恢复窗口布局，请稍候"/;
    }
    elsif ($file =~ /SystrayForm\.cs$/) {
        $c =~ s/"Enable upgrade notice"/"启用升级提醒"/g;
        $c =~ s/"Disable upgrade notice"/"关闭升级提醒"/g;
        $c =~ s/"Enable webpage commander"/"启用网页控制窗口"/g;
        $c =~ s/"Disable webpage commander"/"停用网页控制窗口"/g;
        $c =~ s/"Pause auto restore"/"暂停自动恢复(&P)"/;
        $c =~ s/"Resume auto restore"/"继续自动恢复"/;
        $c =~ s/"Try customized icon"/"尝试自定义图标"/;
        $c =~ s/"Disable customized icon"/"停用自定义图标"/;
        $c =~ s/upgrade is available"/有新版本可用"/;
        $c =~ s/"The upgrade notice can be disabled in menu"/"可在菜单中关闭升级提醒"/;
        $c =~ s/\$"Upgrade to \{latestVersion\}"/\$"升级到 {latestVersion}"/;
        # menu-state logic must match the Chinese text
        $c =~ s/upgradeNoticeMenuItem\.Text\.Contains\("Disable"\)/upgradeNoticeMenuItem.Text.Contains("关闭")/;
        $c =~ s/invokeWebCommander\.Text\.Contains\("Disable"\)/invokeWebCommander.Text.Contains("停用")/;
        $c =~ s/upgradeNoticeMenuItem\.Text\.Contains\("Upgrade to"\)/upgradeNoticeMenuItem.Text.Contains("升级到")/;
        $c =~ s/upgradeNoticeMenuItem\.Text\.Contains\("Enable"\)/upgradeNoticeMenuItem.Text.Contains("启用")/;
    }
    elsif ($file =~ /SplashForm\.Designer\.cs$/) {
        $c =~ s/"info"/"关于"/;
        $c =~ s/"Recognize All Contributors"/"致谢所有贡献者"/;
    }
    elsif ($file =~ /SplashForm\.cs$/) {
        $c =~ s/Author:/作者:/;
        $c =~ s/Contributors:/贡献者:/;
    }
    elsif ($file =~ /PersistentWindowProcessor\.cs$/) {
        $c =~ s/"Another instance is already running\."/"程序已经在运行中。"/;
        $c =~ s/"Proceed to restore windows"/"即将恢复窗口布局"/;
        $c =~ s/"Switch to another virtual desktop to restore windows"/"请切换到其他虚拟桌面后再恢复窗口"/;
    }
    elsif ($file =~ /HotKeyWindow\.cs$/) {
        $c =~ s/You may also press Z key to toggle the size of webpage commander window/也可以按 Z 键来调整网页控制窗口的大小/;
    }
    elsif ($file =~ /HotKeyWindow\.Designer\.cs$/) {
        $c =~ s/"Prev Tab"/"上一个标签"/;
        $c =~ s/"Next Tab"/"下一个标签"/;
        $c =~ s/"Close Tab"/"关闭标签"/;
        $c =~ s/"New  Tab"/"新建标签"/;
        $c =~ s/"Home"/"主页"/;
        $c =~ s/"End"/"末页"/;
        $c =~ s/"Prev Url"/"上一个网址"/;
        $c =~ s/"Next Url"/"下一个网址"/;
    }
    elsif ($file =~ /DbKeySelect\.Designer\.cs$/) {
        $c =~ s/\.Text = "OK"/.Text = "确定"/;
        $c =~ s/\.Text = "Cancel"/.Text = "取消"/;
        $c =~ s/"Select a desktop layout to restore"/"请选择要恢复的桌面布局"/;
    }
    elsif ($file =~ /LayoutProfile\.Designer\.cs$/) {
        $c =~ s/"Enter one digit or a letter to name the snapshot"/"输入一个数字或字母作为快照名称"/;
        $c =~ s/"Enter the name of snapshot"/"请输入快照名称"/;
    }
    elsif ($file =~ /NameDbKey\.Designer\.cs$/) {
        $c =~ s/\.Text = "OK"/.Text = "确定"/;
        $c =~ s/"Enter the name of capture on disk"/"请输入磁盘布局存档名称"/;
        $c =~ s/"Enter the name of capture"/"请输入布局存档名称"/;
    }

    if ($c ne $orig) {
        open my $out, '>:raw', $file or die "cannot write $file: $!";
        print $out $c; close $out;
        print "updated: $file\n";
    } else {
        print "NO CHANGE: $file\n";
    }
}
