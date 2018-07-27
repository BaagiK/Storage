#get_stalesessions.ps1
# Get list of stale sessions for a user on a list of servers

echo "">C:\Users\bkota\stalesessions_output.txt

ForEach ($server in (Get-Content C:\Users\bkota\server_list.txt)) {

	[string[]]$session=qwinsta /SERVER:$server | select-string bkota
	if($session -ne $null){
		$User=$session.substring(15,19).trim()
		$ID=$session.substring(24,24).trim()
		Write "$server	$User	$ID" | out-file C:\Users\bkota\stalesessions_output.txt -Append
	}
}


