% setup  Installing IRIS.
% 
% Requirements
% =============
% 
% * Matlab R2014a or later.
% 
%
% Optional components
% ====================
% 
% * The Optimization Toolbox is needed to compute the steady state of
% non-linear models, and to run estimation.
% 
% * LaTeX is a free typesetting system used to produce PDF reports
% in IRIS.
% 
%
% Installing IRIS
% ================
% 
% 1. Download the latest IRIS zip archive, `IRIS_Tbx_YYYYMMDD.zip`,
% from the download area on \texttt{www.iris-toolbox.com}, and save it in a
% temporary location on your disk.
% 
% 2. If you are going to install IRIS in a folder where an older
% version already resides, completely delete the old version first.
%
% 3. Unzip the archive into a folder on your hard drive, e.g.
% `C:\IRIS_Tbx`. This folder is called the IRIS root.
% 
% 4. After installing a new version of IRIS, we recommend that you
% remove all older versions of IRIS from the Matlab search path, and
% restart Matlab.
% 
%
% Getting started
% ================
% 
% Each time you want to start working with IRIS, run the following line
% 
%     >> addpath C:\IRIS_Tbx; irisstartup
% 
% where `C:\IRIS_Tbx` needs to be, obviously, replaced with the proper IRIS
% root folder chosen during installation.
% 
% Alternatively, you can put the IRIS root folder permanently on the Matlab
% seatch path (using the menu File - Set Path), and only run the
% `irisstartup` command at the beginning of each IRIS session.
% 
% See also the section on [Starting and quitting IRIS](config/Contents).
% 
%
% Syntax highlighting
% ====================
% 
% You can get the IRIS model files syntax-highlighted. Syntax highlighting
% improves enormously the readability of the files: it helps you understand
% the model better, and discover typos and mistakes more quickly.
%
% Add any number of extensions you want to use for model files (such as
% `'model'` or `'iris'`, there is really no limitation) to the Matlab
% editor. Open the menu Home - Preferences, unfold Editor/Debugger and
% choose Language. Make sure Matlab is selected at the top as the language.
% Use the Add button in the File extensions panel to associate any number
% of new extensions with the editor. Re-start the editor. The IRIS model
% files will be syntax highlighted from that moment on.
% 
%
% Third-party components distributed with IRIS
% =============================================
% 
% * X13-ARIMA-SEATS (formerly X12-ARIMA, X11-ARIMA). Courtesy of the U.S.
% Census Bureau, the X13-ARIMA-SEATS (formerly X12-ARIMA) program is now
% incoporated in, and distributed with IRIS. No extra installation or setup
% is needed.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.
