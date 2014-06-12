# arguements expected
#   0: build directory
#   1: cis/smb share

if (!($args.Length -ieq 2))
{
    Write-Host "WinDDK 7.1.0   : Must supply adequate arguments!"
    return 1
}

$folder =    ("{0}\winddk7" -f $args[0])
$setup =     ("{0}\winddk7\unpacked\KitSetup.exe" -f $args[0])
$source =    $args[1]

if ([IO.Directory]::Exists($folder))
{
    [IO.Directory]::Delete($folder, $true)
}
[IO.Directory]::CreateDirectory($folder)

# Copy this junk to avoid moronic file open warnings
Copy-Item $source $folder -Recurse

# Piping the output forces the script to wait to for the command to finish before continuing - cunning eh...
# Assuming that the KitSetup works more or less the same way for the Win7 WDK
& $setup /install ALL /ui-level EXPRESS | Write-Host
