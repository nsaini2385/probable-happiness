<#
.SYNOPSIS
    Custom WPF progress window - no title bar branding, no app info row.
    Launched as a hidden background process to avoid black console popup.
    Progress bar shows real percentage based on log scraping + time creep.
#>

function Show-ProgressWindow {
    param(
        [string]$StatusMessage = 'Microsoft Office 365 Installation in Progress... This may take up to 25 minutes to complete.'
    )

    $tempScript = "$env:TEMP\PSADT_Progress_$PID.ps1"

    $scriptContent = @"
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

`$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Installation"
    Width="500" SizeToContent="Height"
    ResizeMode="NoResize"
    WindowStyle="None"
    WindowStartupLocation="CenterScreen"
    Background="#FF007ACC"
    SnapsToDevicePixels="True"
    Topmost="False"
    ShowInTaskbar="True"
    MaxWidth="550"
    AllowsTransparency="False">

    <Window.Resources>
        <Style TargetType="ProgressBar">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ProgressBar">
                        <Border BorderBrush="#003366" BorderThickness="1" CornerRadius="3" Background="#E0E0E0">
                            <Grid>
                                <Rectangle x:Name="PART_Track"/>
                                <Rectangle x:Name="PART_Indicator" Fill="#0078D4" HorizontalAlignment="Left"/>
                            </Grid>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border BorderBrush="#003366" BorderThickness="1">
        <DockPanel Background="White">
            <StackPanel DockPanel.Dock="Top">

                <!-- Header -->
                <Grid MinHeight="52" Background="#003366">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="56"/>
                        <ColumnDefinition/>
                    </Grid.ColumnDefinitions>
                    <Image Grid.Column="0"
                           Source="$($PSScriptRoot -replace '\\','/')/Assets/AppIcon.png"
                           Width="32" Height="32"
                           HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="0,0,12,0">
                        <TextBlock Text="Microsoft Office 365"
                                   Foreground="White" FontSize="15" FontWeight="SemiBold"/>
                        <TextBlock Text="Installation in progress — please do not turn off your device"
                                   Foreground="#AACCEE" FontSize="10" Margin="0,2,0,0"
                                   TextWrapping="Wrap"/>
                    </StackPanel>
                </Grid>

                <!-- Divider -->
                <Rectangle Height="1" Fill="#003366"/>

                <!-- Status message -->
                <StackPanel Background="White" Margin="20,16,20,8">
                    <TextBlock
                        Text="$StatusMessage"
                        TextWrapping="Wrap"
                        FontSize="13"
                        Foreground="#1A1A1A"
                        LineHeight="20"/>
                </StackPanel>

                <!-- Phase label -->
                <TextBlock x:Name="PhaseText"
                           Text="Preparing installation..."
                           Margin="20,4,20,6"
                           FontSize="11"
                           Foreground="#0078D4"
                           FontWeight="SemiBold"/>

                <!-- Progress bar + percentage -->
                <Grid Margin="20,0,20,4">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition/>
                        <ColumnDefinition Width="44"/>
                    </Grid.ColumnDefinitions>
                    <ProgressBar x:Name="ProgressBar"
                                 Grid.Column="0"
                                 Minimum="0" Maximum="100" Value="0"
                                 Height="22"
                                 Margin="0,0,8,0"/>
                    <TextBlock x:Name="PctText"
                               Grid.Column="1"
                               Text="0%"
                               FontSize="12"
                               FontWeight="SemiBold"
                               Foreground="#003366"
                               VerticalAlignment="Center"
                               HorizontalAlignment="Right"/>
                </Grid>

                <!-- Elapsed time -->
                <TextBlock x:Name="ElapsedText"
                           Text="Elapsed: 0:00"
                           Margin="20,6,20,4"
                           FontSize="10"
                           Foreground="#888888"/>

                <!-- Footer -->
                <TextBlock
                    Text="This window will close automatically when the installation is complete."
                    HorizontalAlignment="Center"
                    Foreground="#666666"
                    FontSize="11"
                    Margin="20,4,20,16"
                    TextWrapping="Wrap"
                    TextAlignment="Center"/>

            </StackPanel>
        </DockPanel>
    </Border>
</Window>
'@

`$reader      = [System.Xml.XmlReader]::Create([System.IO.StringReader]`$xaml)
`$window      = [System.Windows.Markup.XamlReader]::Load(`$reader)

`$progressBar = `$window.FindName('ProgressBar')
`$pctText     = `$window.FindName('PctText')
`$phaseText   = `$window.FindName('PhaseText')
`$elapsedText = `$window.FindName('ElapsedText')

`$startTime   = Get-Date
`$script:lastPct = 0

# Scrape Office setup log for real progress keywords
function Get-OfficeInstallProgress {
    `$logFile = `$null

    # Search both TEMP locations
    foreach (`$dir in @(`$env:TEMP, 'C:\Windows\Temp')) {
        `$found = Get-ChildItem -Path `$dir -Filter '*.log' -ErrorAction SilentlyContinue |
                  Where-Object { `$_.Name -match 'Office|M365|C2R|OfficeSetup|Setup' } |
                  Sort-Object LastWriteTime -Descending |
                  Select-Object -First 1
        if (`$found) { `$logFile = `$found; break }
    }

    if (-not `$logFile) { return `$null }

    try {
        `$fs      = [System.IO.FileStream]::new(`$logFile.FullName,
                    [System.IO.FileMode]::Open,
                    [System.IO.FileAccess]::Read,
                    [System.IO.FileShare]::ReadWrite)
        `$sr      = [System.IO.StreamReader]::new(`$fs)
        `$content = `$sr.ReadToEnd()
        `$sr.Close(); `$fs.Close()
    } catch { return `$null }

    `$stages = [ordered]@{
        95 = @('installation successful','install succeeded','setup completed','office was installed')
        88 = @('applying updates','finalizing','post-install','registration')
        78 = @('installing office','installing product','running bootstrapper','applying package')
        65 = @('extracting','unpacking','decompressing')
        50 = @('download complete','all files downloaded','download succeeded')
        35 = @('downloading','transferring','fetching')
        20 = @('initializing','validating','checking prerequisites','preparing')
        10 = @('starting','beginning','launched','started setup')
    }

    `$lower = `$content.ToLower()
    foreach (`$pct in `$stages.Keys) {
        foreach (`$keyword in `$stages[`$pct]) {
            if (`$lower.Contains(`$keyword)) { return `$pct }
        }
    }
    return 5
}

function Get-PhaseLabel {
    param([int]`$Pct)
    if     (`$Pct -lt 10) { 'Preparing installation...' }
    elseif (`$Pct -lt 20) { 'Starting setup engine...' }
    elseif (`$Pct -lt 35) { 'Initializing components...' }
    elseif (`$Pct -lt 50) { 'Downloading Office files...' }
    elseif (`$Pct -lt 65) { 'Download complete — preparing files...' }
    elseif (`$Pct -lt 78) { 'Extracting and preparing...' }
    elseif (`$Pct -lt 88) { 'Installing Office components...' }
    elseif (`$Pct -lt 95) { 'Applying updates and finalizing...' }
    else                   { 'Completing installation...' }
}

# Draggable
`$window.Add_MouseLeftButtonDown({ `$window.DragMove() })

