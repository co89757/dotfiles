function prompt {

    $path = Split-Path -leaf -path (Get-Location)
    $Date = Get-Date

    Write-Host
    Write-Host "# " -NoNewline -ForegroundColor Blue
    Write-Host $env:USERNAME -NoNewline -ForegroundColor Cyan
    Write-Host " in " -NoNewline
    Write-Host $path" " -NoNewline -ForegroundColor Green
    $realLASTEXITCODE = $LASTEXITCODE
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    Write-Host " "$Date
    Write-Host ">" -NoNewline -ForegroundColor Magenta

    return " "
}

if ( -not (Test-Path alias:new) ) {
    Set-Alias new New-Object
}

function dirname ($path) {
    [System.IO.Path]::GetDirectoryName($path);
}

if (-not (Test-Path alias:subl)) {
    Set-Alias subl 'C:\Program Files\Sublime Text 3\sublime_text.exe'
}

function df () {
    param(
        # computern ame
        [Parameter( Position=1 )]
        [string]
        $ComputerName = $env:computername
    )
  Get-WmiObject Win32_LogicalDisk -filter "DriveType=3" -computer $ComputerName |
  Select-Object SystemName, DeviceID, VolumnName,
          @{Name="size (GB)";Expression={"{0:N1}" -f($_.size/1gb)}},
          @{Name="freespace (GB)";Expression={"{0:N1}" -f($_.freespace/1gb)}} |
  Format-Table -AutoSize
}

function touch () {
    param(
        # path to the File
        [Parameter(Mandatory,Position=1)]
        [string]
        $Path,

        $Value = $null
    )
    Set-Content -Path $Path -Value $Value
    Set-ItemProperty -Path $Path -Name LastWriteTime -Value $(get-date)
}

function CountLine () {
    param(
        # input filename
        [Parameter(HelpMessage="Input filename",
        Mandatory)]
        [ValidateScript({test-path $_})]
        [string]
        $File,
        [switch]$NonBlank = $false
    )
    if ($NonBlank) {
        Get-Content $File |  Measure-Object -line
    }else{
        Get-Content $File | Measure-Object | select -ExpandProperty Count
    }
}
if ( -not (Test-Path alias:wc) ) {
    set-alias wc Count-Line
}

function UnZip  () {
    [CmdletBinding()]
    param(
        # file to unzip
        [Parameter(Mandatory,Position=1)]
        [string]
        $File,
        # destination directory
        [Parameter(Position=2)]
        [string]
        $DestDirectory = $PWD.ToString()
    )

    if ($PSVersionTable.PSVersion.Major -ge 5) {
        Expand-Archive -Path $File -Dest $DestDirectory -Force
    }else{
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($File, $DestDirectory)
    }
}

## poll IGS run status : running | blocked | complete


## delete a a IGS deployment given service-name
function Delete-AzDeployment () {
    [CmdletBinding()]
    param(
        # service name
        [Parameter(Mandatory,Position=1)]
        [string]
        $ServiceName,
        [Parameter(Mandatory)]
        [string]$SubscriptionName,
        # publish settings file Get-Location
        [Parameter(Mandatory)]
        [ValidatePattern("publishsettings$")]
        $PublishSettingsFile 
    )
    if (-not (Test-Path $PublishSettingsFile)) {
        Write-Error "PublishSettings File: $PublishSettingsFile not exist! Fix your path/to/publishsettings before proceeding"
    }

    Import-AzurePublishSettingsFile -PublishSettingsFile $PublishSettingsFile
    Select-AzureSubscription $SubscriptionName

    $depl =  Get-AzureDeployment -ServiceName $ServiceName -ErrorVariable err -ErrorAction SilentlyContinue
    if($err[0] -ne $null){
        Write-Host "No Deployment Found for $ServiceName. Nothing further." -Fore Yellow
        return
    }



    Write-Host "Found Active Deployment:"
    Write-Host "-------------`nServiceName: $ServiceName`nStatus: $($depl.Status)`nSlot:$($depl.Slot)`nDeploymentID:$($depl.DeploymentId)`nCreateTime:$($depl.CreatedTime)`n---------" -Fore Cyan
    Write-Host "Are you REALLY sure to delete this deployment? [Y/N]" -Fore Yellow
    $key = [Console]::ReadKey($true)
    if ($key.Key -eq 'Y' ) {
        Write-Host "OK, About to delete deployment on $ServiceName"
        Remove-AzureDeployment -ServiceName $depl.ServiceName
    }
    else{
        Write-Host "Quitting without deleting any deployment ... "
    }

}

