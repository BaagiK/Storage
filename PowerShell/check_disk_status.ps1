#check_disk_status.ps1
#Disk status:		Invoke-Command -ComputerName srv1 -ScriptBlock {"list disk" | diskpart}

Set-Item WSMan:\localhost\Client\TrustedHosts -value * -Force
#Restart-Service winrm -Force

echo "">C:\Users\SA_bkota\check_disk_status_output.txt

ForEach ($server in (Get-Content C:\Users\SA_bkota\server_list.txt)) {	
	
	[string]$diskoutput = Invoke-Command -ComputerName $server -ScriptBlock {"list disk" | diskpart}
	
	Write "------------------------$server-----------------------" | out-file C:\Users\SA_bkota\check_disk_status_output.txt -Append
	Write "$diskoutput" | out-file C:\Users\SA_bkota\check_disk_status_output.txt -Append
	
	Write "------------------------$server-----------------------"
	Write "$diskoutput"
	
	Write-Host "Press any key to continue ..."
	$HOST.UI.RawUI.Flushinputbuffer()
	$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	$HOST.UI.RawUI.Flushinputbuffer()
}