# Timer polls every 3 seconds
`$timer          = [System.Windows.Threading.DispatcherTimer]::new()
`$timer.Interval = [TimeSpan]::FromSeconds(3)

`$timer.Add_Tick({
    # Elapsed
    `$elapsed = (Get-Date) - `$startTime
    `$elapsedText.Text = 'Elapsed: ' + ('{0}:{1:00}' -f [int]`$elapsed.TotalMinutes, `$elapsed.Seconds)

    # Log-based progress
    `$logPct = Get-OfficeInstallProgress
    if (`$logPct -and `$logPct -gt `$script:lastPct) {
        `$script:lastPct = `$logPct
    } else {
        # Time-based creep — crawls to max 90% over 25 min so bar always moves
        `$timePct = [math]::Min(90, [int](`$elapsed.TotalMinutes / 25 * 90))
        if (`$timePct -gt `$script:lastPct) {
            `$script:lastPct = `$timePct
        }
    }

    `$progressBar.Value = `$script:lastPct
    `$pctText.Text      = "`$(`$script:lastPct)%"
    `$phaseText.Text    = Get-PhaseLabel -Pct `$script:lastPct
})

`$timer.Start()
`$window.ShowDialog() | Out-Null
`$timer.Stop()
"@

    $scriptContent | Out-File -FilePath $tempScript -Encoding UTF8 -Force

    $script:ProgressProcess = Start-Process `
        -FilePath     'powershell.exe' `
        -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -File `"$tempScript`"" `
        -WindowStyle  Hidden `
        -PassThru
}


function Close-ProgressWindow {
    if ($script:ProgressProcess -and -not $script:ProgressProcess.HasExited) {
        $script:ProgressProcess.Kill()
        $script:ProgressProcess = $null
    }
    Remove-Item "$env:TEMP\PSADT_Progress_$PID.ps1" -Force -ErrorAction SilentlyContinue
}