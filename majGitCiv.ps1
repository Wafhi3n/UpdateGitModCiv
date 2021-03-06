$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")
$dirMod=$documents+"\My Games\Sid Meier's Civilization VI\Mods"
$env:GIT_REDIRECT_STDERR = '2>&1'
$com=$MyInvocation.MyCommand.Path
$voice = New-Object -ComObject Sapi.spvoice
$voice.rate = 0

try {
    . ("$PSScriptRoot/settings.ps1")
    . ("$PSScriptRoot/CommonFct.ps1")
    . ("$PSScriptRoot/Git.ps1")
    . ("$PSScriptRoot/old.ps1")
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}

function Update {
    param (
        $Mod,
        $GameLauched
    )
    $DirName=GetName $Mod
    $TotalPath=$dirMod+"\"+$DirName
    Set-Location $TotalPath
    git fetch --tags
    $latesttag=$(LatestTag $mod)
    $tagActuel=git describe --tags
    if($latesttag -ne $tagActuel){
        if(!$GameLauched){
            Write-Host "Maj necessaire de "$DirName " " $latesttag " depuis la" $tagActuel
            if ($latesttag -ne ""){
                git -c advice.detachedHead=false checkout $('tags/'+$latesttag)
            }else{
                git -c advice.detachedHead=false checkout 

            }
        }else{
            $voice.speak($("Maj necessaire de "+$DirName+" "+$latesttag+" depuis la "+$tagActuel+", veuillez redemarrer Civilisation son script."))
            Write-Host "Maj necessaire de "$DirName " " $latesttag " depuis la " $tagActuel ", veuillez redemarrer le jeu et ce script."
        }
    }else{
        if(!$GameLauched){
            Write-Host $DirName" est à jour."
        }
    }
}
function createIcon() {
    $targetPath = "powershell.exe"
    $Arguments = "-ExecutionPolicy Bypass -File $com"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($($desktop+"\"+$shortCutName+".lnk"))
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Arguments  = $Arguments
    $Shortcut.Save()
}
function updateAllMod(){
    param(
        $GameLauched
    )
    $git | ForEach-Object {
        Update $PSItem $GameLauched
    }
}
function verifInstallAllMod(){
    $git | ForEach-Object {
        VerifAndInstallWithGit $PSItem 
    }
}
function main(){
    $date=Get-Date
    $nextCheck=$date.AddMinutes(30);
   
    VerifGit
    verifInstallAllMod
    updateAllMod 0
    
    if(!(Test-Path -Path $($desktop+"\"+$shortCutName+".lnk")  -PathType Leaf )){
        createIcon
        Write-Host "Icone crée sur le Bureau : Civ6-BBG!"
    }
    
    Start-Process steam://rungameid/289070
    Start-Sleep -s 30

    While ($true){
        $LaunchPadProcess = Get-Process "LaunchPad" -ErrorAction SilentlyContinue
        $Civ6Process = Get-Process "CivilizationVI*" -ErrorAction SilentlyContinue
        $date=Get-Date   
        if ( $Civ6Process -Or $LaunchPadProcess) {
            if ( $($date - $nextCheck) -gt 0){
                Write-Host "Recherche de mise à jour"
                updateAllMod 1 
                $nextCheck=$date.AddMinutes(30);
            }
        }else {
            Write-Host "jeu eteint, au revoir" 
            exit 0;
        }      
        Start-Sleep -s 5
    }
}



function labelNomMod(){
    param(
        $mod,
        $x,
        $y
    )
    $label = New-Object  System.Windows.Forms.Label
    # Initialize the Label and TextBox controls.
    $label.Location = New-Object System.Drawing.Point($x,$y);
    $label.Text = $mod[1];
    $Font = New-Object System.Drawing.Font("Verdana",20,[System.Drawing.FontStyle]::Italic)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $label.Font = $Font

    $label.Size =New-Object System.Drawing.Size(300, $LABEL_Y_SIZE);
    $label.BackColor = $([System.Drawing.Color]::blue)
    return $label
}
function buttonCheckMod
(){
    param(
        $mod,
        $x,
        $y
    )
    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Size($x,$($y-3.5))
    $Button.Size = New-Object System.Drawing.Size(150,23)
    $Button.Text = "Getting Status info..."
    $Button.BackColor = $([System.Drawing.Color]::red)

    $main_form.Controls.Add($Button)
    return $Button

}


function setPanelMod(){
    param(
        $main_form
    )

    $panelMod = New-Object  System.Windows.Forms.Panel
    $panelMod.Location = New-Object System.Drawing.Point(0,0);
    $panelMod.Size = New-Object System.Drawing.Size($PANEL_X_SIZE, $PANEL_Y_SIZE);


    $panelMod.BackColor = $([System.Drawing.Color]::lightblue)

    #$labelisOK =   VerifModGit $mod


    #$textBox1.Location = New-Object System.Drawing.Point(16,32);
    #$textBox1.Text = "";
    #$textBox1.Size = New-Object System.Drawing.Size(152, 20);
 
    # Add the Panel control to the form.


    $main_form.Controls.Add($panelMod);
    # Add the Label and TextBox controls to the Panel.
    #$panel1.Controls.Add($textBox1);
    



    return $panelMod
}
#main
function addModToPanel(){
    param(
        $panelMod,
        $mod,
        [int]$position
    )
    #Write-Host $position 
    [int]$y = ($position-1)*$LABEL_Y_SIZE +3*$position;
    [int]$xButtonCheckMod = 350 + $LABEL_X_SIZE;
    $labelNomMod = labelNomMod $mod $LABEL_X_SIZE $y
    $ButtonCheckMod = buttonCheckMod $mod $xButtonCheckMod $y
    $panelMod.Controls.Add($labelNomMod);
    $panelMod.Controls.Add($ButtonCheckMod);
}
function addLaunchButtonToForm(){
    param(
        $main_form
    )
    $Button = New-Object System.Windows.Forms.Button;

    #[double]$y = [double]$WINDOW_Y_SIZE - 32
    #[double]$x = [double]$WINDOW_X_SIZE 
$x= 200
$y = 200
    $Button.Location = New-Object System.Drawing.Size($x, $y)
    $Button.Size = New-Object System.Drawing.Size(150,23)
    $Button.Text = "LANCER CIVILIZATION"
    $Button.BackColor = $([System.Drawing.Color]::red)

    $main_form.Controls.Add($Button)
    return $Button
}


function mainUI(){
    Add-Type -assembly System.Windows.Forms
    Add-Type -assembly System.Drawing

    $main_form = New-Object System.Windows.Forms.Form
    $main_form.Text ='Launcher Civ-FR'
    $main_form.Width = $WINDOW_X_SIZE
    $main_form.Height = $WINDOW_Y_SIZE
    $main_form.AutoSize = $false

    $panelMod = setPanelMod $main_form;
    [int]$cpt=0
    $git | ForEach-Object {
        $cpt++
        addModToPanel $panelMod $PSItem $cpt
    }
    $launchButton = addLaunchButtonToForm $main_form


    $main_form.ShowDialog()

}

#mainUI
checkInstallFont