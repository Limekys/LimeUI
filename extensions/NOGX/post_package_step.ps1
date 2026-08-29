# Set error handling policy to stop on errors
$ErrorActionPreference = "Stop"

# Get environment variables from GameMaker Studio
$YYPLATFORM_name = $env:YYPLATFORM_name
$YYtargetFile = $env:YYtargetFile
$YYtargetType = $env:YYtargetType
$YYprojectName = $env:YYprojectName
$YYTARGET_runtime = $env:YYTARGET_runtime
$YYtempFolder = $env:YYtempFolder
$YYEXTOPT_NOGX_Enable = $env:YYEXTOPT_NOGX_Enable
$YYEXTOPT_NOGX_YaFix = $env:YYEXTOPT_NOGX_YaFix
$YYEXTOPT_NOGX_ReplaceAlertOnError = $env:YYEXTOPT_NOGX_ReplaceAlertOnError

Write-Host "[NOGX] post_package_step"

# Check if extension is enabled
if ($YYEXTOPT_NOGX_Enable -ne "True") {
	Write-Host "[NOGX] The extension is disabled."
	exit 0
}

Write-Host "[NOGX] Current platform: $YYPLATFORM_name"

# Check if the current platform is Opera GX or HTML5
$isOperaGxPlatform = $YYPLATFORM_name -ieq "Opera GX" -or $YYPLATFORM_name -ieq "operagx"
$isHTML5 = $YYPLATFORM_name -ieq "html5"
if (-not ($isOperaGxPlatform -or $isHTML5)) {
	Write-Host "[NOGX] Aborting: This script is only for Opera GX and HTML5 platform."
	exit 0
}

# Validate required environment variables
if ([string]::IsNullOrWhiteSpace($YYtargetFile)) {
	Write-Error "[NOGX] ERROR: YYtargetFile environment variable is not set."
	exit 1
}

if ([string]::IsNullOrWhiteSpace($YYprojectName)) {
	Write-Error "[NOGX] ERROR: YYprojectName environment variable is not set."
	exit 1
}

if ([string]::IsNullOrWhiteSpace($YYTARGET_runtime)) {
	Write-Error "[NOGX] ERROR: YYTARGET_runtime environment variable is not set."
	exit 1
}

if ([string]::IsNullOrWhiteSpace($YYtempFolder)) {
	Write-Error "[NOGX] ERROR: YYtempFolder environment variable is not set."
	exit 1
}

# Load required assemblies for ZIP file operations
Add-Type -AssemblyName System.IO.Compression -ErrorAction Stop
Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop

<#
.SYNOPSIS
    Removes a file from a ZIP archive.
.DESCRIPTION
    Deletes an entry from the ZIP archive if it exists.
#>
function RemoveFile-Zip {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[System.IO.Compression.ZipArchive]$Zip,
		
		[Parameter(Mandatory)]
		[string]$FileName
	)
	
	try {
		Write-Host "[NOGX] Remove '$FileName'"
		$entry = $Zip.GetEntry($FileName)
		if ($null -ne $entry) {
			$entry.Delete()
		}
	}
	catch {
		Write-Warning "[NOGX] Failed to remove file '$FileName' from ZIP: $_"
	}
}

<#
.SYNOPSIS
    Renames a file within a ZIP archive.
.DESCRIPTION
    Creates a new entry with the new name, copies content from the old entry, and deletes the old entry.
#>
function RenameFile-Zip {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[System.IO.Compression.ZipArchive]$Zip,
		
		[Parameter(Mandatory)]
		[string]$OldName,
		
		[Parameter(Mandatory)]
		[string]$NewName
	)
	
	try {
		Write-Host "[NOGX] Rename '$OldName' -> '$NewName'"
		$entry = $Zip.GetEntry($OldName)
		if ($null -ne $entry) {
			# Read content from old entry
			$stream = $entry.Open()
			$memoryStream = New-Object System.IO.MemoryStream
			$stream.CopyTo($memoryStream)
			$stream.Close()
			$memoryStream.Position = 0
			
			# Create new entry with new name
			$newEntry = $Zip.CreateEntry($NewName)
			$newStream = $newEntry.Open()
			$memoryStream.CopyTo($newStream)
			$newStream.Close()
			$memoryStream.Dispose()
			
			# Delete old entry
			$entry.Delete()
		}
	}
	catch {
		Write-Error "[NOGX] Failed to rename file '$OldName' to '$NewName' in ZIP: $_"
		throw
	}
}

