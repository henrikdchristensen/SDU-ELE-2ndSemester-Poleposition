@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\Users\Henrik-PC\Dropbox\VentStart\labels.tmp" -fI -W+ie -C V2E -o "C:\Users\Henrik-PC\Dropbox\VentStart\VentStart.hex" -d "C:\Users\Henrik-PC\Dropbox\VentStart\VentStart.obj" -e "C:\Users\Henrik-PC\Dropbox\VentStart\VentStart.eep" -m "C:\Users\Henrik-PC\Dropbox\VentStart\VentStart.map" "C:\Users\Henrik-PC\Dropbox\VentStart\VentStart.asm"
