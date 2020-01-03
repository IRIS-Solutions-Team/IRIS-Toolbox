function varargout = get(varargin)
% iris.get  Query current IRIS configuration settings
%
% __Syntax__
%
%     [Value, Value, ...] = iris.get(Query, Query, ...)
%     Config = iris.get( )
%
%
% __Input Arguments__
%
% * `Query` [ char ] - Name of the queried IRIS configuration settings.
%
%
% __Output Arguments__
%
% * `Value` [ ... ] - Current value of the queried configuration
% settings.
%
% * `Config` [ iris.Configuration ] - Configuration object with all current
% configuration settings.
%
%
% __Description__
%
% You can view any of the modifiable options listed in
% [`irisset`](config/irisset), plus the following non-modifiable ones
% (these cannot be changed by the user):
%
% * `'UserConfigPath'` [ char ] - The path to the user configuration file
% called by the last executed `iris.startup`.
%
% * `'IrisRoot'` [ char ] - The current IRIS root directory.
%
% * `'Version'` [ char ] - The current IRIS version string.
%
% When called without any input arguments, the `iris.get( )` function returns a
% struct with all options and their current values.
%
% When used as input arguments in the `iris.get( )` function, the option
% names are case-insensitive. When referring to field names of an output
% struct returned by the `iris.get( )` function, all option names are
% lower-case and case-sensitive.
%
%
% __Example__
%
%     iris.get('dateFormat')
%     ans =
%     YFP
% 
%     g = iris.get( );
%     g.dateformat
%     ans =
%     YFP
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

irisConfig = iris.Configuration.load( );

if isempty(irisConfig)
    irisConfig = iris.reset( );
end

if nargin==0
    varargout = { irisConfig };
    return
end

varargout = cell(1, nargin);
for i = 1 : nargin
    ithOptionName = varargin{i};
    varargout{i} = irisConfig.(ithOptionName);
end

end%
