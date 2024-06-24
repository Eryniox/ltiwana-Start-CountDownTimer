<#
.SYNOPSIS
    This function will start a countdown timer based on the parameters supplied.
#>

Function Start-CountDownTimer {
    [CmdletBinding(DefaultParameterSetName = 'int')]
    Param (
    
        [CmdletBinding()]
        [Parameter(ParameterSetName = 'int', Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[0-9]*")]
        [int]$Seconds,

        [Parameter(ParameterSetName = 'int', Position=1)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[0-9]*")]
        [int]$Minutes,

        [Parameter(ParameterSetName = 'int', Position=2)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[0-9]*")]
        [int]$Hours,

        [Parameter(ParameterSetName = 'datetime', Position=0)]
        [datetime]$EndTime,

        [Parameter(ParameterSetName = 'datetimestring', Position=0)]
        [string]$EndTimeString

    )

    $Timer = 0; $i = 1

    if (!$Seconds  -and !$Minutes -and !$Hours -and !$EndTime) {
        Write-Warning "No parameters were supplied, default is 1 minute"
        $Timer = New-TimeSpan -Minutes 1
        #Write-Error  -Message "At least one parameter is required" -RecommendedAction "Usage: Start-CountDownTimer -seconds 35" -Category NotSpecified -Exception "Missing one of the following parameters -Seconds, -Minutes, -Hours" -TargetObject "Missing Parameters"
    }
    
    if ($EndTimeString) {
        Write-Verbose "End Time String was supplied"
        try {
            $EndTime = [datetime]::Parse($EndTimeString)
        }
        catch {
            Write-Error "Invalid DateTime format supplied"
            Return
        }
    }

    if ($EndTime) {
        Write-Verbose "End Time was supplied"
        $TimerEnd = $EndTime - (Get-Date)
        Write-Verbose "Timer Value: $Timer"
        $Seconds = $TimerEnd.Seconds
        $Minutes = $TimerEnd.Minutes
        $Hours = $TimerEnd.Hours + ( $TimerEnd.Days * 24 )
    }

    Write-Verbose "Following values were supplied"
    Write-Verbose "`nSeconds: $Seconds`nMinutes: $Minutes `nHours: $Hours"

    if ($Seconds) {
        Write-Verbose "Adding $Seconds seconds to Timer"
        $Timer = New-TimeSpan -Seconds $Seconds
    }

    if ($Minutes) {
        Write-Verbose "Adding $Minutes Mintues to Timer"
        $Timer += New-TimeSpan -Minutes $Minutes
    }

    if ($Hours) {
        Write-Verbose "Adding $Hours Hours to Timer"
        $Timer += New-TimeSpan -Hours $Hours
    }

    Write-Verbose "Total Timer Value: $Timer"
    Write-Verbose "Starting the progress bar"

    while ( $i -ne $Timer.TotalSeconds) {
        
        Write-Verbose "Calculating the percentage"
        $Percentage = [math]::Round($i/$Timer.TotalSeconds*100)

        Write-Verbose "Percentage: $Percentage"
        Write-Verbose "Calculating total time remaining"
        $TimeDifference = $Timer - (New-TimeSpan -Seconds $i)
        Write-Verbose "Time remaining $TimeDifference"
       
        Write-Progress -Activity "Time Remaining: $TimeDifference" -Status "Timer Progress $Percentage%" -PercentComplete $Percentage
        
        Write-Verbose "Incrementing `$i($i) variable"
        $i++

        Write-Verbose "Adding 1 second sleep"
        Start-Sleep -Seconds 1
    }
    Write-Verbose "Marking progress bar done"
    Write-Progress -Activity "Time Remaining: $TimeDifference" -Status "Done" -Completed 
}

Export-ModuleMember -Function Start-CountDownTimer
