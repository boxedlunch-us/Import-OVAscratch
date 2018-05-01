<#
.SYNOPSIS
   A troubleshooting tool that breaks the OVA/F import process down in order to discovery points of failure in the case of a stubborn archive.
   Imports OVA/OVF to vCenter with hashtable configuration parameters
.PARAMETER vCenter
    vCenter under which the OVA will be deployed
.PARAMETER cluster
    cluster resource needed
.PARAMETER OVAPath
    path to the OVA file, including dependencies
.PARAMETER datastore
    where the deployed VM will live
.PARAMETER vmhost
    Need to figure out why this is needed; suspect needed for clusters without DRS enabled, or if DRS is set to manual
.PARAMETER vmName
    name of the deployed VM
.NOTES
    Author(s): Ricky Nelson, Brian McElroy
    Date: 20180207
.EXAMPLE
    .\Import-OVAscratch.ps1 -vCenter vCenter -cluster clustername -OVAPath C:\pathtoOVA.ova -datastore DestDatastore -vmhost vmhost -vmName nameOfDeployedVM

#>


[CmdletBinding()]
param (
    # vCenter Server to which you will deploy the machine
    [Parameter(Mandatory=$true,HelpMessage="vCenter Server")]
    [string]
    $vCenter,
    # Cluster resources
    [Parameter(Mandatory=$true,HelpMessage="Cluster to which the OVA will be deployed")]
    [string]
    $cluster,
    # ova path
    [Parameter(Mandatory=$true,HelpMessage="Path to the ova file")]
    [string]
    $OVAPath,
    # datastore
    [Parameter(Mandatory=$true,HelpMessage="Datastore the ova/ovf will be deployed to")]
    [string]
    $datastore,
    # VMhost
    [Parameter(Mandatory=$true,HelpMessage="Need to figure out why this is needed; suspect needed for clusters without DRS enabled, or if DRS is set to manual")]
    [string]
    $vmhost,
    # Virtual machine name
    [Parameter(Mandatory=$true,HelpMessage="name of the deployed VM")]
    [string]
    $vmName
)
Connect-VIServer $vCenter
# Connect and collect data
$ova = $OVAPath
$cluster = Get-Cluster $cluster
$datastore = Get-Datastore -Name $datastore

# OVA configuration difficulties in native format; we changed to regular hastable with successful results
$config = Get-OvfConfiguration -Ovf $ova
$hash = $config.ToHashTable()

# Entered all configuration information
foreach($parameter in $hash.keys){

    # Entering the information into the hash table
    $answer = Read-Host -Prompt "Enter value for $parameter"
    $hash[$parameter] = $answer

}

# Execute ova/ovf deployment task
Import-VApp -Source $ova -Datastore $datastore -Location $cluster -Name $vmName -VMHost $vmhost -OvfConfiguration $hash