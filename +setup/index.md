# Installing Iris and its dependencies

## Requirements

* Matlab R2018a or later


## Optional components

* The Optimization Toolbox is needed when estimating structural models.


## Installing Iris

1. Download the latest Iris zip archive, `Iris_Tbx_YYYYMMDD.zip`,
from the download area on \texttt{www.iris-toolbox.com}, and save it in a
temporary location on your disk.

2. If you are going to install Iris in a folder where an older
version already resides, completely delete the old version first.

3. Unzip the archive into a folder on your hard drive, e.g. `C:\IrisT_Tbx`
   (on Windows) or `~/iris-tbx` (on Unix based systems). This folder is
   called the Iris root.

4. After installing a new version of Iris, we recommend that you
remove all older versions of Iris from the Matlab search path, and
restart Matlab.


## Getting started

Each time you want to start working with Iris, run the following line

    >> addpath C:\IrisT_Tbx; iris.startup

where `C:\Iris_Tbx` needs to be, obviously, replaced with the proper Iris
root folder chosen during installation.

Alternatively, you can put the Iris root folder permanently on the Matlab
seatch path (using the menu File - Set Path), and only run the
`iris.startup` command at the beginning of each Iris session.

See also the section on [Starting and quitting Iris](config/Contents).


## Syntax highlighting

You can get the Iris model files syntax-highlighted. Syntax highlighting
improves enormously the readability of the files: it helps you understand
the model better, and discover typos and mistakes more quickly.

Add any number of extensions you want to use for model files (such as
`'model'` or `'iris'`, there is really no limitation) to the Matlab
editor. Open the menu Home - Preferences, unfold Editor/Debugger and
choose Language. Make sure Matlab is selected at the top as the language.
Use the Add button in the File extensions panel to associate any number
of new extensions with the editor. Re-start the editor. The Iris model
files will be syntax highlighted from that moment on.


## Third-party components distributed with Iris

* X13-ARIMA-SEATS (formerly X12-ARIMA, X11-ARIMA). Courtesy of the U.S.
Census Bureau, the X13-ARIMA-SEATS (formerly X12-ARIMA) program is now
incoporated in, and distributed with Iris. No extra installation or setup
is needed.


