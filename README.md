# Posh-Prowl

A simple wrapper for the [Prowl](https://www.prowlapp.com/) notification API.

# Install

The [latest release version](https://www.powershellgallery.com/packages/Posh-Prowl) can found in the PowerShell Gallery or the [GitHub releases page](https://github.com/rmbolger/Posh-Prowl/releases). Installing from the gallery is easiest using `Install-Module` from the PowerShellGet module. See [Installing PowerShellGet](https://docs.microsoft.com/en-us/powershell/gallery/installing-psget) if you don't already have it installed.

```powershell
# install for all users (requires elevated privs)
Install-Module -Name Posh-Prowl

# install for current user
Install-Module -Name Posh-Prowl -Scope CurrentUser
```

To install the latest *development* version from the git master branch, use the following command. This method assumes a default Windows PowerShell environment that includes the [`PSModulePath`](https://msdn.microsoft.com/en-us/library/dd878326.aspx) environment variable which contains a reference to `$HOME\Documents\WindowsPowerShell\Modules`. You must also make sure `Get-ExecutionPolicy` is not set to `Restricted` or `AllSigned`.

```powershell
# (optional) set less restrictive execution policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# install latest dev version
iex (irm https://raw.githubusercontent.com/rmbolger/Posh-Prowl/master/instdev.ps1)
```


# Quick Start

This guide assumes you already have a Prowl account and at least one app successfully recieving notifications. If you haven't created an API key yet, go to the [API Keys](https://www.prowlapp.com/api_settings.php) page on the Prowl site and create a key to use for your account.

The minimum set of parameters needed to send a Prowl notification are an API key and a Subject or Message.

```powershell
$key = '1234567890123456789012345678901234567890'
Send-ProwlNotification $key -Subject 'Hello from Prowl'
```

The previous message will show up as being from "Posh-Prowl" which is the default value for the `-From` parameter. In most cases, you probably want to provide a more specific context for the notification. You may also want to customize the `-Priority` parameter which ranges from -2 (Very Low) to 2 (Emergency).

```powershell
Send-ProwlNotification $key -Subject 'The server is down' -From 'The Monitoring System' -Priority 2
```

A notification can also be associated with a URL via `-Url` and most apps will have an easy way to launch a browser to that URL from the notification. You can also send a notification to multiple recipients by specifying multiple API keys.

```powershell
$keys = 'xxxxxxxxxxxxxxxx','yyyyyyyyyyyyyyyy'
$from = 'The Ticketing System'
$subject = 'Ticket Requires Attention'
$msg = 'Ticket #12345 requires authorization.'
$url = 'https://example.com/tickets/12345'

# send the message to all keys
$keys | Send-ProwlNotification -Subject $subject -Message $msg -From $from -Url $url
```

For more complete docs, run `Get-Help Send-ProwlNotification -full`.

# Requirements and Platform Support

* Supports Windows PowerShell 5.1 or later (a.k.a. Desktop edition).
* Supports [Powershell Core](https://github.com/PowerShell/PowerShell) 6.0 or later (a.k.a. Core edition) on all supported OS platforms.

# Changelog

See [CHANGELOG.md](/CHANGELOG.md)
