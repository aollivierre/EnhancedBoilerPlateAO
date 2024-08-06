function InstallAndImportModulesPSGallery {
    <#
    .SYNOPSIS
    Validates, installs, and imports required PowerShell modules specified in a PSD1 file.

    .DESCRIPTION
    This function reads the 'modules.psd1' file from the script's directory, validates the existence of the required modules,
    installs any that are missing, and imports the specified modules into the current session.

    .PARAMETER modulePsd1Path
    The path to the modules.psd1 file.

    .EXAMPLE
    InstallAndImportModulesPSGallery -modulePsd1Path "$PSScriptRoot\modules.psd1"
    This example reads the 'modules.psd1' file, installs any missing required modules, and imports the specified modules.

    .NOTES
    This function relies on a properly formatted 'modules.psd1' file in the script's root directory.
    The PSD1 file should have 'RequiredModules', 'ImportedModules', and 'MyModules' arrays defined.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$modulePsd1Path
    )

    begin {
        Write-EnhancedLog -Message "Starting InstallAndImportModulesPSGallery function" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Validate PSD1 file path
        if (-not (Test-Path -Path $modulePsd1Path)) {
            Write-EnhancedLog -Message "modules.psd1 file not found at path: $modulePsd1Path" -Level "ERROR"
            throw "modules.psd1 file not found."
        }

        Write-EnhancedLog -Message "Found modules.psd1 file at path: $modulePsd1Path" -Level "INFO"
    }

    process {
        try {
            # Read and import PSD1 data
            $moduleData = Import-PowerShellDataFile -Path $modulePsd1Path
            $requiredModules = $moduleData.RequiredModules
            $importedModules = $moduleData.ImportedModules
            $myModules = $moduleData.MyModules

            # Validate, Install, and Import Modules
            if ($requiredModules) {
                Write-EnhancedLog -Message "Installing required modules: $($requiredModules -join ', ')" -Level "INFO"
                foreach ($moduleName in $requiredModules) {
                    Update-ModuleIfOldOrMissing -ModuleName $moduleName
                }
            }

            if ($importedModules) {
                Write-EnhancedLog -Message "Importing modules: $($importedModules -join ', ')" -Level "INFO"
                foreach ($moduleName in $importedModules) {
                    Import-Module -Name $moduleName -Force
                }
            }

            if ($myModules) {
                Write-EnhancedLog -Message "Importing custom modules: $($myModules -join ', ')" -Level "INFO"
                foreach ($moduleName in $myModules) {
                    Import-Module -Name $moduleName -Force
                }
            }

            Write-EnhancedLog -Message "Modules installed and imported successfully." -Level "INFO"
        }
        catch {
            Write-EnhancedLog -Message "Error processing modules.psd1: $_" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_
        }
    }

    end {
        Write-EnhancedLog -Message "InstallAndImportModulesPSGallery function execution completed." -Level "INFO"
    }
}