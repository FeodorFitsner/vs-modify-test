#
# The list of VS 2019 components: https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?vs-2019&view=vs-2019
#

Function InstallVS
{
  Param
  (
    [String]$WorkLoads,
    [String]$Sku,
    [String] $VSBootstrapperURL
  )

  $exitCode = -1

  try
  {
    Write-Host "Downloading Bootstrapper ..."
    Invoke-WebRequest -Uri $VSBootstrapperURL -OutFile "${env:Temp}\vs_$Sku.exe"

    $FilePath = "${env:Temp}\vs_$Sku.exe"
    $Arguments = ('modify', $WorkLoads, '--quiet', '--norestart', '--wait', '--nocache')

    Write-Host "Starting Install ..."
    $process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -Wait -PassThru
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0 -or $exitCode -eq 3010)
    {
      Write-Host -Object 'Installation successful'
      return $exitCode
    }
    else
    {
      Write-Host -Object "Non zero exit code returned by the installation process : $exitCode."

      # this wont work because of log size limitation in extension manager
      # Get-Content $customLogFilePath | Write-Host

      exit $exitCode
    }
  }
  catch
  {
    Write-Host -Object "Failed to install Visual Studio. Check the logs for details in $customLogFilePath"
    Write-Host -Object $_.Exception.Message
    exit -1
  }
}

$WorkLoads = '--add Component.MDD.Linux '

$Sku = 'Community'

if ($env:install_vs2019_preview) {
	Write-Host "Installing from 'Preview' channel"
	$VSBootstrapperURL = 'https://aka.ms/vs/16/pre/vs_community.exe'
} else {
	Write-Host "Installing from 'Release' channel"
	$VSBootstrapperURL = 'https://aka.ms/vs/16/release/vs_community.exe'
}

$ErrorActionPreference = 'Stop'

# Install VS
$exitCode = InstallVS -WorkLoads $WorkLoads -Sku $Sku -VSBootstrapperURL $VSBootstrapperURL
