Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WinPull {
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr lp);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lp);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder sb, int max);
    [DllImport("user32.dll")] public static extern int GetClassName(IntPtr hWnd, StringBuilder sb, int max);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);
    [DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr after, int X, int Y, int cx, int cy, uint flags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
}
"@
$processNames = @{}
Get-Process | ForEach-Object { $processNames[[uint32]$_.Id] = $_.ProcessName }

Add-Type -AssemblyName System.Windows.Forms
$vs = [System.Windows.Forms.SystemInformation]::VirtualScreen

$sbTitle = New-Object System.Text.StringBuilder 256
$sbClass = New-Object System.Text.StringBuilder 256
[uint32]$procId = 0
$log = New-Object System.Collections.ArrayList
$cb = [WinPull+EnumWindowsProc]{
    param($hWnd, $lp)
    if ([WinPull]::IsWindowVisible($hWnd)) {
        [WinPull]::GetWindowText($hWnd, $sbTitle, 256) | Out-Null
        [WinPull]::GetClassName($hWnd, $sbClass, 256) | Out-Null
        [WinPull]::GetWindowThreadProcessId($hWnd, [ref]$procId) | Out-Null
        $r = New-Object WinPull+RECT
        [WinPull]::GetWindowRect($hWnd, [ref]$r) | Out-Null
        $w = $r.Right - $r.Left; $h = $r.Bottom - $r.Top
        $style = [WinPull]::GetWindowLong($hWnd, -16)
        $exStyle = [WinPull]::GetWindowLong($hWnd, -20)
        $title = $sbTitle.ToString()
        # app window only: titled, has caption, not a small tool window
        if ($title.Length -gt 0 -and ($style -band 0x00C00000) -ne 0 -and ($exStyle -band 0x00000080) -eq 0 -and $w -gt 100) {
            $fullyOut = ($r.Right -le 0) -or ($r.Bottom -le 0) -or ($r.Left -ge $vs.Right) -or ($r.Top -ge $vs.Bottom)
            if ($fullyOut -and -not [WinPull]::IsIconic($hWnd)) {
                if ([WinPull]::IsIconic($hWnd)) { [WinPull]::ShowWindow($hWnd, 9) | Out-Null }
                $newX = [Math]::Min([Math]::Max(0, $r.Left), $vs.Right - $w)
                $newY = [Math]::Min([Math]::Max(0, $r.Top), $vs.Bottom - $h)
                [WinPull]::SetWindowPos($hWnd, [IntPtr]::Zero, $newX, $newY, 0, 0, 0x0001 -bor 0x0004 -bor 0x0040) | Out-Null
                $null = $log.Add(("'{0}' [{1}] ({2},{3}) -> ({4},{5})" -f $title, $processNames[$procId], $r.Left, $r.Top, $newX, $newY))
            }
        }
    }
    return $true
}
[WinPull]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
if ($log.Count -eq 0) {
    Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-Command',"Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('没有发现离屏窗口，一切正常。','拉回离屏窗口')"
} else {
    $msg = "已拉回 $($log.Count) 个离屏窗口：`r`n`r`n" + ($log -join "`r`n")
    Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-Command',"Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('$($msg.Replace("'","''"))','拉回离屏窗口')"
}
