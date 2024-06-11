# VMD-Automatic-Lip-Synchronization
Helps automate the process of converting an audio file to a cleaned lip synced vmd for MikuMikuDance/MikuMikuMoving

![lipsync](img/vmd_auto_lipsync.png)

## Video Tutorial
- Video Tutorial "[_MMD Automatic Lipsync to Audio File Tutorial_](https://youtu.be/4Fnxsbt0DhE)":
  
  [<img src=img/audio_to_vmd_yt_270p.png width=480 alt=" MMD Automatic Lipsync to Audio File Tutorial ">](https://youtu.be/4Fnxsbt0DhE)

## Requirements

1. [Miku Miku Moving English](https://sites.google.com/site/mikumikumovingeng/) 
3. [Lipsyncloid plugin for Miku Miku Moving by Nawota](https://www.nicovideo.jp/watch/sm22506025)
3. [VMDConverter by Yumin](https://miku-challenge.up.seesaa.net/image/VMDConverter.zip)
4. [AutoIt](https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.zip)
5. [FFMPEG for Windows](https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.7z) (if not already installed on your pc)
6. [Ultimate Vocal Remover](https://github.com/Anjok07/ultimatevocalremovergui/releases) (if you don't already have clean voice-only audio)

## Setup

1. Download this repository (Click "Code" button -> Download Zip, or alternately use git) and unzip it on your pc. Download the files in the Requirements section of this ReadMe.

2. **On the Miku Miku Moving zip file, Right click -> Properties -> click on unblock. Do this to Lipsyncloid plugin zip file, VMDConverter zip file and "VMD-Automatic-Lip-Synchronization" zip file as well(this will keep windows from blocking things like the dlls/scripts).**

3. Unzip Miku Miku Moving and VMDConverter. In VMDConverter folder, copy "LipSynchloid_v021.dll" to "MikuMikuMoving64_v*\Plugins\\" folder. Then copy "VMDConverter.exe" from "\VMDConverter\\" to the "VMD-Automatic-Lip-Synchronization\VMDConverter\\" folder.

4. Unzip ffmpeg and copy "ffmpeg.exe" from "ffmpeg-2024-05-15-git-7b47099bc0-essentials_build\bin\" folder to "VMD-Automatic-Lip-Synchronization" folder. It should now be in the same folder as the au3 file.

5. Unzip Autoit and run "autoit-v3-setup.exe" and go through the wizard to install.

6. Run "UVR_v*_setup*.exe" and go through the wizard to install Ultimate Vocal Remover.

## Convert audio file to optimized, lip-synced VMD

1. *(optional)* Open **"Ultimate Vocal Remover"** if your audio contains more than just the voice.
    - Click "Select Input" and choose your audio file. Then click on "Select Output" to choose your save folder
    - Check "WAV" radio button. Check "GPU Conversion" and "Vocals Only". Uncheck "Sample Mode".
    - Click "Start Processing" to create a voice-only wave file.
2. Drag your audio file to **"Audio To 48kHz 16bit wav.bat"** to convert it to an encoded 48kHz 16bit wav file that Lipsyncloid will accept.
3. Open **MikuMikuMoving**.
    - Click "Load Model" button and select a **DEFAULT MMD model** (DEFAULT meaning a MMD model that came with MikuMikuDance, as custom models might have different bones. A model must be loaded for the conversion to work. [MikuMikuDance also includes default models here](https://drive.google.com/uc?id=1rzOO6DoECOsLxBRAGM5FjRz0bt7m9rub&export=download).
    - Drag & Drop your new audio file into MikuMikuMoving to load it, then click on the "Plugins" Tab.
    - Click on "LipSynchloid 64Bit*" to convert your audio to lipsync data (this may take a moment to convert, then a message should popup).
    - Click on the "File" tab, then click on the "Export Motion" button.
    - Uncheck "center" if it's checked, then expanded the first folder with japanese characters, then check "a", "i", "u", and "o". It should look like [THIS](img/export_motion_settings.png).
    - Make sure "VMD File" radio button is selected, then click on the "..." next to "Output File" and choose save location/name.
    - Click the Export button to save it as a VMD (a "Completed" message should popup).
4. Run "**VMD Lips clean & optimize v\*.au3**" and select the VMD file. This will clean/optimize the file. Wait for it to convert, then a completed message should appear.
5. Complete! The final vmd lipsync file should be the one with **"\*_cleaned.vmd"**. 

## Credits
This repository was inspired by the original automatic lipsync guide by [Vayanis](https://www.youtube.com/watch?v=ozKBYGiyPJE)