# Main execution block
$zip = $null
try {
	if($isHTML5 -and $env:YYEXTOPT_NOGX_EnableInjectionsForHTML5 -ne "True") {
		Write-Host "[NOGX] Aborting: There's nothing to do in HTML5 target."
		exit 0
	}
	
	# Step 1: Show info
	Write-Host "[NOGX] Project name: $YYprojectName"
	Write-Host "[NOGX] Target runtime: $YYTARGET_runtime"
	Write-Host "[NOGX] Target file: $YYtargetFile"
	Write-Host "[NOGX] Target type: $YYtargetType"
	
	# Step 2: Validate that the processed index.html file exists
	$sourceFile = [System.IO.Path]::Combine($YYtempFolder, "NOGX_index.html")
	if (-not (Test-Path -Path $sourceFile -PathType Leaf)) {
		Write-Error "[NOGX] ERROR: Processed index.html file does not exist: '$sourceFile'"
		Write-Error "[NOGX] Make sure pre_build_step.ps1 completed successfully."
		exit 1
	}
	
	if($isHTML5) {
		# Step 3: Override index.html
		if($YYtargetType -ieq "folder") {
			if (-not (Test-Path -Path $YYtargetFile -PathType Container)) {
				Write-Error "[NOGX] ERROR: Target file not found: '$YYtargetFile'"
				exit 1
			}
			
			$indexFile = [System.IO.Path]::Combine($YYtargetFile, $env:YYPLATFORM_option_html5_outputname)
			Write-Host "[NOGX] Overriding '$indexFile' by '$sourceFile'"
			Copy-Item -Path $sourceFile -Destination $indexFile -Force -ErrorAction Stop
			Write-Host "[NOGX] Done!"
			exit 0
		}
		elseif ($YYtargetType -ieq "zip") {
			if (-not (Test-Path -Path $YYtargetFile -PathType Leaf)) {
				Write-Error "[NOGX] ERROR: Target file not found: '$YYtargetFile'"
				exit 1
			}
			
			Write-Host "[NOGX] Repackaging target file..."
			$zip = [System.IO.Compression.ZipFile]::Open($YYtargetFile, 'Update')
			
			RemoveFile-Zip -Zip $zip -FileName $env:YYPLATFORM_option_html5_outputname
			
			$indexFile = $env:YYPLATFORM_option_html5_outputname
			Write-Host "[NOGX] Adding new '$indexFile' from '$sourceFile'"
			[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $sourceFile, $env:YYPLATFORM_option_html5_outputname) | Out-Null
			
			$zip.Dispose()
			Write-Host "[NOGX] Repackaging complete!"
			exit 0
		}
		else {
			Write-Error "[NOGX] Unknown target type '$YYtargetType'."
			exit 1
		}
	}
	elseif($isOperaGxPlatform) {
		if (-not (Test-Path -Path $YYtargetFile -PathType Leaf)) {
			Write-Error "[NOGX] ERROR: Target file not found: '$YYtargetFile'"
			exit 1
		}
		
		$webfilesDir = [System.IO.Path]::Combine($PSScriptRoot, "..", "..", "webfiles")
		$webfilesDir = [System.IO.Path]::GetFullPath($webfilesDir)
		Write-Host "[NOGX] Webfiles dir: $webfilesDir"
		
		# Step 3: Open ZIP archive for modification
		Write-Host "[NOGX] Repackaging target file..."
		$zip = [System.IO.Compression.ZipFile]::Open($YYtargetFile, 'Update')
		
		# Step 4: Remove extra files from ZIP archive
		RemoveFile-Zip -Zip $zip -FileName "index.html"
		
		# Step 5: Process files based on runtime target
		if ($YYTARGET_runtime -ieq "YYC") {
			# YYC (YoYo Compiler) runtime: remove unnecessary files and rename JS file
			RemoveFile-Zip -Zip $zip -FileName "runner.html"
			RemoveFile-Zip -Zip $zip -FileName "runner.json"
			RemoveFile-Zip -Zip $zip -FileName "run.xml"
			RemoveFile-Zip -Zip $zip -FileName "runner-sw.js"
			RemoveFile-Zip -Zip $zip -FileName "$YYprojectName.html"
			RenameFile-Zip -Zip $zip -OldName "$YYprojectName.js" -NewName "runner.js"
		}
		elseif ($YYTARGET_runtime -ieq "VM") {
			# VM (Virtual Machine) runtime: remove runner.json
			RemoveFile-Zip -Zip $zip -FileName "runner.json"
		}
		else {
			$zip.Dispose()
			Write-Error "[NOGX] ERROR: Unknown runtime target '$YYTARGET_runtime'."
			Write-Error "[NOGX] Supported runtime targets: YYC, VM"
			exit 1
		}
		
		# Step 6: Patch runner.js
		if ($YYEXTOPT_NOGX_YaFix -eq "True" -or $YYEXTOPT_NOGX_ReplaceAlertOnError -eq "True") {
			Write-Host "[NOGX] Patching 'runner.js'"
			$entryPath = "runner.js"
			$entry = $zip.GetEntry($entryPath)
			
			if ($null -ne $entry) {
				$encoding = [System.Text.Encoding]::UTF8
				
				# Read content from runner.js
				$stream = $entry.Open()
				$reader = New-Object System.IO.StreamReader($stream, $encoding)
				$content = $reader.ReadToEnd()
				$reader.Dispose()
				$stream.Dispose()
				$entry.Delete()
				
				$updatedContent = $content
				
				# Fix "Ya" variable conflict if enabled
				if ($YYEXTOPT_NOGX_YaFix -eq "True") {
					Write-Host "[NOGX] Apply 'YaFix'"
					# Apply replacements to fix Ya variable conflict:
					# 1. Replace "Ya" -> "Yv" globally
					# 2. Replace WebAssembly.instantiate(d,b) with wrapper that sets Ya=Yv
					# 3. Replace WebAssembly.instantiateStreaming patterns with wrappers
					
					$updatedContent = $updatedContent -creplace '(?<![a-zA-Z0-9_])Ya(?![a-zA-Z0-9_])', 'Yv'
					
					$updatedContent = $updatedContent.Replace(
							'WebAssembly.instantiate(d,b)',
							'WebAssembly.instantiate(d,(b.a.Ya=b.a.Yv,b))'
						)
					$updatedContent = $updatedContent.Replace(
							'WebAssembly.instantiateStreaming(d,a)',
							'WebAssembly.instantiateStreaming(d,(a.a.Ya=a.a.Yv,a))'
						)
				}
				
				# Replace "alert" -> "console.error" in window.onerror
				if ($YYEXTOPT_NOGX_ReplaceAlertOnError -eq "True") {
					Write-Host "[NOGX] Apply 'ReplaceAlertOnError'"
					
					$updatedContent = $updatedContent.Replace(
							'alert("Error occured: "+a)',
							'console.error("Error occured: "+a)'
						)
				}

				# Removing the "Downloading data..."
				$updatedContent = $updatedContent.Replace(
					'k.setStatus&&k.setStatus(`Downloading data... (${B}/${r})`)',
					'0'
				)
				$updatedContent = $updatedContent.Replace(
					'k.setStatus&&k.setStatus("Downloading data...")',
					'0'
				)
				
				# Write updated content to temporary file and add to ZIP
				$tempFile = [System.IO.Path]::GetTempFileName()
				try {
					[System.IO.File]::WriteAllText($tempFile, $updatedContent, $encoding)
					[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $tempFile, (Split-Path $entryPath -Leaf)) | Out-Null
				}
				catch {
					Write-Error "[NOGX] ERROR: Failed to patch runner.js: $_"
					throw
				}
				finally {
					if (Test-Path -Path $tempFile) {
						Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
					}
				}
				
				Write-Host "[NOGX] runner.js patching complete!"
			}
			else {
				Write-Warning "[NOGX] runner.js not found in ZIP archive."
			}
		}
		
		# Step 7: Add files from 'webfiles' folder if it exists
		if (Test-Path -Path $webfilesDir -PathType Container) {
			Write-Host "[NOGX] Adding 'webfiles' folder content."
			Push-Location -Path $webfilesDir
			try {
				$files = Get-ChildItem -Recurse -File -ErrorAction Stop
				
				foreach ($file in $files) {
					# Calculate relative path and normalize to forward slashes
					$relativePath = Resolve-Path -Path $file.FullName -Relative
					$relativePath = $relativePath.Substring(2).Replace('\', '/')
					
					# Remove existing entry if it exists
					$entry = $zip.GetEntry($relativePath)
					if ($null -ne $entry) {
						$entry.Delete()
					}
					
					# Add file to ZIP archive
					Write-Host "[NOGX] Adding '$relativePath'"
					[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $relativePath) | Out-Null
				}
			}
			catch {
				Write-Error "[NOGX] ERROR: Failed to add webfiles folder content: $_"
				throw
			}
			finally {
				Pop-Location
			}
		}
		else {
			Write-Host "[NOGX] 'webfiles' folder does not exist. Skipping."
		}
		
		# Remove existing index.html and add the processed one
		RemoveFile-Zip -Zip $zip -FileName "index.html"
		Write-Host "[NOGX] Add processed 'index.html'"
		[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $sourceFile, "index.html") | Out-Null
		
		# Step 8: Close and save ZIP archive
		$zip.Dispose()
		
		Write-Host "[NOGX] Repackaging complete!"
		exit 0
	}
}
catch {
	# Ensure ZIP archive is disposed even on error
	if ($null -ne $zip) {
		try {
			$zip.Dispose()
		}
		catch {
			# Ignore disposal errors
		}
	}
	
	Write-Error "[NOGX] FATAL ERROR: $_"
	Write-Error "[NOGX] Stack trace: $($_.ScriptStackTrace)"
	exit 1
}

