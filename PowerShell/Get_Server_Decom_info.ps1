#Get_Server_Decom_info.ps1
#Save script to any location. Save server names in server_list.txt file.
#Open Powershell in admin mode.
#Go to the script location and enter the following:
#./Get_Server_Decom_info.ps1 <array sid>
#Ex: ./Get_Server_Decom_info.ps1 3962
#Output will be saved in 
#1.Masking groups & Fast policy - server_decom_info.txt file in C:\Users\bkota\
#2.symdev & Pool info - symdevs.txt in C:\Users\bkota\

Param(
    [string]$sid
)
echo "">C:\Users\bkota\symdevs.txt
echo "">C:\Users\bkota\server_decom_info.txt
symaccess -sid $sid list -type init | out-file C:\Users\bkota\iglist.txt
symaccess -sid $sid list -type stor | out-file C:\Users\bkota\sglist.txt

ForEach ($server in (Get-Content server_list.txt)) {
    [string]$ig=get-content iglist.txt | select-string $server
    $ig=$ig.trim()
    [string]$sg=get-content sglist.txt | select-string $server
    $sg=$sg.trim()
    symaccess -sid $sid show $ig -type init | out-file igdisplay.txt
    [string]$mv=get-content igdisplay.txt | select-string -pattern "_mask", "-Mask"
    $mv=$mv.trim()
    symfast -sid $sid show -association -sg $sg | out-file fastdisplay.txt
    [string]$fp=get-content fastdisplay.txt | select-string "Policy Name"
    $fp=$fp.substring(23).trim()
    get-content fastdisplay.txt | select-string FBA | out-file C:\Users\bkota\symdevs.txt -Append

    Write "$server	$mv	$ig	$sg	$fp" | Out-File C:\Users\bkota\server_decom_info.txt -Append
#(get-content C:\Users\bkota\symdevs.txt) | ? {$_.trim() -ne "" } | set-content C:\Users\bkota\symdevs_noblanks.txt

}