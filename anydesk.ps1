function Get-ADConnections{
<#
.SYNOPSIS
    Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of incoming 
    and outgoing connections, to include the timstamps, AnyDesk IDs, IP addresses, and PIDs.

.PARAMETER logFile
    Location to the ad_svc.trace or ad.trace log.

.EXAMPLE
    Get-ADkConnections -logFile c:\ad_svc.trace

    Parses C:\ad_svc.trace and returns a list of incoming and outgoing connection data.
#>
    [CmdletBinding()]
    param(
        $logfile
    )

    $log = Get-Content $logfile
    $obj = @()
    $obj = foreach($line in $log){
        if($line -like '*app.session - 1: Connecting to "*'){
            $split = $line -Split('\s+')
            $index = $log.IndexOf($line) + 20
            for($i = $index; $i -gt ($index - 20); $i--){
                if($log[$i] -match "anynet.any_socket - Logged in from "){
                    $netData = (($log[$i] -split ' ')[-4]) -split ':'  
                    break
                }  
            }
            [pscustomobject]@{
                Timestamp = ([datetime]($split[2]+' '+$split[3])).ToString("yyyy-MM-dd HH:mm:ss")
                OutgoingID = $split[13].trim('"')
                OutgoingIP = $netData[0]
                OutgoingPort = $netData[1]
                IncomingID = '-'
                IncomingIP = '-'
                IncomingPort = '-'
            }  
        }
        elseif($line -like "*accept request from*"){
            $split = $line -Split('\s+')
            $index = $log.IndexOf($line) + 20
            for($i = $index; $i -gt ($index - 20); $i--){
                if($log[$i] -match "anynet.any_socket - Logged in from "){
                    $netData = (($log[$i] -split ' ')[-4]) -split ':'
                }  
            }
            [pscustomobject]@{
                Timestamp = ([datetime]($split[2]+' '+$split[3])).ToString("yyyy-MM-dd HH:mm:ss")
                OutgoingID = '-'
                OutgoingIP = '-'
                OutgoingPort = '-'
                IncomingID = $split[13].trim('"')
                IncomingIP = $netData[0]
                IncomingPort = $netData[1]
            }
        }
    }
    $obj
}

function Get-ADOutgoingConnections{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of outgoing connections, to 
        include the timestamps, AnyDesk IDs, and PIDs.

    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADOutgoingConnections -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns a list of outgoing connection data.
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )

    $log = Get-Content $logfile
    $lines = $log | Select-String -Pattern 'app.session - 1: Connecting to "'
    $obj = @()
    $obj = foreach($line in $lines){
        $split = $line -Split('\s+')
        [pscustomobject]@{
            Timestamp = ([datetime]($split[2]+' '+$split[3])).ToString("yyyy-MM-dd HH:mm:ss")
            PID = $split[5]
            RemoteID = $split[13].trim('"') 
        }
    }
    $obj
}

function Get-ADIncomingConnections{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of incoming connections, to 
        include the timestamps, AnyDesk IDs, and PIDs.

    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADIncomingConnections -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns a list of incoming connection data.
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )

    $log = Get-Content $logfile
    $lines = $log | Select-String -Pattern 'accept request from'
    $obj = @()
    $obj = foreach($line in $lines){
        $split = $line -Split('\s+')
        [pscustomobject]@{
            Timestamp = ([datetime]($split[2]+' '+$split[3])).ToString("yyyy-MM-dd HH:mm:ss")
            PID = $split[5]
            RemoteID = $split[13].trim('"') 
        }
    }
    $obj
}

function Get-ADIncomingConnectionIPs{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of IP addresses associated 
        with incoming connections.

    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADIncomingConnectionIPs -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns a list of timestamps and IP addresses.
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )

    $log = Get-Content $logfile
    $lines = $log | Select-String -Pattern 'accept request from'
    $obj = @()
    $obj = foreach($line in $lines){
        $split = $line -Split('\s+')
        $index = $log.IndexOf($line) + 20
        for($i = $index; $i -gt ($index - 20); $i--){
            if($log[$i] -match "anynet.any_socket - Logged in from "){
                $netData = (($log[$i] -split ' ')[-4]) -split ':'
            }  
        }
        [pscustomobject]@{
            Timestamp = ([datetime]($split[2]+' '+$split[3])).ToString("yyyy-MM-dd HH:mm:ss")
            IncomingIP = $netData[0]
        }
    }
    $obj
}

