function Send-ProwlNotification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]]$ApiKeys,
        [string]$Subject,
        [string]$Message,
        [ValidateNotNullOrEmpty()]
        [string]$From='Posh-Prowl',
        [string]$ProviderKey,
        [ValidateRange(-2,2)]
        [int]$Priority=0,
        [string]$Url
    )

    Begin {
        $allKeys = @()
        $apiUrl = 'https://api.prowlapp.com/publicapi/add'

        # $Subject and/or $Message are/is required
        if (-not $Subject -and -not $Message) {
            throw "You must provide -Subject or -Message or both."
        }

        # validate the byte length of the various parameters
        if ($Subject) {
            if ([Text.Encoding]::UTF8.GetByteCount($Subject) -gt 1024) {
                throw "Subject must be no larger than 1024 bytes."
            }
        }
        if ($Message) {
            if ([Text.Encoding]::UTF8.GetByteCount($Message) -gt 10000) {
                throw "Message must be no larger than 10000 bytes."
            }
        }
        if ($From) {
            if ([Text.Encoding]::UTF8.GetByteCount($From) -gt 256) {
                throw "From must be no larger than 256 bytes."
            }
        }
        if ($ProviderKey) {
            if ([Text.Encoding]::UTF8.GetByteCount($ProviderKey) -gt 40) {
                throw "ProviderKey must be no larger than 40 bytes."
            }
        }
        if ($Url) {
            if ([Text.Encoding]::UTF8.GetByteCount($Url) -gt 512) {
                throw "Url must be no larger than 512 bytes."
            }
        }
    }

    Process {
        # add the keys from this pipeline item to
        # the set of all keys
        $allKeys += $ApiKeys
    }

    End {
        # remove duplicates
        $allKeys = $allKeys | Select-Object -Unique

        # prepare the keys for transmission
        $apikey = $allKeys -join ','

        # build the body
        $body = @{
            apikey = $apikey
            application = $From
            priority = $Priority
        }
        if ($Subject) { $body.event = $Subject }
        if ($Message) { $body.description = $Message }
        if ($ProviderKey) { $body.providerkey = $ProviderKey }
        if ($Url) { $body.url = $Url }

        Write-Verbose "Sending message to $($allKeys.Count) key(s)"
        $response = Invoke-RestMethod $apiUrl -Method Post -Body $body

        if ($response.prowl.success) {
            Write-Verbose "$($response.prowl.success.remaining) calls remaining. Resets at $([DateTimeOffset]::FromUnixTimeSeconds($response.prowl.success.resetdate))"
        }

    }


    <#
    .SYNOPSIS
        Send a Prowl notification.

    .DESCRIPTION
        Send a Prowl push notification to one or more API keys.

    .PARAMETER APIKeys
        One or more Prowl API keys to send to.

    .PARAMETER Subject
        The name of the event or subject of the notification. Required if Message is not specified. (1024 bytes max)

    .PARAMETER Message
        A description of the event, generally terse. Required if Subject is not specified. (10,000 bytes max)

    .PARAMETER From
        The name of your application or the sender of the event. (256 bytes max)

    .PARAMETER ProviderKey
        Your provider API key. Only necessary if you have been whitelisted.

    .PARAMETER Priority
        The priority of the notification ranging from -2 to 2 where -2 is Very Low and 2 is Emergency. Emergency priority messages may bypass quiet hours according to the user's settings.

    .PARAMETER Url
        The URL which should be attached to the notification. This will trigger a redirect when launched, and is viewable in the notification list. (512 bytes max)

    .EXAMPLE
        Send-ProwlNotification 'XXXXXXXXXXXX' -Subject 'The operation is complete.'

        Send a subject-only message to a single API key.

    .EXAMPLE
        $keys = 'XXXXXXXXXXXXXXXX','YYYYYYYYYYYYYYYY'
        PS C:\>$from = 'The Ticketing System'
        PS C:\>$subject = 'Ticket Requires Attention'
        PS C:\>$msg = 'Ticket #12345 requires authorization.'
        PS C:\>$url = 'https://example.com/tickets/12345'
        PS C:\>$keys | Send-ProwlNotification -Subject $subject -Message $msg -From $from -Url $url

        Send a message to multiple recipients with a custom app name and URL link

    .LINK
        Project: https://github.com/rmbolger/Posh-Prowl

    #>
}
