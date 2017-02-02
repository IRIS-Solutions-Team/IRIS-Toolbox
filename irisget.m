function varargout = irisget(varargin)
% irisget  Query current IRIS config options.
%
% Syntax
% =======
%
%     Value = irisget(Option)
%     S = irisget( )
%
% Input arguments
% ================
%
% * `Option` [ char ] - Name of the queried IRIS configuration option.
%
% Output arguments
% =================
%
% * `Value` [ ... ] - Current value of the queried configuration
% option.
%
% * `S` [ struct ] - Structure with all configuration options and their
% current values.
%
% Description
% ============
%
% You can view any of the modifiable options listed in
% [`irisset`](config/irisset), plus the following non-modifiable ones
% (these cannot be changed by the user):
%
% * `'userConfigPath='` [ char ] - The path to the user configuration file
% called by the last executed [`irisstartup`](config/irisstartup).
%
% * `'irisRoot='` [ char ] - The current IRIS root directory.
%
% * `'version='` [ char ] - The current IRIS version string.
%
% When called without any input arguments, the `irisget` function returns a
% struct with all options and their current values.
%
% When used as input arguments in the `irisget` function, the option names
% are case-insensitive. When referring to field names of an output struct
% returned by the `irisget` function, all option names are lower-case and
% case-sensitive.
%
% Example
% ========
%
%     irisget('dateFormat')
%     ans =
%     YFP
% 
%     g = irisget( );
%     g.dateformat
%     ans =
%     YFP
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:max(nargout, 1)}] = irisconfigmaster('get', varargin{:});

end