function Get-ADUniqueIncomingConnectionIPs{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of unique IP addresses 
        associated with incoming connections.

    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADUniqueIncomingConnectionIPs -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns a list of unique IP addresses.
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )

    $log = Get-Content $logfile
    $lines = $log | Select-String -Pattern 'accept request from'
    $obj = @()
    $obj = foreach($line in $lines){
        $split = $line -Split('\s+')
        $index = $log.IndexOf($line) + 20
        for($i = $index; $i -gt ($index - 20); $i--){
            if($log[$i] -match "anynet.any_socket - Logged in from "){
                $netData = (($log[$i] -split ' ')[-4]) -split ':'
            }  
        }
        [pscustomobject]@{
            Timestamp = ([datetime]($split[2]+' '+$split[3])).ToString("yyyy-MM-dd HH:mm:ss")
            IncomingIP = $netData[0]
        }
    }
    $obj.incomingIP | Sort-Object -Unique
}

function Get-ADConnectionDurations{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of incoming connections and 
        their durations to include timestamps.


    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADConnectionDurations -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns each connection and its duration
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )

    $log = Get-Content $logfile
    $end = $log.IndexOf($log[-1])
    $lines = $log | Select-String -Pattern 'accept request from'
    $obj = @()
    $obj = foreach($line in $lines){
        #if($line -like "*accept request from*"){
            #$index = $log.IndexOf($line)
        #$start = $log[$line.Linenumber]
        $startSplit = $line -split ' '
        $startTime = ([datetime]($startSplit[4]+' '+$startSplit[5])).ToString("yyyy-MM-dd HH:mm:ss")
        #write-host $line
        for($i = ($line.Linenumber); $i -lt $end; $i++){
            if($log[$i] -like "*Cleaned up 1/1 managed client connections*"){ # process stop    session close
                #write-host $log[$i]
                $endSplit = $log[$i] -split ' '
                $endTime = ([datetime]($endSplit[4]+' '+$endSplit[5])).ToString("yyyy-MM-dd HH:mm:ss")
                break
            }
            if($log[$i] -like "*session close*"){
                #write-host $log[$i]
                $endSplit = $log[$i] -split ' '
                $endTime = ([datetime]($endSplit[4]+' '+$endSplit[5])).ToString("yyyy-MM-dd HH:mm:ss")
                break
            }
        }
        $span = New-TimeSpan -Start $startTime -End $endTime
        [pscustomobject]@{            
            AnyDeskID = $startSplit[-3]
            StartTimestamp = $startTime
            EndTimestamp = $endTime
            Duration = [string]$span.days + "D" + [string]$span.hours + "H" + [string]$span.Minutes + "M" + [string]$span.Seconds + "S"
        }
    }
    $obj
}

function Get-ADTunnel{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of data about any 
        configured AnyDesk tunnel configurations

    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADTunnel -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns tunnel information
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )
    $log = Get-Content $logfile
    $obj = @()
    $obj = foreach($line in $log){
        if($line -like "*tunnel.config*->*"){
            $split = $line -split ' '
            $remote = $split[-1] -split ':'
            [pscustomobject]@{
                Timestamp = ([datetime]($split[4]+' '+$split[5])).ToString("yyyy-MM-dd HH:mm:ss")
                LocalPort = $split[-3]
                ForwardedIP = $remote[0]
                ForwardedPort = $remote[-1]
            }
        }
    }
    $obj
}

function Get-ADTunnelConnections{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of tunnels that were
        configured and used to include the timestamps associated with the connections. 


    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADTunnelConnections -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns tunnel data
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )

    $log = Get-Content $logfile
    $end = $log.IndexOf($log[-1])
    $lines = $log | Select-String -Pattern 'app.session - 1: Connecting to "'
    $obj = $tun = @()
    $obj = foreach($line in $lines){
        $tunnelTimestamp = ''
        $startSplit = $line -split ' '
        $connectTimestamp = ([datetime]($startSplit[4]+' '+$startSplit[5])).ToString("yyyy-MM-dd HH:mm:ss")
        for($i = ($line.Linenumber); $i -lt $end; $i++){
            if($log[$i] -like "*tunneling_config*->*"){ 
                $split = $log[$i] -split ' '
                $remote = $split[-1] -split ':'
                break
            }           
        }
        if($tunnelTimestamp.Length -eq 0){
            $tunnelTimestamp = '-'
        }
        [pscustomobject]@{
            Timestamp = $connectTimestamp
            OutgoingID = ($startSplit[-1]).Trim('"')
            LocalPort = $split[-3]
            ForwardedIP = $remote[0]
            ForwardedPort = $remote[-1]
            TunnelTimestamp =$tunnelTimestamp
        }   
    }

    $tunConnect = $log | select-string -Pattern "accepting tcp-tunnel"
    foreach($line in $tunConnect){
        $split = $line -split ' '
        $date = ([datetime]($split[4]+' '+$split[5])).ToString("yyyy-MM-dd HH:mm:ss")
        $index = 0
        foreach($item in $obj){
            if($date -gt $item.timestamp -AND $date -lt $obj[($index + 1)].timestamp){
                $item.TunnelTimestamp = $date
            }
            $index += 1
        }
    }
    $obj | Format-Table
}

