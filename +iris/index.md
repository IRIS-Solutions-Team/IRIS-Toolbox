# Installing IrisT and its dependencies

## Requirements

* Matlab R2018a or later


## Optional components

* The Optimization Toolbox is needed when estimating structural models.


## Installing IrisT

1. Download the latest IrisT zip archive, `IrisT_Tbx_YYYYMMDD.zip`,
from the download area on \texttt{www.iris-toolbox.com}, and save it in a
temporary location on your disk.

2. If you are going to install IrisT in a folder where an older
version already resides, completely delete the old version first.

3. Unzip the archive into a folder on your hard drive, e.g. `C:\IrisT_Tbx`
   (on Windows) or `~/iris-tbx` (on Unix based systems). This folder is
   called the IrisT root.

4. After installing a new version of IrisT, we recommend that you
remove all older versions of IrisT from the Matlab search path, and
restart Matlab.


## Getting started

Each time you want to start working with IrisT, run the following line

    >> addpath C:\IrisT_Tbx; iris.startup

where `C:\IrisT_Tbx` needs to be, obviously, replaced with the proper IrisT
root folder chosen during installation.

Alternatively, you can put the IrisT root folder permanently on the Matlab
seatch path (using the menu File - Set Path), and only run the
`iris.startup` command at the beginning of each IrisT session.

See also the section on [Starting and quitting IrisT](config/Contents).


## Syntax highlighting

You can get the IrisT model files syntax-highlighted. Syntax highlighting
improves enormously the readability of the files: it helps you understand
the model better, and discover typos and mistakes more quickly.

Add any number of extensions you want to use for model files (such as
`'model'` or `'iris'`, there is really no limitation) to the Matlab
editor. Open the menu Home - Preferences, unfold Editor/Debugger and
choose Language. Make sure Matlab is selected at the top as the language.
Use the Add button in the File extensions panel to associate any number
of new extensions with the editor. Re-start the editor. The IrisT model
files will be syntax highlighted from that moment on.


## Third-party components distributed with IrisT

* X13-ARIMA-SEATS (formerly X12-ARIMA, X11-ARIMA). Courtesy of the U.S.
Census Bureau, the X13-ARIMA-SEATS (formerly X12-ARIMA) program is now
incoporated in, and distributed with IrisT. No extra installation or setup
is needed.


