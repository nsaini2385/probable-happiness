<#
.SYNOPSIS
    Live-polling deferral prompt with time picker.
    Time slots capped to 4.5 hours max, and shrink as deferrals are consumed.
    Scheduling a time slot consumes a deferral.
    Scheduling beyond remaining deferrals x 1hr consumes ALL remaining deferrals.
    Registry DeferUntil keeps Intune from retrying during snooze.
    Script exits immediately after deferral - NO sleep loop - Intune safe.
#>
function Show-DeferralPrompt {
    param(
        [string]$AppName      = 'Microsoft Office 365',
        [int]$MaxDeferCount   = 4,
        [int]$SnoozeDuration  = 60,
        [int]$MaxDeferHours   = 4,
        [string[]]$CloseApps  = @('WINWORD','EXCEL','OUTLOOK','POWERPNT','ONENOTE','WINPROJ','VISIO','TEAMS','GROOVE')
    )

    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

    $AppKey    = 'Microsoft_Office365_x64_EN_003'
    $regPath   = "HKLM:\SOFTWARE\PSADT_Deferrals\$AppKey"
    $errorIcon = Join-Path -Path $PSScriptRoot -ChildPath 'Error.png'

    # Check active defer window - if still active exit silently
    if (Test-Path $regPath) {
        $deferUntilStr = (Get-ItemProperty -Path $regPath -Name 'DeferUntil' -ErrorAction SilentlyContinue).DeferUntil
        if ($deferUntilStr) {
            try {
                $deferUntil = [DateTime]::Parse($deferUntilStr)
                if ((Get-Date) -lt $deferUntil) {
                    $remaining = [math]::Round(($deferUntil - (Get-Date)).TotalMinutes)
                    Write-ADTLogEntry -Message "Active defer window. $remaining min remaining. Exiting silently." -Source 'Show-DeferralPrompt'
                    return -1
                } else {
                    Remove-ItemProperty -Path $regPath -Name 'DeferUntil' -ErrorAction SilentlyContinue
                }
            } catch {}
        }
    }

    $maxDeferWindowMins = 270  # 4.5 hours total hard cap

    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }

    $startTimeStr = (Get-ItemProperty -Path $regPath -Name 'ScriptStartTime' -ErrorAction SilentlyContinue).ScriptStartTime
    if ($startTimeStr) {
        try {
            $previousStart = [DateTime]::Parse($startTimeStr)
            $isStale  = $previousStart.Date -lt (Get-Date).Date
            $isTooOld = $previousStart -lt (Get-Date).AddHours(-5)
            if ($isStale -or $isTooOld) {
                Write-ADTLogEntry -Message "Stale defer registry from $previousStart - clearing." -Source 'Show-DeferralPrompt'
                Remove-Item -Path $regPath -Force -ErrorAction SilentlyContinue
                New-Item -Path $regPath -Force | Out-Null
                $startTimeStr = $null
            }
        } catch { $startTimeStr = $null }
    }
    if (-not $startTimeStr) {
        $startTimeStr = (Get-Date).ToString('o')
        Set-ItemProperty -Path $regPath -Name 'ScriptStartTime' -Value $startTimeStr -Force
    }
    $scriptStartTime = [DateTime]::Parse($startTimeStr)

    # Read defer count
    $deferCount = 0
    try {
        if (Test-Path $regPath) {
            $val = (Get-ItemProperty -Path $regPath -Name 'DeferCount' -ErrorAction SilentlyContinue).DeferCount
            if ($val) { $deferCount = [int]$val }
        }
    } catch {}

    function Get-TimeSlots {
        param([int]$DefersRemaining)
        $slots     = [System.Collections.Generic.List[string]]::new()
        $now       = Get-Date
        $hardEnd   = $scriptStartTime.AddMinutes($maxDeferWindowMins)
        $softHours = [math]::Min($DefersRemaining, $MaxDeferHours)
        $softEnd   = $now.AddHours($softHours)
        $windowEnd = if ($softEnd -lt $hardEnd) { $softEnd } else { $hardEnd }
        if (($windowEnd - $now).TotalMinutes -lt 30) { return $slots }
        $start = $now.AddMinutes(30 - ($now.Minute % 30)).AddSeconds(-$now.Second)
        $cur   = $start
        while ($cur -le $windowEnd) {
            $slots.Add($cur.ToString('h:mm tt'))
            $cur = $cur.AddMinutes(30)
        }
        return $slots
    }

    function Get-RunningOfficeApps {
        $found = [System.Collections.Generic.List[string]]::new()
        foreach ($app in $CloseApps) {
            if (Get-Process -Name $app -ErrorAction SilentlyContinue) {
                $name = switch ($app.ToUpper()) {
                    'WINWORD'  { 'Microsoft Word' }
                    'EXCEL'    { 'Microsoft Excel' }
                    'OUTLOOK'  { 'Microsoft Outlook' }
                    'POWERPNT' { 'Microsoft PowerPoint' }
                    'ONENOTE'  { 'Microsoft OneNote' }
                    'WINPROJ'  { 'Microsoft Project' }
                    'VISIO'    { 'Microsoft Visio' }
                    'TEAMS'    { 'Microsoft Teams' }
                    'GROOVE'   { 'Microsoft OneDrive for Business' }
                    default    { $app }
                }
                $found.Add($name)
            }
        }
        return $found
    }

    # Only show prompt once per invocation - no while loop
    # Intune re-triggers the whole script after defer expires via detection script
    $defersRemaining      = $MaxDeferCount - $deferCount
    $snoozeVisibility     = if ($defersRemaining -gt 0) { 'Visible' } else { 'Collapsed' }
    $timeSlots            = Get-TimeSlots -DefersRemaining $defersRemaining
    $timePickerVisibility = if ($timeSlots.Count -gt 0 -and $defersRemaining -gt 0) { 'Visible' } else { 'Collapsed' }

    $comboItems = ''
    foreach ($slot in $timeSlots) {
        $comboItems += "                    <ComboBoxItem Content=""$slot""/>`n"
    }

    $footerMsg = if ($defersRemaining -le 0) {
        'All deferrals used. Please save your work and click Install Now.'
    } elseif ($timeSlots.Count -eq 0) {
        'No more time slots available. Please click Install Now to proceed.'
    } else {
        "You have $defersRemaining deferral(s) remaining. Scheduling further ahead uses more deferrals."
    }

    $slotCountMsg = "Each hour scheduled ahead uses 1 deferral — you have $defersRemaining left"

    $xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Software Installation"
    Width="520" SizeToContent="Height"
    WindowStartupLocation="CenterScreen"
    Topmost="True"
    ResizeMode="NoResize"
    WindowStyle="None"
    Background="#FFFFFF"
    FontFamily="Segoe UI">

    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#1B3A6B"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="2" Padding="16,7">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#0078D4"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border BorderBrush="#AAAAAA" BorderThickness="1">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="42"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="50"/>
            </Grid.RowDefinitions>

            <!-- Header -->
            <Rectangle Grid.Row="0" Fill="#1B3A6B"/>
            <TextBlock Grid.Row="0" Text="$AppName" Foreground="White"
                       FontSize="14" FontWeight="Bold"
                       VerticalAlignment="Center" Margin="16,0,0,0"/>

            <!-- Body -->
            <StackPanel Grid.Row="1" Margin="18,12,18,10">

                <TextBlock TextWrapping="Wrap" FontSize="12" Foreground="#1A1A1A" Margin="0,0,0,8"
                    Text="Microsoft Office (Outlook, Word, Excel, PowerPoint, etc.) is ready to be refreshed on your device. Please save your work before proceeding."/>

                <!-- Running apps warning -->
                <StackPanel Name="PanelRunning" Visibility="Collapsed" Margin="0,0,0,8">
                    <DockPanel>
                        <Image Name="ImgError" Source="$errorIcon" Width="28" Height="28"
                               DockPanel.Dock="Left" VerticalAlignment="Top" Margin="0,2,10,0"/>
                        <StackPanel>
                            <TextBlock TextWrapping="Wrap" FontSize="12" FontWeight="Bold"
                                       Foreground="#0078D4" Margin="0,0,0,4"
                                       Text="Installation cannot complete because the following applications are running:"/>
                            <TextBlock Name="TxtRunningApps" FontSize="12" FontWeight="SemiBold"
                                       Foreground="#1A1A1A" Margin="12,0,0,0"/>
                        </StackPanel>
                    </DockPanel>
                </StackPanel>

                <!-- Ready panel -->
                <StackPanel Name="PanelReady" Visibility="Collapsed" Margin="0,0,0,8">
                    <TextBlock FontSize="12" FontWeight="Bold" Foreground="#107C10"
                               Text="All applications are closed. Click Install Now to begin."/>
                </StackPanel>

                <!-- Divider -->
                <Rectangle Height="1" Fill="#DDDDDD" Margin="0,2,0,8"/>

                <!-- Defer info -->
                <TextBlock FontSize="12" Foreground="#1A1A1A" Margin="0,0,0,2"
                    Text="You can defer this installation to a more convenient time:"/>
                <TextBlock FontSize="12" FontWeight="Bold" Foreground="#1A1A1A" Margin="0,0,0,6"
                    Text="Remaining Deferrals: $defersRemaining of $MaxDeferCount"/>

                <!-- Schedule time picker -->
                <StackPanel Visibility="$timePickerVisibility" Margin="0,0,0,4">
                    <TextBlock FontSize="12" Foreground="#1A1A1A" Margin="0,0,0,4"
                        Text="Schedule installation for a specific time today:"/>
                    <DockPanel>
                        <ComboBox Name="CmbTime" Width="120" Height="28"
                                  FontSize="12" Margin="0,0,10,0"
                                  DockPanel.Dock="Left" SelectedIndex="0">
