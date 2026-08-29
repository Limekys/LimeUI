# Set error handling policy to stop on errors
$ErrorActionPreference = "Stop"

# Get environment variables from GameMaker Studio
$YYMACROS_project_full_filename = $env:YYMACROS_project_full_filename
$YYruntimeLocation = $env:YYruntimeLocation
$YYtempFolder = $env:YYtempFolder
$YYoutputFolder = $env:YYoutputFolder
$YYPLATFORM_name = $env:YYPLATFORM_name
$YYEXTOPT_NOGX_Enable = $env:YYEXTOPT_NOGX_Enable

Write-Host "[NOGX] pre_build_step"

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
if ([string]::IsNullOrWhiteSpace($YYMACROS_project_full_filename)) {
	Write-Error "[NOGX] ERROR: YYMACROS_project_full_filename environment variable is not set."
	exit 1
}

if ([string]::IsNullOrWhiteSpace($YYtempFolder)) {
	Write-Error "[NOGX] ERROR: YYtempFolder environment variable is not set."
	exit 1
}

<#
.SYNOPSIS
    Validates and cleans JSON content by removing trailing commas.
.DESCRIPTION
    Removes trailing commas before closing braces and brackets to fix common JSON formatting issues.
#>
function Validate-Json {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$jsonContent
	)
	
	try {
		if ([string]::IsNullOrWhiteSpace($jsonContent)) {
			Write-Warning "[NOGX] Validate-Json: JSON content is empty."
			return $jsonContent
		}
		
		# Remove trailing commas before closing braces and brackets
		$jsonContentOut = $jsonContent -replace ',\s*}', '}'
		$jsonContentOut = $jsonContentOut -replace ',\s*]', ']'
		return $jsonContentOut
	}
	catch {
		Write-Error "[NOGX] Validate-Json failed: $_"
		throw
	}
}

<#
.SYNOPSIS
    Extracts all GameMaker extension filenames from a project file.
.DESCRIPTION
    Reads the project JSON file and returns an array of full paths to all extension files.
#>
function Get-AllGMExtensionFilenames {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$projectFullFilename
	)
	
	try {
		# Validate that the project file exists
		if (-not (Test-Path -Path $projectFullFilename -PathType Leaf)) {
			Write-Error "[NOGX] Get-AllGMExtensionFilenames: Project file not found: '$projectFullFilename'"
			throw "Project file not found: '$projectFullFilename'"
		}
		
		# Read and parse the project JSON file
		$jsonContent = Get-Content -Raw -Path "$projectFullFilename" -ErrorAction Stop
		$jsonContent = Validate-Json -jsonContent "$jsonContent"
		
		$jsonStruct = $jsonContent | ConvertFrom-Json -ErrorAction Stop
		
		if ($null -eq $jsonStruct) {
			Write-Error "[NOGX] Get-AllGMExtensionFilenames: Failed to parse JSON from project file."
			throw "Failed to parse JSON"
		}
		
		$resources = $jsonStruct.resources
		
		if ($null -eq $resources) {
			Write-Warning "[NOGX] Get-AllGMExtensionFilenames: No resources found in project file."
			return @()
		}
		
		# Extract extension file paths from resources
		$filenames = @()
		$directory = Split-Path -Path $projectFullFilename
		
		foreach ($item in $resources) {
			# Validate that the resource item has a valid path structure
			$hasValidPath = $null -ne $item `
				-and $null -ne $item.id `
				-and $null -ne $item.id.path
			
			if (-not $hasValidPath) {
				continue
			}
			
			# Only process items that are in the extensions folder
			if ($item.id.path.StartsWith('extensions/')) {
				$extPath = ($item.id.path).Replace("/", "\")
				$fullPath = [System.IO.Path]::Combine($directory, $extPath)
				$filenames += $fullPath
			}
		}
		
		return $filenames
	}
	catch {
		Write-Error "[NOGX] Get-AllGMExtensionFilenames failed: $_"
		throw
	}
}

<#
.SYNOPSIS
    Extracts HTML5 code injection from a GameMaker extension file.
.DESCRIPTION
    Reads an extension JSON file and returns the HTML5CodeInjection content if the extension
    is configured for Opera GX platform (bit 34 in copyToTargets flags).
