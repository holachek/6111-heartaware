# HeartAware

by Michael Holachek and Nalini Singh

## Introduction

HeartAware is a pulse oximetry system with a user-friendly interface for the Nexys 4 DDR FPGA board. The system will process the input pulse oximeter signal to identify peaks in the signal and calculate the patient’s heart rate using this data. Then, the processed oxygen saturation waveform and calculated heart rate will be displayed on a monitor. Additionally, the user’s calculated heart rate will be periodically announced through a recorded voice played through the audio output. __Disclaimer: this device is not intended for medical use.__

More information about this project is available in our [final report](http://web.mit.edu/6.111/www/f2015/projects/holachek_Project_Final_Report.pdf). We also have recorded a [video](http://web.mit.edu/6.111/www/f2015/projects/heart_s.mp4) demonstrating the project in action.

## Hardware

- Nexys 4 DDR board with USB cable
- 1024x768 VGA display
- 3.5mm speaker
- 2GB SD card

## Getting Started


First, program the microSD card. Use the Mac/Linux `dd` utility to block copy WAV files directly to the SD card. Note: the WAV file must be an unsigned 8 bit WAV with 32 kHz sample rate. Here are the steps to creating the SD card:

	1. Format the SD card in Disk Utility
	2. In Terminal, run `df -h` to see what devices are currently mounted. Find the SD card. Should be something like `/dev/diskXXX`. Easiest way to determine is by Size.
	3. Run `umount /dev/diskXXX` to unmount the card
	4. Block copy over WAV file `sudo dd if=~/Desktop/my_awesome_wav_file.wav of=/dev/diskXXX`
	
Then you'll be ready to start the Nexys 4:
	
1. Plug in the microSD card to the Nexys 4

2. Open the project file under `vivado/` and program the device with the generated bitstream. Ensure you have [Vivado 2015.2.1](http://www.xilinx.com/products/design-tools/vivado.html) or newer installed.

3. It works! Ensure you have switch 15 and 14 set to zero to boot into run mode.

## User Interface

In run mode:

SW[9] will turn on/off the heart rate beeping sound. 
SW[10] will turn on/off the match filter display.

Press the center button to play the current user heart rate.

Press the right button to play a test tone. 

Press the left button to enter pause mode, or the up button to enter system error mode.

Press the down button to clear these modes and resume run mode.


## Resources

#### Xilinx IP Modules
Our project uses a few Xilinx IP core modules: Block Memory Generator, FIFO Generator, and Clocking Wizard.

#### Font
We used the excellent [Dosis](http://www.impallari.com/dosis) font by Impallari, released under the Open Font License.

#### Font to Bitmap
Thanks to Codehead for [Bitmap Font Generator](http://www.codehead.co.uk/cbfg/), a way to generate bitmap font files from any fonts.

#### COE Conversion
Thanks to Javier Merino for [coetool](http://jqm.io/files/coetool/), a simple Python-based conversion utility to generate COE files from JPG/PNG/BMP images. We also used the 6.111 MATLAB COE generator script.

### SD Card Module
Thanks to Jonathan Matthews for the [sd_controller.v](https://github.com/jono-m/mariokart/blob/master/v1/v1.srcs/sources_1/new/sd_controller.v) module.

### Icons
Thanks to Google for their [Material Icons](https://www.google.com/design/icons/) used in our sprite map.

### Windows Sound
Thanks to Microsoft for their [Windows 95 start up](https://www.youtube.com/watch?v=miZHa7ZC6Z0) tone we used for extra retro effect in our project!

## Acknowledgements

Many thanks to Gim Hom, Miren Bamforth, and the 6.111 lab staff for help and support during the project!
