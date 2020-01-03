% config  Starting, quitting, and configuring IRIS.
%
% This section describes how to start and quit an IRIS session, and how to
% customise some of the IRIS configuration options.
%
% The most common way of starting an IRIS session (after you have installed
% the IRIS files on your disk) is to run the following line in the
% Matlab command window:
%
%     addpath C:\IRIS_Tbx; irisstartup( );
%
% The first command, `addpath`, adds the IRIS root folder to the Matlab
% search path. The second command, `irisstartup`, initialises IRIS and puts
% the other necessary IRIS subfolders, classes, and internal packages on
% the search path. *Never* add these other subfolders, classes and packages
% to the search path by yourself.
%
%
% Starting and quitting IRIS
% ===========================
%
% * [`irisstartup`](config/irisstartup) - Start an IRIS session.
% * [`irisfinish`](config/irisfinish) - Close the current IRIS session.
% * [`iriscleanup`](config/iriscleanup) - Remove IRIS from Matlab and clean up.
%
%
% Getting information about IRIS
% ===============================
%
% * [`irisget`](config/irisget) - Query current IRIS config options.
% * [`irisman`](config/irisman) - Open IRIS Reference Manual PDF.
% * [`irisroot`](config/irisroot) - Current IRIS root folder.
% * [`irisrequired`](config/irisrequired) - Throw error if the installed version of IRIS fails to comply with the required minimum.
% * [`irisversion`](config/irisversion) - Current IRIS version.
%
%
% Changes in configuration
% =========================
%
% * [`irisset`](config/irisset) - Change configurable IRIS options.
% * [`irisreset`](config/irisreset) - Reset IRIS configuration options to start-up values.
% * [`irisuserconfig`](config/irisuserconfighelp) - User configuration file called at the IRIS start-up.
%
%
% Getting on-line help on configuration functions
% ================================================
%
%     help config
%     help function_name
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.