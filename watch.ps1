$ErrorActionPreference = "Stop"

[char]$e = 0x1b

function Get-Bytes {
	param (
		[Parameter(Mandatory=$true)]
		[string]$String
	)

	#return [Byte[]]([char[]]$String)
	return [System.Text.Encoding]::UTF8.GetBytes($String)
}

# https://en.wikipedia.org/wiki/Control_Pictures
[hashtable]$controlPicturesMap = @{
	[char]0  = "␀"
	[char]1  = "␁"
	[char]2  = "␂"
	[char]3  = "␃"
	[char]4  = "␄"
	[char]5  = "␅"
	[char]6  = "␆"
	[char]7  = "␇"
	[char]8  = "␈"
	[char]9  = "␉"
	[char]10 = "␊"
	[char]11 = "␋"
	[char]12 = "␌"
	[char]13 = "␍"
	[char]14 = "␎"
	[char]15 = "␏"
	[char]16 = "␐"
	[char]17 = "␑"
	[char]18 = "␒"
	[char]19 = "␓"
	[char]20 = "␔"
	[char]21 = "␕"
	[char]22 = "␖"
	[char]23 = "␗"
	[char]24 = "␘"
	[char]25 = "␙"
	[char]26 = "␚"
	[char]27 = "␛"
	[char]28 = "␜"
	[char]29 = "␝"
	[char]30 = "␞"
	[char]31 = "␟"
	[char]32 = "␠"
	[char]127 = "␡"
}

function Write-Log {
	param (
		#[Parameter(Mandatory=$true)]
		[string]$Message,
		[string]$Prefix = "$e[1;35m>>>$e[22;39m ",
		[string]$Suffix = ""
	)

	Write-Host "${Prefix}${Message}${Suffix}"
}

function Get-Repr {
	param (
		[Parameter(Mandatory=$true)]
		$Value
	)

	if ($Value -is [string]) {
		$quote = '"'

		$valueEscaped = $Value -replace '"', ("$e[1m``${quote}$e[0m")
		foreach ($pair in $controlPicturesMap) {
			[char]$key   = $pair.Name
			[string]$val = $pair.Value
			#Write-Host "  - '[char]$([Byte]${key})' = '${val}'"

			$valueEscaped = $valueEscaped -replace $key, ("$e[1m${val}$e[0m")
		}

		return "$e[33m${quote}${valueEscaped}${quote}$e[39m"
	}

	return "${Value}"
}

function Write-Variable {
	param (
		[Parameter(Mandatory=$true)]
		[string]$Name
	)

	$value = (Get-Variable -Name $Name -ValueOnly)
	$type  = ($value.GetType())

	$equals = "$e[1;35m=$e[22;39m"

	$typeString = "$e[33m[$e[34m${type}$e[33m]$e[39m"
	$nameString = "$e[36m`$${Name}$e[39m"
	$valueString = (Get-Repr -Value $value)

	Write-Log "${typeString}${nameString} ${equals} ${valueString}"
}

[string]$scriptDir = (Split-Path -Parent $MyInvocation.MyCommand.Definition)
Write-Variable -Name "scriptDir"
Write-Log

Set-Location -Path $scriptDir

[string]$bunCommand = (Get-Command -Name 'bun.exe')
[string]$nodeModulesDir = '.\node_modules'
[string]$sourceDir = '.\src'
[string]$outputDir = '.\build'

if (!(Test-Path -Path $nodeModulesDir)) {
	Write-Log "Directory `"${nodeModulesDir}`" does not exists, running ``bun install``..."
	Write-Log

	& $bunCommand install
}

function Get-ChildFiles {
	param (
		[Parameter(Mandatory=$true)]
		[string]$Path,
		[switch]$Recurse,
		[scriptblock]$FilterScript
	)

	$pathParentDir = (Split-Path -Parent $Path)

	[string[]]$files = ((Get-ChildItem -Path $Path -Recurse:$Recurse) | Where-Object {
		$_.Attributes -ne [System.IO.FileAttributes]::Directory
	} | ForEach-Object {
		Resolve-Path -Path $_ -Relative -RelativeBasePath $pathParentDir
	})

	if (!$FilterScript) {
		return $files
	}

	[scriptblock]$wrappedFilter = {
		Set-Variable -Name '_' -Value (Get-Item -Path $_)
		Invoke-Command -ScriptBlock $FilterScript
	}

	return $files | Where-Object -FilterScript $wrappedFilter
}

[string[]]$sourceFiles = (Get-ChildFiles -Path $sourceDir -Recurse -FilterScript {
	$_.Extension -eq ".ts"
})

Write-Log "Watching the following files for changes:"
foreach ($file in $sourceFiles) {
	Write-Log "  - $(Get-Repr -Value $file)"
}
Write-Log

[string[]]$bunArgs = (@("build", "--outdir", $outputDir, "--watch", "--") + $sourceFiles)
& $bunCommand @bunArgs
