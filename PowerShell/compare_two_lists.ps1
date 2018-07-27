#compare_two_lists.ps1
#Save script to any location. Save server names in server_list.txt file.
#Open Powershell in admin mode.
#Go to the script location and enter the following:
#./compare_two_lists.ps1
#Output will be saved in 

echo "">C:\Users\bkota\comparison_output.txt

ForEach ($server in (Get-Content server_list.txt)) {
	Try {
		Get-Content critical_list.txt | select-string $server | Out-File -FilePath C:\Users\bkota\comparison_output.txt -Append
	}
    Catch {
        "$Computer not migrated" | Out-File -FilePath C:\Users\bkota\comparison_output.txt -Append
    }
}