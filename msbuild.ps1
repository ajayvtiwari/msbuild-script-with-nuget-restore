    $msbuild = 'C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe'
    $NUGETLOCATION = 'C:\nuget.exe'
    
    Function Get-FileName($initialDirectory)             
    {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "SLN (*.sln)| *.sln"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    }

     Function RestoreAllPackages ($baseDir)
	{
		Write-Host "Starting Package Restore - This may take a few minutes ..."
		$PACKAGECONFIGS = Get-ChildItem -Recurse -Force $BaseDirectory -ErrorAction SilentlyContinue | 
			Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -eq "packages.config")}
		ForEach($PACKAGECONFIG in $PACKAGECONFIGS)
			{
				Write-Host $PACKAGECONFIG.FullName
				$NugetRestore = $NUGETLOCATION + " restore " + " '" + $PACKAGECONFIG.FullName + "' -OutputDirectory '" + $PACKAGECONFIG.Directory.parent.FullName + "\packages'"
				Write-Host $NugetRestore
				Invoke-Expression $NugetRestore
			}
	}
    
    Clear-Host
    Write-host " Open a Solution to build" -ForegroundColor Red -BackgroundColor White
    $inputfile = Get-FileName "C:\projects"  # Accept the Solution to build

    $baseDir = Split-Path -Path $inputfile                               # get the base directory
    $Projectname = [io.path]::GetFileNameWithoutExtension("$inputfile")  # get the project name
    $Solutionname = Split-Path -Path $inputfile -Leaf                    # get the solution filename

    Write-host "The solution root is $baseDir"

    # make sure our working directory is correct
     cd $baseDir

    RestoreAllPackages $SOLUTIONROOT                             # restoring Packages 

    Write-Host "Cleaning $($Solutionname)" -foregroundcolor green
         & "$($msbuild)" "$($Solutionname)" /t:Clean /m
    Write-Host "Building $($Solutionname)" -foregroundcolor green
         & "$($msbuild)" "$($Solutionname)" /t:Build /m