function Tidy-Xml {
    begin {
        $private:str = ""

        # recursively concatenate strings from passed-in arrays of schmutz
        # not sure how to improve this...
        function ConcatString ([object[]] $szArray) {
            # return string
            $private:rStr = ""

            # Recursively call itself, if a string is also of array or a collection type
            foreach ($private:sz in $szArray) {
                if (($private:sz.GetType().IsArray) -or `
                    ($private:sz -is [System.Collections.IList])) {
                    $private:rStr += ConcatString($private:sz)
                }
                elseif ($private:sz -is [xml]) {
                    $private:rStr += $private:sz.Get_OuterXml()
                }
                else {
                    $private:rStr += $private:sz
                }
            }
            return $private:rStr;
        }

        # Original "Tidy-Xml" portion
        function FormatXmlString ($arg) {
            # ignore parse errors
            trap { continue; }

            # out-null hides output of the assembly load
            [System.Reflection.Assembly]::LoadWithPartialName("System.Xml") | out-null

            $PRIVATE:tempString = ""
            if ($arg -is [xml]){
                $PRIVATE:tempString = $arg.get_outerXml()
            }
            if ($arg -is [string]){
                $PRIVATE:tempString = $arg
            }

            # the ` tick mark is a line-continuation char
            $r = new-object System.Xml.XmlTextReader(`
                new-object System.IO.StringReader($PRIVATE:tempString))
            $sw = new-object System.IO.StringWriter
            $w = new-object System.Xml.XmlTextWriter($sw)
            $w.Formatting = [System.Xml.Formatting]::Indented

            do { $w.WriteNode($r, $false) } while ($r.Read())

            $w.Close()
            $r.Close()
            $sw.ToString()
        }
    }

    process {
        # For non-xml strings or types, they will be buffered and will be
        # taken care of in "end" block

        # this checks for objects that have been "pipe'd" in.
        if ($_) {
            # check if whatever we have appended is a valid XML or not
            $private:xmlStr = ($private:str + $_) -as [xml]

            if ($private:xmlStr -ne $null) {
                FormatXmlString([xml]$private:xmlStr)
                # clear the string not to be handled in "end" block
                $private:str = $null
            } else {
                if ($_ -is [string]) {
                    $private:str += $_
                } elseif ($_ -is [xml]) {
                    FormatXmlString($_)
                }
                # for an array or a collection type,
                elseif ($_.Count) {
                    # iterate each item in the collection and append
                    foreach ($i in $_) {
                        $private:line += $i
                    }
                    $private:str += $private:line
                }
            }
        }
    }

    end {
        if ([string]::IsNullOrEmpty($private:str)) {
            $private:szXml = $(ConcatString($args)) -as [xml]
            if (! [string]::IsNullOrEmpty($private:szXml)) {
                FormatXmlString([xml]$private:szXml)
            }
        } else {
            FormatXmlString([xml]$private:str)
        }
    }
}

# Append a location to system PATH variable
function Add-Path () {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to append to PATH sysvar.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $PathToAppend
    )

    #test if path exists 
    if (-not (Test-Path -Path $PathToAppend)) {
        Write-Error "$PathToAppend is not a valid location."
        return 
    }
    $RegKey = "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment"
    # get old path 
    $oldpath = (Get-ItemProperty -Path $RegKey -Name PATH ).Path 
    Write-Debug "Old %PATH%: $oldpath" 
    # test if alerady contains 
    if ($oldpath.Contains( $PathToAppend )) {
        Write-Host "$PathToAppend already exists in $oldpath, do nothing..."
        return        
    }
    $newpath = $oldpath + ";" + $PathToAppend 
    Set-ItemProperty -Path $RegKey -Name PATH -Value $newpath 
    Write-Verbose "path $PathToAppend is appended to PATH variable" 
}
