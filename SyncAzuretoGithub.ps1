param(
    [Parameter()]
    [string]$GithubDestinationPAT,

    [Parameter()]
    [string]$AzurePAT
)

#write your PowerShell commands here.
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - '
Write-Host ' reflect Azure Devops repo changes to Github repo '
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - '
$AzureRepoName="Aladdin-Karobaar-Web-Portal"
$AzureCloneURL="dev.azure.com/aladdininformatics/Aladdin-Karobaar-Web-Portal/_git/Aladdin-Karobaar-Web-Portal"
$GithubCloneURL="github.com/syedhassanali2001/Aladdin-Karobaar-Web-App.git"
$stageDir = pwd | Split-Path
Write-Host "stage Dir is : $stageDir"
$githubDir = $stageDir +"\gitHub"
Write-Host "github Dir is : $githubDir"
$destination = $githubDir +"\"+ $AzureRepoName+".\.git"
Write-Host "destination: $destination"
#please make sure, you remove https from azure-repo-clone-url
$sourceURL= "https://$(AzureSourcePAT)"+"@"+"$($AzureCloneURL)" 
Write-Host "Source URL : $sourceURL"
#please make sure, you remove https from github-repo-clone-url
$destURL= "https://" + $($GithubDestinationPAT) +"@"+ "$($GithubCloneURL)"
Write-Host "dest URL : $destUrl"
#Check if the parent directory exist and delete
if(Test-Path -path $githubDir){
    Remove-Item -Path $githubDir -Recurse -force
}
if (!(Test-Path -path $githubDir)) {
    New-Item -ItemType directory -path $githubDir
    Set-Location $githubDir
    git clone --mirror $sourceURL
}
else 
{
    Write-Host "The given folder path $githubDir already exists";
}

Set-Location $destination
Write-Output '*****Git removing remote secondary*****'
git remote rm secondary 
Write-Output '*****Git remote add*****'
git remote add --mirror-fetch secondary $destURL 
Write-Output '*****Git fetch origin*****'
git fetch $sourceURL
Write-Output '*****Git push secondary*****'
#git remote set-url origin $destURL SetURL
git push secondary --all -f
Write-Output '*****Azure Devops repo synced with Github repo*****'
Set-Location $stageDir
if(Test-Path -path $githubDir){
    Remove-Item -Path $githubDir -Recurse -force
}
Write-Host "Job Completed"
