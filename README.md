# Reason Arturia Keylab MkII Codec
A device control codec for using the Arturia Keylab MkII with Reason.

## Compatibility

Tested successfully with:
- Reason Version 12.2
- Keylab MkII Firmware Version 1.3.1

## Installation

### Windows

1. Download and unpack the source zip file (*reason-keylabmkii-codec-master.zip*) from this repository (Click the *Code* button and choose *Download ZIP*).

2. Copy the *Remote* folder including its contents to *C:\Users\[yourUserName]\AppData\Roaming\Propellerhead Software*

3. Open Reason, navigate to *Preferences/Control Surfaces* and manually add the following control surfaces from the *Arturia* manufacturer category:

   **Keylab MkII MCU**:
   	Set MIDI In to *MIDIIN2 (Keylab mkII 61)*.
   	Set MIDI Out to *MIDIOUT2 (Keylab mkII 61)*.
   	This control surface will be used for DAW transport controls (Play, Stop, Record, Metronome, etc.).

   **Keylab MkII**:
   	Set MIDI In to *Keylab mkII 61*.
   	Set MIDI Out to *Keylab mkII 61*.
   	This control surface will be used for the Keylab's three user knob/slider/swiches banks.

   **Keylab MkII Keys**:
   	Set MIDI In to *Keylab mkII 61*.
   	Set MIDI Out to *Keylab mkII 61*.
   	Set this surface as your master keyboard.

   **Keylab MkII Pads**:
   	Set MIDI In to *Keylab mkII 61*.
   	Set MIDI Out to *Keylab mkII 61*.
   	This control surface will be used to play the Keylab's drum pads independently from the piano keys.

**NOTE**: Reason will display warning icons on Keylab MkII, Keylab MkII Keys, and Keylab MkII Pads because these devices share the same MIDI input. This is a limitation of the Keylab MkII but these warnings can safely be ignored. The surfaces will still work.

4. Close Reason and open the Arturia MIDI Control Center.
4. Import the included *Reason.keylabmkII* file from the *Template* folder into Arturia MIDI Control Center, rename the imported template to *Reason* and then store it in one of the device memories of your Keylab MkII.

## Usage

- Use the DAW transport functions (play/stop/record, etc.) on the Keylab MkII with Reason (the Keylab MkII does not have to be locked to the Master Section to use this).
- Switch to DAW mode on the Keylab MkII and switch patches prev/next with the two arrow buttons (the encoder knob is currently not supported).
- Play the piano keys to play notes.
- Play the drum pads for drums (e.g with Reason's Kong) independently from the piano keys.
- Control any Reason devices and REs that are mapped in the included Keylab MkII.remotemap file with the Keylab MKII's three user knob/slider/button banks. **To use these the Keylab MkII needs to be switched to User mode and the Reason template needs to be activated by selecting it with the wheel and then pressing the wheel.** As soon as a Reason rack device is focused and receives MIDI input it should be controllable with the knobs, faders, and buttons.

**Please note that Reason rack device mappings in *Keylab MkII.remotemap* are a work in progress.**

## Troubleshooting

If any of this isn't working it's best to do a factory reset on the Keylab and see if it fixes it. First, backup any user templates from the Keylab into MIDI Control Center. To factory reset the Keylab turn it off, then hold the Oct- and Oct+ buttons down while turning it back on, then confirm by pressing the large encoder wheel. Don't forget to load the custom Reason template into the device again afterwards!

## Credits

Original codec programming: Timothy Rylatt
Improvements & future support: Ciathyza