function Get-ADForwardedTunnels{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list of forwarded tunnels from the 
        system to include timestamps associated with the connections. 


    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADForwardedTunnels -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns tunnel data
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )    

    $log = Get-Content $logfile
    $end = $log.IndexOf($log[-1])
    $lines = $log | Select-String -Pattern 'accept request from'
    $obj = @()
    $obj = foreach($line in $lines){
        $tunnelTimestamp = ''
        $startSplit = $line -split ' '
        $connectTimestamp = ([datetime]($startSplit[4]+' '+$startSplit[5])).ToString("yyyy-MM-dd HH:mm:ss")
        $id = $startSplit[-3]
        $index = $log.IndexOf($line) + 20
        for($i = $index; $i -gt ($index - 20); $i--){
            if($log[$i] -match "anynet.any_socket - Logged in from "){
                $netData = (($log[$i] -split ' ')[-4]) -split ':'
            }           
        }
        [pscustomobject]@{
            Timestamp = $connectTimestamp
            IncomingID = $id
            IncomingIP = $netData[0]
            ForwardedIP = '-'
            ForwardedPort = '-'
            TunnelTimestamp = '-'
        }   
    }
    $tunConnect = $log | Select-String -Pattern 'Requesting a TCP-Tunnel'
    foreach($line in $tunConnect){
        $split = $line -split ' '
        $date = ([datetime]($split[4]+' '+$split[5])).ToString("yyyy-MM-dd HH:mm:ss")
        $index = 0
        foreach($item in $obj){
            if($date -gt $item.timestamp -AND $date -lt $obj[($index + 1)].timestamp){
                $item.TunnelTimestamp = $date
                $item.forwardedport = ($split[-1]).Trim('.')
                $item.forwardedip = $split[-4]
            }
            $index += 1
        }
    }
}

function Get-ADFileTransferTo{
<#
    .SYNOPSIS
        Parses the ad_svc.trace log (for installed instances of AnyDesk) or ad.trace log (for portable instances of AnyDesk) and returns a list directories from which a 
        file or files were transferrred from to a remote system. The list also includes the timstamp of the AnyDesk connection, the remote anydesk ID and IP, as well as
        the transfer timestamp.

    .PARAMETER logFile
        Location to the ad_svc.trace or ad.trace log.

    .EXAMPLE
        Get-ADFileTransferTo -logFile c:\ad_svc.trace

        Parses C:\ad_svc.trace and returns tunnel data
#>
    
    [CmdletBinding()]
    param(
        $logfile
    )    
    $log = Get-Content $logfile
    $lines = $log | Select-String -Pattern 'accept request from'
    $obj = @()
    $obj = foreach($line in $lines){
        $split = $line -split ' '
        $index = $log.IndexOf($line) + 20
        for($i = $index; $i -gt ($index - 20); $i--){
            if($log[$i] -match "anynet.any_socket - Logged in from "){
                $netData = (($log[$i] -split ' ')[-4]) -split ':'
                break
            }           
        }
        [pscustomobject]@{
            Timestamp = ([datetime]($split[4]+' '+$split[5])).ToString("yyyy-MM-dd HH:mm:ss")
            ConnectedID = $split[-3]
            ConnectedIP = $netData[0]
            TransferTimestamp = '-'
            SourceDirectory = '-'
        }
    }

    $fileTask = $log | select-string -Pattern "app.prepare_task - Preparing files in"
    foreach($line in $fileTask){
        $split = $line -split ' '
        $date = ([datetime]($split[4]+' '+$split[5])).ToString("yyyy-MM-dd HH:mm:ss")
        $index = 0
        foreach($item in $obj){
            if($date -gt $item.timestamp -AND $date -lt $obj[($index + 1)].timestamp){
                $item.TransferTimestamp = $date
                $item.SourceDirectory = $split[-1].Trim("'.")
            }
            $index += 1
        }
    }
    $obj | Format-Table
}

function Get-ADFileTransferFrom{


}

function keyboard{
    desk_rt.capture_component - Keyboard layout changed to: en_us
}