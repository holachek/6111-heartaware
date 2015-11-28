# HeartAware

## Introduction

HeartAware is a pulse oximetry system with a user-friendly interface for the Nexys 4 DDR FPGA board. The system will process the input pulse oximeter signal to identify peaks in the signal and calculate the patient’s heart rate using this data. Then, the processed oxygen saturation waveform and calculated heart rate will be displayed on a monitor. Additionally, the user’s calculated heart rate will be periodically announced through a recorded voice played through the audio output. __Disclaimer: this device is not intended for medical use.__

## Dependencies

- Nexys 4 DDR board
- 1024x768 VGA display
- 3.5mm speaker

## Getting Started

Ensure you have Vivado 2015.2.1 or newer installed. Open the project file under `vivado/` and program the device.

## Resources

#### Xilinx IP Modules
Our project uses a few Xilinx IP core modules.

#### Font
We used the excellent [Dosis](http://www.impallari.com/dosis) font by Impallari, released under the Open Font License.

#### Font to Bitmap
Thanks to Codehead for [Bitmap Font Generator](http://www.codehead.co.uk/cbfg/), a way to generate bitmap font files from any fonts.

#### COE Conversion
Thanks to Javier Merino for [coetool](http://jqm.io/files/coetool/), a simple Python-based conversion utility to generate COE files from JPG/PNG/BMP images.

#### SD Block Copy
Use the Mac/Linux `dd` utility to block copy WAV files directly to the SD card. Here are the steps to creating the SD card:

1. Format the SD card in Disk Utility
2. In Terminal, run `df -h` to see what devices are currently mounted. Find the SD card. Should be something like `/dev/diskXXX`. Easiest way to determine is by Size.
3. Run `umount /dev/diskXXX` to unmount the card
4. Block copy over WAV file `sudo dd bs=1M if=~/Desktop/my_awesome_wav_file.wav of=/dev/diskXXX`

## Acknowledgements