#>
function Get-HTML5CodeInjectionFromGMExt {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$extensionFilename
	)
	
	try {
		# Validate that the extension file exists
		if (-not (Test-Path -Path $extensionFilename -PathType Leaf)) {
			Write-Warning "[NOGX] Get-HTML5CodeInjectionFromGMExt: Extension file not found: '$extensionFilename'"
			return ""
		}
		
		# Read and parse the extension JSON file
		$jsonContent = Get-Content -Raw -Path "$extensionFilename" -ErrorAction Stop
		$jsonContent = Validate-Json -jsonContent "$jsonContent"
		$jsonStruct = $jsonContent | ConvertFrom-Json -ErrorAction Stop
		
		if ($null -eq $jsonStruct) {
			Write-Warning "[NOGX] Get-HTML5CodeInjectionFromGMExt: Failed to parse JSON from extension file: '$extensionFilename'"
			return ""
		}
		
		# Check if the extension is configured
		$platformMask = 1L -shl 34 # for Opera GX platform (bit 34)
		if($isHTML5) {
			$platformMask = 1L -shl 5 # for HTML5 (bit 5)
		}
		
		if ($null -eq $jsonStruct.copyToTargets) {
			return ""
		}
		
		# Check if the flag is set and HTML5 properties exist
		$copyToTargetsFlags = [Int64]$jsonStruct.copyToTargets
		$hasFlag = ($copyToTargetsFlags -band $platformMask) -ne 0
		$hasHtml5Props = $null -ne $jsonStruct.html5Props
		
		# Return HTML5 code injection if conditions are met
		if ($hasHtml5Props -and $hasFlag) {
			if ($null -ne $jsonStruct.HTML5CodeInjection) {
				return $jsonStruct.HTML5CodeInjection
			}
		}
		
		return ""
	}
	catch {
		Write-Warning "[NOGX] Get-HTML5CodeInjectionFromGMExt failed for '$extensionFilename': $_"
		return ""
	}
}

<#
.SYNOPSIS
    Accumulates all HTML5 code injections from extension files and processes them.
.DESCRIPTION
    Collects HTML5 code injections from all extension files, replaces variables,
    parses XML content, and groups elements by name for injection into the HTML file.
