#!/usr/bin/env python2

import subprocess
from pprint import pprint
#import sys
def run_command(cmd):
   proc = subprocess.Popen(cmd,
      stdout=subprocess.PIPE,
      stderr=subprocess.PIPE,
      shell=True,
      universal_newlines=True)

   output, error = proc.communicate()
   if proc.returncode:
      print('\033[1;31m' + "Error running command: " + cmd + '\033[0m')
      print('\033[1;31m' + error + '\033[0m')

   return output

def main():
#   df_out = run_command("df -h | grep -i emcpower | grep ocfs | sed 's/\/dev\///g' | sort -k6")
   df_out = run_command("df -h | grep -i emcpower | sed 's/\/dev\///g' | sort -k6")

#   print(df_out)

# Remove empty lines from output
#   while '\n\n' in df_out:
#      df_out = df_out.replace('\n\n','\n')

# Split multiline string into list of lines
   df_out_line_list = df_out.split("\n")
#   print(len(df_out_line_list))

# Remove empty string at the end from list, after split
   df_out_line_list = filter(None, df_out_line_list)
#   print(len(df_out_line_list))

   pseudo_list = list()
   size_list = list()
   usedperc_list = list()
   mount_list = list()

   for line in df_out_line_list:
      temp_list = line.split()
#      print(temp_list)

      pseudo_list.append(temp_list[0])
      size_list.append(temp_list[1])
      usedperc_list.append(temp_list[4])
      mount_list.append(temp_list[5])

#   print (pseudo_list)

   array_list = list()
   dev_list = list()
   wwn_list = list()

   for pseudo in pseudo_list:
      ppcmd = "/sbin/powermt display dev=" + pseudo 
      ppcmd_out = run_command(ppcmd)
#      ppcmd_out = """Pseudo name=emcpowervd
#VNX ID=APM00154736610 [SG_USWS1HMSDVDB08]
#Logical device ID=6006016011B03400EC1B8C80AF7FE611 [HLRLEG /ocfshlrlegd138]
#state=alive; policy=CLAROpt; queued-IOs=0"""
#      print(ppcmd_out)

      if "VNX" in ppcmd_out:
#         print("It is a VNX device")
         ppcmd_out_line_list = ppcmd_out.split("\n",3)
         array_sg = ppcmd_out_line_list[1].split("=")[1]
         array = array_sg.split(" ")[0]
         wwn_label  = ppcmd_out_line_list[2].split("=")[1]
         wwn = wwn_label.split(" ")[0]
         dev = wwn_label.split(" ")[2].split("]")[0]
#         print(dev)
      else:
#         print("It is a Symmetrix device")
         ppcmd_out_line_list = ppcmd_out.split("\n",4)   # Split lines using \n character, up to max of 5 lines
#         ppcmd_out_line_list.pop(4)   # Removing teh fifth element in List
         
         array = ppcmd_out_line_list[1].split("=")[1]
         dev = ppcmd_out_line_list[2].split("=")[1]
         wwn = ppcmd_out_line_list[3].split("=")[1]

      array_list.append(array)
      dev_list.append(dev)
      wwn_list.append(wwn)
#   print "==================================================================================================================="
   print "--mountpoint--", "--pseudoname--", "--wwn--", "--arraysid--", "--symdev--", "--Allocatedsize--","--usedpercentage--"
#   print "==================================================================================================================="

   for ind in range(len(pseudo_list)):
      print mount_list[ind], pseudo_list[ind], wwn_list[ind], array_list[ind], dev_list[ind], size_list[ind], usedperc_list[ind]

if __name__ == '__main__':
   main()

