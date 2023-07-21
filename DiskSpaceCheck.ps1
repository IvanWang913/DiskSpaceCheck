# Set the threshold (in percentage) when you want to receive the low disk space notification.
$thresholdPercentage = 10

# Get the drive with the lowest available space percentage.
$lowDisk = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } |
    Sort-Object FreeSpace -Descending | Select-Object -First 1

# Calculate the percentage of free space for the selected drive.
$freeSpacePercentage = [math]::Round(($lowDisk.FreeSpace / $lowDisk.Size) * 100, 2)

# Email settings
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$smtpUsername = "senderemail"
$smtpPassword = "password"
$emailFrom = "senderemail"
$emailTo = "receiveremail"
$emailSubject = "Low Disk Space Alert"
$emailBody = "The available disk space on drive $($lowDisk.DeviceID) is critically low. Free space: $freeSpacePercentage%"

# Send the email if the free space is below the threshold
if ($freeSpacePercentage -lt $thresholdPercentage) {
    $securePassword = ConvertTo-SecureString $smtpPassword -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential ($smtpUsername, $securePassword)
    $emailParameters = @{
        SmtpServer = $smtpServer
        Port = $smtpPort
        UseSsl = $true
        Credential = $credentials
        From = $emailFrom
        To = $emailTo
        Subject = $emailSubject
        Body = $emailBody
    }
    Send-MailMessage @emailParameters
}
