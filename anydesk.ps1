function connections ($logfile){
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


function outgoingConnections($logfile){
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

function incomingConnectionsIDs ($logfile){
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


function incomingConnectionsIPs ($logfile){
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

function UniqueincomingConnectionsIPs ($logfile){
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

function duration ($logfile){
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


function tunnel($logfile){
    $log = Get-Content $logfile
    $obj = @()
    $obj = foreach($line in $log){
        $split = $line -split ' '
        $remote = $split[-1] -split ':'
        if($line -like "*tunnel.config*->*"){
            [pscustomobject]@{
            Timestamp = ([datetime]($split[4]+' '+$split[5])).ToString("yyyy-MM-dd HH:mm:ss")
            LocalPort = $split[-3]
            RemoteIP = $remote[0]
            RemotePort = $remote[-1]
            }
        }
    }
    $obj
}



           # pause
            for($i = $index; $i -lt $end; $i++){
               write-host $i
                if($log[$i] -like "*Cleaned up 1/1 managed client connections*"){
                    1
                    $line
                    $log[$i]
                    
                }
            }
        #}
    }