#>
function Accumulate-AllHTML5CodeInjections {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string[]]$extensionFilenames
	)
	
	try {
		# Collect all injections from extension files
		$allInjectors = $extensionFilenames | ForEach-Object {
			Get-HTML5CodeInjectionFromGMExt -extensionFilename $_
		}
		$allInjectors = $allInjectors -join ''
		
		# Initialize variables for substitution
		$GM_HTML5_BrowserTitle = $env:YYPLATFORM_option_operagx_game_name
		if($isHTML5) {
			$GM_HTML5_BrowserTitle = $env:YYPLATFORM_option_html5_browser_title
		}
		
		if ([string]::IsNullOrWhiteSpace($GM_HTML5_BrowserTitle)) {
			$GM_HTML5_BrowserTitle = "Game"
		}
		
		$GM_HTML5_BackgroundColour = "#000000"
		$GM_HTML5_GameWidth = "640"
		$GM_HTML5_GameHeight = "360"
		$GM_HTML5_GameFolder = $env:YYPLATFORM_option_html5_foldername
		$GM_HTML5_GameFilename = "$env:YYprojectName.js"
		$GM_HTML5_CacheBust = "$(Get-Random)"
		$GM_HTML5_InjectCenterStyle = ""
		
		if($env:YYPLATFORM_option_html5_centregame -ieq "True") {
			$GM_HTML5_InjectCenterStyle = 'style="position: absolute; top: 50%; left: 50%; bottom: -50%; right: -50%; transform: translate(-50%, -50%);"'
		}
		
		$GM_HTML5_InjectDisableCache = ""
		$GM_HTML5_InjectFlurryAnalytics = ""
		$GM_HTML5_InjectSplashScreen = ""
		$GM_HTML5_InjectRunnerPath = ""
		$GM_HTML5_InjectGoogleAnalytics = ""
		
		# Replace standard variables in injections
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_BrowserTitle}", $GM_HTML5_BrowserTitle)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_BackgroundColour}", $GM_HTML5_BackgroundColour)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_GameWidth}", $GM_HTML5_GameWidth)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_GameHeight}", $GM_HTML5_GameHeight)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_GameFolder}", $GM_HTML5_GameFolder)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_GameFilename}", $GM_HTML5_GameFilename)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_CacheBust}", $GM_HTML5_CacheBust)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_InjectCenterStyle}", $GM_HTML5_InjectCenterStyle)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_InjectDisableCache}", $GM_HTML5_InjectDisableCache)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_InjectFlurryAnalytics}", $GM_HTML5_InjectFlurryAnalytics)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_InjectSplashScreen}", $GM_HTML5_InjectSplashScreen)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_InjectRunnerPath}", $GM_HTML5_InjectRunnerPath)
		$allInjectors = $allInjectors.Replace("`${GM_HTML5_InjectGoogleAnalytics}", $GM_HTML5_InjectGoogleAnalytics)
		
		# Replace extension option environment variables (YYEXTOPT_*)
		$extensionOptions = (Get-ChildItem Env: | Where-Object Name -like 'YYEXTOPT_*').Name
		
		foreach ($optionName in $extensionOptions) {
			try {
				$optionValue = (Get-Item "env:$optionName").Value
				if ($null -ne $optionValue) {
					$allInjectors = $allInjectors.Replace("`${$optionName}", $optionValue)
				}
			}
			catch {
				Write-Warning "[NOGX] Failed to get environment variable '$optionName': $_"
			}
		}
		
		# Parse XML content from injections
		try {
			[xml]$xmlDoc = "<content>$allInjectors</content>"
		}
		catch {
			Write-Warning "[NOGX] Failed to parse XML from injections. Using empty groups. Error: $_"
			$xmlDoc = [xml]"<content></content>"
		}
		
		# Group XML elements by name
		$groups = @{}
		
		$hasValidXmlContent = $null -ne $xmlDoc `
			-and $null -ne $xmlDoc.content `
			-and $null -ne $xmlDoc.content.ChildNodes
		
		if ($hasValidXmlContent) {
			foreach ($node in $xmlDoc.content.ChildNodes) {
				# Skip non-element nodes
				if ($node.NodeType -ne 'Element') {
					continue
				}
				
				$nodeName = $node.LocalName
				if ([string]::IsNullOrWhiteSpace($nodeName)) {
					continue
				}
				
				# Initialize array for this node name if it doesn't exist
				if (-not $groups.ContainsKey($nodeName)) {
					$groups[$nodeName] = @()
				}
				
				# Decode HTML entities and add to group
				try {
					$decodedContent = [System.Net.WebUtility]::HtmlDecode($node.InnerXML)
					$groups[$nodeName] += $decodedContent
				}
				catch {
					Write-Warning "[NOGX] Failed to decode HTML for node '$nodeName': $_"
					$groups[$nodeName] += $node.InnerXML
				}
			}
		}
		
		# Add standard variables to groups for injection
		$groups["GM_HTML5_BrowserTitle"] = $GM_HTML5_BrowserTitle
		$groups["GM_HTML5_BackgroundColour"] = $GM_HTML5_BackgroundColour
		$groups["GM_HTML5_GameWidth"] = $GM_HTML5_GameWidth
		$groups["GM_HTML5_GameHeight"] = $GM_HTML5_GameHeight
		$groups["GM_HTML5_GameFolder"] = $GM_HTML5_GameFolder
		$groups["GM_HTML5_GameFilename"] = $GM_HTML5_GameFilename
		$groups["GM_HTML5_CacheBust"] = $GM_HTML5_CacheBust
		$groups["GM_HTML5_InjectCenterStyle"] = $GM_HTML5_InjectCenterStyle
		$groups["GM_HTML5_InjectDisableCache"] = $GM_HTML5_InjectDisableCache
		$groups["GM_HTML5_InjectFlurryAnalytics"] = $GM_HTML5_InjectFlurryAnalytics
		$groups["GM_HTML5_InjectSplashScreen"] = $GM_HTML5_InjectSplashScreen
		$groups["GM_HTML5_InjectRunnerPath"] = $GM_HTML5_InjectRunnerPath
		$groups["GM_HTML5_InjectGoogleAnalytics"] = $GM_HTML5_InjectGoogleAnalytics
		
		return $groups
	}
	catch {
		Write-Error "[NOGX] Accumulate-AllHTML5CodeInjections failed: $_"
		throw
	}
}

<#
.SYNOPSIS
    Injects variable values into a text file and saves the result.
.DESCRIPTION
    Reads an input file, replaces placeholders in the format ${VariableName} with values
    from the injections hashtable, and writes the result to an output file.
