$PAErrorLogPreference = 'C:\temp\pa-errors.log'
function Get-VMInfo {

<#
.SYNOPSIS
Gets VM hardware and other information from vCenter for a
list of VMs. 
.DESCRIPTION
Queries hardware and other information from vCenter for VMs
.PARAMETER ComputerName
The name of the VM to query
.EXAMPLE
Get-PAVMinfo -ComputerName WHATEVER
.EXAMPLE
Get-Content c:\servers.txt | Get-PAVMinfo
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,
              ValueFromPipeline=$True,
              ValueFromPipelineByPropertyName=$True,
              #ParamterSetName='computername',
              HelpMessage="Enter a help message")]
    [string[]]$ComputerName,

    [Parameter()]
    [string]$ErrorLogFilePath = $PAErrorLogPreference

     )
     Begin{}
     PROCESS{
            foreach($computer in $ComputerName){
                $vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = $computer}
                $vmguest = Get-vm $computer 
                $props = @{'ComputerName' = $vm.Name;
                           'NumCPU' = $vm.config.hardware.NumCPU;
                           'NumCores' = $vm.config.hardware.NumCoresPerSocket;
                           'MemoryGB' = ($vm.config.hardware.MemoryMB / 1024);
                           'OSVersion' = $vm.Guest.GuestFullName;
                           'VMToolsVersion' = $vmguest.Guest.ToolsVersion;
                           'ToolsStatus' = $vm.Guest.ToolsVersionStatus;
                           'HardwareVersion' = $vm.Config.Version}                         
                $obj = New-Object -TypeName psobject -Property $props
                $obj.PSObject.TypeNames.Insert(0,'PA.VMInfo')
                Write-Output $obj
     }
}
     END{}
}

Export-ModuleMember -Variable PAErrorLogPreference
Export-ModuleMember -Function Get-VMInfo