$comboItems
                        </ComboBox>
                        <Button Name="BtnSchedule" Content="Schedule" Height="28" Width="90"
                                DockPanel.Dock="Left"/>
                    </DockPanel>
                    <TextBlock Name="TxtSlotCost" FontSize="10" Foreground="#CC6600"
                               FontWeight="SemiBold" Margin="0,4,0,0"
                               Text="$slotCountMsg"/>
                </StackPanel>

                <TextBlock FontSize="11" Foreground="#666666" Margin="0,8,0,0"
                           TextWrapping="Wrap" Text="$footerMsg"/>

            </StackPanel>

            <!-- Button bar -->
            <Border Grid.Row="2" Background="#F0F0F0" BorderBrush="#DDDDDD" BorderThickness="0,1,0,0">
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right"
                            VerticalAlignment="Center" Margin="0,0,16,0">
                    <Button Name="BtnOK"     Content="Install Now" Width="110" Height="32" Margin="0,0,10,0"/>
                    <Button Name="BtnSnooze" Content="Snooze 1hr"  Width="110" Height="32"
                            Visibility="$snoozeVisibility"/>
                </StackPanel>
            </Border>

        </Grid>
    </Border>
</Window>
"@

    $reader                    = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
    $window                    = [System.Windows.Markup.XamlReader]::Load($reader)
    $script:chosen             = 'SNOOZE'
    $script:scheduledMinutes   = 0
    $script:deferralsToConsume = 1

    $panelRunning = $window.FindName('PanelRunning')
    $panelReady   = $window.FindName('PanelReady')
    $txtRunning   = $window.FindName('TxtRunningApps')
    $imgError     = $window.FindName('ImgError')
    $cmbTime      = $window.FindName('CmbTime')
    $txtSlotCost  = $window.FindName('TxtSlotCost')

    if (-not (Test-Path $errorIcon)) { $imgError.Visibility = 'Collapsed' }

    # Live cost label when user changes combo selection
    $cmbTime.Add_SelectionChanged({
        $selected = $cmbTime.SelectedItem
        if ($selected) {
            try {
                $targetTime = [DateTime]::Parse($selected.Content)
                $mins       = [math]::Round(($targetTime - (Get-Date)).TotalMinutes)
                $cost       = [math]::Ceiling($mins / 60)
                $cost       = [math]::Max(1, [math]::Min($cost, $defersRemaining))
                if ($cost -ge $defersRemaining) {
                    $txtSlotCost.Text       = "Warning: scheduling this time will use ALL $defersRemaining remaining deferral(s)"
                    $txtSlotCost.Foreground = [System.Windows.Media.Brushes]::Red
                } else {
                    $txtSlotCost.Text       = "This will use $cost deferral(s) — $($defersRemaining - $cost) remaining after"
                    $txtSlotCost.Foreground = [System.Windows.Media.Brushes]::DarkOrange
                }
            } catch {}
        }
    })

    # Install Now
    $window.FindName('BtnOK').Add_Click({
        $script:chosen = 'OK'
        $window.Close()
    })

    # Snooze 1hr - costs 1 deferral
    $window.FindName('BtnSnooze').Add_Click({
        $script:chosen             = 'SNOOZE'
        $script:scheduledMinutes   = $SnoozeDuration
        $script:deferralsToConsume = 1
        $window.Close()
    })

    # Schedule - costs 1 deferral per hour
    $window.FindName('BtnSchedule').Add_Click({
        $selected = $cmbTime.SelectedItem.Content
        if ($selected) {
            $targetTime   = [DateTime]::Parse($selected)
            if ($targetTime -lt (Get-Date)) { $targetTime = $targetTime.AddDays(1) }
            $minutesUntil = [math]::Round(($targetTime - (Get-Date)).TotalMinutes)
            $elapsed       = ((Get-Date) - $scriptStartTime).TotalMinutes
            $remainingMins = $maxDeferWindowMins - $elapsed
            if ($minutesUntil -gt $remainingMins) { $minutesUntil = [math]::Floor($remainingMins) }
            $consumed = [math]::Ceiling($minutesUntil / 60)
            $consumed = [math]::Max(1, [math]::Min($consumed, $defersRemaining))
            $script:chosen             = 'SCHEDULE'
            $script:scheduledMinutes   = $minutesUntil
            $script:deferralsToConsume = $consumed
            $window.Close()
        }
    })

    # Draggable
    $window.Add_MouseLeftButtonDown({ $window.DragMove() })

    # No deferrals left - block X
    if ($defersRemaining -le 0) {
        $window.Add_Closing({
            param($s, $e)
            if ($script:chosen -ne 'OK') { $e.Cancel = $true }
        })
    }

    # Live polling timer
    $timer          = [System.Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromSeconds(3)
    $timer.Add_Tick({
        $running = Get-RunningOfficeApps
        if ($running.Count -gt 0) {
            $txtRunning.Text         = $running -join "`n"
            $panelRunning.Visibility = 'Visible'
            $panelReady.Visibility   = 'Collapsed'
        } else {
            $panelRunning.Visibility = 'Collapsed'
            $panelReady.Visibility   = 'Visible'
        }
    })
    $timer.Start()

    $init = Get-RunningOfficeApps
    if ($init.Count -gt 0) {
        $txtRunning.Text         = $init -join "`n"
        $panelRunning.Visibility = 'Visible'
        $panelReady.Visibility   = 'Collapsed'
    } else {
        $panelRunning.Visibility = 'Collapsed'
        $panelReady.Visibility   = 'Visible'
    }

    $window.ShowDialog() | Out-Null
    $timer.Stop()

    # User clicked Install Now - proceed immediately
    if ($script:chosen -eq 'OK') {
        Write-ADTLogEntry -Message "User clicked Install Now." -Source 'Show-DeferralPrompt'
        try { Remove-Item -Path $regPath -Force -ErrorAction SilentlyContinue } catch {}
        return 0
    }

    # User deferred - write registry and EXIT immediately
    # Detection script will hold Intune off via DeferUntil
    # Intune re-triggers the install when DeferUntil expires
    $sleepMinutes = if ($script:chosen -eq 'SCHEDULE') {
        Write-ADTLogEntry -Message "User scheduled for $($cmbTime.SelectedItem.Content). Consuming $($script:deferralsToConsume) deferral(s)." -Source 'Show-DeferralPrompt'
        $script:scheduledMinutes
    } else {
        Write-ADTLogEntry -Message "User snoozed 1hr. Consuming 1 deferral. ($($deferCount+1)/$MaxDeferCount)" -Source 'Show-DeferralPrompt'
        $SnoozeDuration
    }

    # Consume deferrals
    $deferCount += $script:deferralsToConsume
    if ($deferCount -gt $MaxDeferCount) { $deferCount = $MaxDeferCount }

    $deferUntil = (Get-Date).AddMinutes($sleepMinutes).ToString('o')
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name 'DeferCount' -Value $deferCount -Force
    Set-ItemProperty -Path $regPath -Name 'DeferUntil' -Value $deferUntil -Force

    Write-ADTLogEntry -Message "DeferUntil: $deferUntil. DeferCount: $deferCount/$MaxDeferCount. Exiting - detection script will hold Intune off." -Source 'Show-DeferralPrompt'

    # Return -1 so Invoke-AppDeployToolkit exits cleanly
    return -1
}