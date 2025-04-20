# SimpleLoreScoreboard
Simple card game Score keeping app for live streaming (made with Disney Lorcana in mind)

To use, download project, leave all in a folder accessible to OBS (I use C:\Streaming\)
Open an admin powershell window, navigate to the project folder
run server.ps1 [-port {port number} (optional)]  default port is 8080
on a device on the same network (preferably phone or tablet), in a browser, navigate to the website presented by the server.ps1 output
should be http://{yourIPAddress}:{portNumber}

the red button in the middle opens the menu
reset yes/no and FullScreen button

in OBS, make a new Text source, style it, use Read from File, set to P1Score and/or P2score
use the Custom Text Extends option to make it fit perfectly at any number

as the score is raised/lowered via ANY device connected to the URL, the text files will be updated and OBS will show the updated number

