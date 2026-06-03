# Define variables with clear descriptions
$languageTag = "he-IL"  # Language code for Hebrew (Israel) (Replace with desired language code)
$downloadPath = "C:\Temp\LanguagePackFiles"  # Temporary download location

# Define URLs for the CAB files (update these with your uploaded CAB file URLs)
$cabUrls = @{
    "ClientLanguagePack" = "https://yourstorage.blob.core.windows.net/cabs/Microsoft-Windows-Client-Language-Pack_x64_he-il.cab"
    "Basic" = "https://yourstorage.blob.core.windows.net/cabs/Microsoft-Windows-LanguageFeatures-Basic-he-il-Package~31bf3856ad364e35~amd64~~.cab"
    "Fonts" = "https://yourstorage.blob.core.windows.net/cabs/Microsoft-Windows-LanguageFeatures-Fonts-Hebr-Package~31bf3856ad364e35~amd64~~.cab"
    "TextToSpeech" = "https://yourstorage.blob.core.windows.net/cabs/Microsoft-Windows-LanguageFeatures-TextToSpeech-he-il-Package~31bf3856ad364e35~amd64~~.cab"
    "LXP" = "https://yourstorage.blob.core.windows.net/cabs/LanguageExperiencePack.he-IL.Neutral.appx"
    "License" = "https://yourstorage.blob.core.windows.net/cabs/License.xml"
}

# Function to check if Hebrew LXP is installed
function Is-LxpInstalled {
    Get-Language | Where-Object { $_.LanguagePacks -match 'LXP' -and $_.LanguageId -match 'he-IL' }
}

# Check if Hebrew LXP is already installed
if (Is-LxpInstalled) {
    Write-Host "Hebrew Language Experience Pack is already installed."
    exit 0  # Exit with success code (0)
}

# Check if the download path exists
if (-not (Test-Path $downloadPath)) {
    Write-Host "The download path $downloadPath does not exist. Creating it..."
    New-Item -Path $downloadPath -ItemType Directory -ErrorAction SilentlyContinue
}

# Download the CAB files and LXP files
foreach ($key in $cabUrls.Keys) {
    $url = $cabUrls[$key]
    $fileName = [System.IO.Path]::GetFileName($url)
    $filePath = Join-Path $downloadPath $fileName
    Write-Host "Downloading $key CAB file..."
    Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $filePath
}

Write-Host "All files downloaded."

# Set execution path
Set-Location -Path $downloadPath

# Install the LXP for Windows 11
Add-AppProvisionedPackage -Online -PackagePath "$downloadPath\LanguageExperiencePack.he-IL.Neutral.appx" -LicensePath "$downloadPath\License.xml"

Write-Host "Installing Hebrew Language Experience Pack..."

# Install additional language features
Add-WindowsPackage -Online -PackagePath "$downloadPath\Microsoft-Windows-Client-Language-Pack_x64_he-il.cab"
Add-WindowsPackage -Online -PackagePath "$downloadPath\Microsoft-Windows-LanguageFeatures-Basic-he-il-Package~31bf3856ad364e35~amd64~~.cab"
Add-WindowsPackage -Online -PackagePath "$downloadPath\Microsoft-Windows-LanguageFeatures-Fonts-Hebr-Package~31bf3856ad364e35~amd64~~.cab"
Add-WindowsPackage -Online -PackagePath "$downloadPath\Microsoft-Windows-LanguageFeatures-TextToSpeech-he-il-Package~31bf3856ad364e35~amd64~~.cab"

# Set Hebrew as the system language
Set-SystemPreferredUILanguage $languageTag

Write-Host "Finished installing Hebrew Language Experience Pack and features."

exit 0  # Exit with success code (0)