#>
function Inject-TextFile {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$inputFilename,
		
		[Parameter(Mandatory)]
		[string]$outputFilename,
		
		[Parameter(Mandatory)]
		[hashtable]$injections
	)
	
	try {
		# Validate that the input file exists
		if (-not (Test-Path -Path $inputFilename -PathType Leaf)) {
			Write-Error "[NOGX] Inject-TextFile: Input file not found: '$inputFilename'"
			throw "Input file not found: '$inputFilename'"
		}
		
		# Create output directory if it doesn't exist
		$outputDirectory = Split-Path -Path $outputFilename -Parent
		$directoryExists = -not [string]::IsNullOrWhiteSpace($outputDirectory) `
			-and (Test-Path -Path $outputDirectory -PathType Container)
		
		if (-not $directoryExists -and -not [string]::IsNullOrWhiteSpace($outputDirectory)) {
			New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
		}
		
		# Read input file content
		$content = Get-Content -Raw -Path $inputFilename -Encoding utf8 -ErrorAction Stop
		
		if ($null -eq $content) {
			$content = ""
		}
		
		# Replace all placeholders with values from injections hashtable
		if ($null -ne $injections) {
			$injections.GetEnumerator() | ForEach-Object {
				$key = $_.Key
				$value = if ($null -eq $_.Value) { "" } else { "$($_.Value)" }
				$content = $content.Replace("`${$key}", $value)
			}
		}
		
		# Write the processed content to output file
		$content | Out-File -FilePath $outputFilename -Encoding utf8 -ErrorAction Stop
	}
	catch {
		Write-Error "[NOGX] Inject-TextFile failed: $_"
		throw
	}
}

# Main execution block
try {
	if($isHTML5 -and $env:YYEXTOPT_NOGX_EnableInjectionsForHTML5 -ne "True") {
		Write-Host "[NOGX] Aborting: There's nothing to do in HTML5 target."
		exit 0
	}
	
	# Step 1: Get list of extension filenames from project file
	Write-Host "[NOGX] Getting all extension filenames from '$YYMACROS_project_full_filename'"
	$extensionFilenames = Get-AllGMExtensionFilenames -projectFullFilename $YYMACROS_project_full_filename
	Write-Host "[NOGX] Extensions found: $($extensionFilenames.Count)"
	if ($extensionFilenames.Count -gt 0) {
		$extensionFilenames | ForEach-Object { Write-Host "  - $_" }
	}

	# Step 2: Accumulate all HTML injections from extensions
	Write-Host "[NOGX] Accumulating all HTML injections:"
	$injections = Accumulate-AllHTML5CodeInjections -extensionFilenames $extensionFilenames
	if ($null -ne $injections) {
		$injections.GetEnumerator() | ForEach-Object {
			$displayValue = if ($_.Value -is [Array]) { 
				$_.Value -join ", " 
			} 
			else { 
				$_.Value 
			}
			Write-Host "  `$$($($_.Key)) : $displayValue"
		}
	}

	# Step 3: Determine source index.html file (custom or default)
	$sourceFile = ""
	
	if ($isHTML5) {
		if($env:YYPLATFORM_option_html5_index -ne 'use_default') {
			$subpath = $env:YYPLATFORM_option_html5_index.Replace("datafiles/", "")
			$sourceFile = [System.IO.Path]::Combine($env:YYprojectDir, "datafiles", $subpath)
			Write-Host "[NOGX] Using custom index.html from datafiles directory ('$subpath')"
		}
		else {
			$sourceFile = [System.IO.Path]::Combine($YYruntimeLocation, "html5", "index.html")
			Write-Host "[NOGX] Using default index.html from HTML5 runtime"
		}
	}
	elseif ($isOperaGxPlatform) {
		$webfilesDir = [System.IO.Path]::Combine($PSScriptRoot, "..", "..", "webfiles")
		$customIndexFile = [System.IO.Path]::GetFullPath(
			[System.IO.Path]::Combine($webfilesDir, "index.html")
		)
		
		if (Test-Path $customIndexFile -PathType Leaf) {
			$sourceFile = $customIndexFile
			Write-Host "[NOGX] Using custom index.html from webfiles directory"
		}
		else {
			$sourceFile = [System.IO.Path]::Combine($PSScriptRoot, "index.html")
			Write-Host "[NOGX] Using default index.html from extension directory"
		}
	}

	# Validate that source file exists
	if (-not (Test-Path $sourceFile -PathType Leaf)) {
		Write-Error "[NOGX] ERROR: Source index.html file not found: '$sourceFile'"
		exit 1
	}

	# Step 4: Perform injection and save result
	$outputFilename = [System.IO.Path]::Combine($YYtempFolder, "NOGX_index.html")
	Write-Host "[NOGX] Injecting into 'index.html' ('$sourceFile' -> '$outputFilename')"
	
	Inject-TextFile -inputFilename $sourceFile -outputFilename $outputFilename -injections $injections

	Write-Host "[NOGX] The injection is complete. The resulting file is in '$outputFilename'"
	exit 0
}
catch {
	Write-Error "[NOGX] FATAL ERROR: $_"
	Write-Error "[NOGX] Stack trace: $($_.ScriptStackTrace)"
	exit 1
}

