﻿function Get-DbaPbmStore {
    <#
    .SYNOPSIS
    Returns the policy based management store.

    .DESCRIPTION
    Returns the policy based management store.

    .PARAMETER SqlInstance
    SQL Server name or SMO object representing the SQL Server to connect to. This can be a collection and receive pipeline input to allow the function to be executed against multiple SQL Server instances.

    .PARAMETER SqlCredential
    Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

    .PARAMETER Policy
    Filters results to only show specific policy

    .PARAMETER Category
    Filters results to only show policies in the category selected

    .PARAMETER IncludeSystemObject
    By default system objects are filtered out. Use this parameter to include them.

    .PARAMETER EnableException
    By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
    This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
    Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
    Tags: Policy, PoilcyBasedManagement, PBM

    Website: https://dbatools.io
    Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
    License: MIT https://opensource.org/licenses/MIT

    .LINK
    https://dbatools.io/Get-DbaPbmStore

    .EXAMPLE
    Get-DbaPbmStore -SqlInstance sql2016
    Return the policy store from the sql2016 instance

    .EXAMPLE
    Get-DbaPbmStore -SqlInstance sql2016 -SqlCredential $cred

    Uses a credential $cred to connect and return the policy store from the sql2016 instance

#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [Alias("Credential")]
        [PSCredential]$SqlCredential,
        [switch]$EnableException
    )
    
    process {
        foreach ($instance in $SqlInstance) {
            Write-Message -Level Verbose -Message "Connecting to $instance"
            
            try {
                $server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $SqlCredential -MinimumVersion 10
                $sqlStoreConnection = New-Object Microsoft.SqlServer.Management.Sdk.Sfc.SqlStoreConnection $server.ConnectionContext.SqlConnectionObject
                # DMF is the Declarative Management Framework, Policy Based Management's old name
                $store = New-Object Microsoft.SqlServer.Management.DMF.PolicyStore $sqlStoreConnection
            }
            catch {
                Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }
            
            Add-Member -Force -InputObject $store -MemberType NoteProperty ComputerName -value $server.ComputerName
            Add-Member -Force -InputObject $store -MemberType NoteProperty InstanceName -value $server.ServiceName
            Add-Member -Force -InputObject $store -MemberType NoteProperty SqlInstance -value $server.DomainInstanceName
            
            Select-DefaultView -InputObject $store -ExcludeProperty SqlStoreConnection, ConnectionContext, Properties, Urn, Parent, DomainInstanceName, Metadata, IdentityKey, Name
        }
    }
}