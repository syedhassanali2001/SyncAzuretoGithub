param(
    [Parameter()]
    [string]$GithubDestinationPAT,

    [Parameter()]
    [string]$AzureSourcePAT
)

# Write your PowerShell commands here.
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - '
Write-Host ' Reflect Azure Devops repo changes to Github repo '
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - '
$AzureRepoName="Aladdin-Karobaar-Web-Portal"
$AzureCloneURL="dev.azure.com/aladdininformatics/Aladdin-Karobaar-Web-Portal/_git/Aladdin-Karobaar-Web-Portal"
$GithubCloneURL="github.com/syedhassanali2001/Aladdin-Karobaar-Web-App.git"
$stageDir = (Get-Location).Path
Write-Host "Stage Dir is: $stageDir"
$githubDir = Join-Path $stageDir "gitHub"
Write-Host "GitHub Dir is: $githubDir"
$destination = Join-Path $githubDir "$AzureRepoName\.git"
Write-Host "Destination: $destination"
# Please make sure, you remove https from azure-repo-clone-url
$sourceURL= "https://$($AzureSourcePAT)@$($AzureCloneURL)" 
Write-Host "Source URL: $sourceURL"
# Please make sure, you remove https from github-repo-clone-url
$destURL= "https://$($GithubDestinationPAT)@$($GithubCloneURL)"
Write-Host "Dest URL: $destURL"

# Check if the parent directory exist and delete
if (Test-Path -Path $githubDir) {
    Remove-Item -Path $githubDir -Recurse -Force
}
if (-not (Test-Path -Path $githubDir)) {
    New-Item -ItemType Directory -Path $githubDir
    Set-Location $githubDir
    git clone --mirror $sourceURL
} else {
    Write-Host "The given folder path $githubDir already exists"
}

# Check if the clone was successful
if (-not (Test-Path -Path $destination)) {
    Write-Host "Clone failed. The destination path $destination does not exist."
    exit 1
}

Set-Location $destination
Write-Output '***** Git removing remote secondary *****'
git remote rm secondary 
Write-Output '***** Git remote add *****'
git remote add --mirror=fetch secondary $destURL 
Write-Output '***** Git fetch origin *****'
git fetch origin
Write-Output '***** Git push secondary *****'
# git remote set-url origin $destURL SetURL
git push secondary --all -f
Write-Output '***** Azure Devops repo synced with Github repo *****'
Set-Location $stageDir
if (Test-Path -Path $githubDir) {
    Remove-Item -Path $githubDir -Recurse -Force
}
Write-Host "Job Completed"
