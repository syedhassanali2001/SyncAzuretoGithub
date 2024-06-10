param(
    [Parameter()]
    [string]$GithubDestinationPAT,

    [Parameter()]
    [string]$AzureSourcePAT
)

# Write your PowerShell commands here.
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - '
Write-Host ' Reflect Azure DevOps repo changes to Github repo '
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - '

$AzureRepoName = "Aladdin-Karobaar-Web-Portal"
$AzureCloneURL = "dev.azure.com/aladdininformatics/Aladdin-Karobaar-Web-Portal/_git/Aladdin-Karobaar-Web-Portal"
$GithubCloneURL = "github.com/syedhassanali2001/Aladdin-Karobaar-Web-App.git"
$stageDir = pwd | Split-Path
Write-Host "Stage Dir is : $stageDir"
$githubDir = $stageDir + "\gitHub"
Write-Host "Github Dir is : $githubDir"
$destination = $githubDir + "\" + $AzureRepoName + "\.git"
Write-Host "Destination: $destination"

# Please make sure to remove https from azure-repo-clone-url
$sourceURL = "https://$AzureSourcePAT@$AzureCloneURL"
Write-Host "Source URL : $sourceURL"

# Please make sure to remove https from github-repo-clone-url
$destURL = "https://$GithubDestinationPAT@$GithubCloneURL"
Write-Host "Dest URL : $destURL"

# Check if the parent directory exists and delete if it does
if (Test-Path -Path $githubDir) {
    Remove-Item -Path $githubDir -Recurse -Force
}

# Create the directory if it does not exist
if (!(Test-Path -Path $githubDir)) {
    New-Item -ItemType Directory -Path $githubDir
    Set-Location $githubDir
    git clone --mirror $sourceURL
} else {
    Write-Host "The given folder path $githubDir already exists"
}

Set-Location $destination
Write-Output '***** Git removing remote secondary *****'
git remote rm secondary

Write-Output '***** Git remote add *****'
git remote add --mirror=fetch secondary $destURL

Write-Output '***** Git fetch origin *****'
git fetch origin

Write-Output '***** Git push secondary *****'
git push secondary --all -f

Write-Output '***** Azure DevOps repo synced with Github repo *****'

Set-Location $stageDir

# Remove the cloned repository to clean up
if (Test-Path -Path $githubDir) {
    Remove-Item -Path $githubDir -Recurse -Force
}

Write-Host "Job Completed"
