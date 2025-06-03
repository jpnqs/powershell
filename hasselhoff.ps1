
Add-Type @"
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# 1. Pfad zum AppData-Verzeichnis
$appDataPath = $env:APPDATA

# 2. Zufälligen Ordnernamen generieren
$randomFolderName = -join ((65..90) + (97..122) | Get-Random -Count 10 | ForEach-Object {[char]$_})
$folderPath = Join-Path $appDataPath $randomFolderName

# 3. Ordner erstellen
New-Item -ItemType Directory -Path $folderPath -Force | Out-Null

# 4. Bild-URL
$imageUrl = "https://www.arte-magazin.de/media/2019/07/GettyImages-1092332826..klein_.jpg"

# 5. Zufälligen Bilddateinamen generieren
$randomFileName = (-join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})) + ".bmp"
$imagePath = Join-Path $folderPath $randomFileName

# 6. Bild herunterladen
$tempPngPath = [System.IO.Path]::ChangeExtension($imagePath, ".png")
Invoke-WebRequest -Uri $imageUrl -OutFile $tempPngPath

# 7. PNG nach BMP konvertieren (Wallpaper braucht BMP für volle Kompatibilität)
Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Image]::FromFile($tempPngPath)
$bmp.Save($imagePath, [System.Drawing.Imaging.ImageFormat]::Bmp)
$bmp.Dispose()
Remove-Item $tempPngPath

# 8. Als Hintergrundbild setzen
# 20 = SPI_SETDESKWALLPAPER, 3 = SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE
[Wallpaper]::SystemParametersInfo(20, 0, $imagePath, 3) | Out-Null

# 9. Ausgabe
Write-Output "Hintergrundbild wurde gesetzt: $imagePath"
