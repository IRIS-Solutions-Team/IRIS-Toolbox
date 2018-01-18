function [this, data, B, count] = SVAR(V, data, varargin)
% SVAR  Identify SVAR from reduced-form VAR
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

try
    data; %#ok<VUNUS>
catch
    data = [ ];
end

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('Data', @(x) isempty(x) || isnumeric(x) || isa(x, 'tseries') || isstruct(x));
pp.parse(data);

opt = passvalopt('SVAR.SVAR', varargin{1:end});

%--------------------------------------------------------------------------

ny = size(V.A, 1);
nv = size(V.A, 3);

% Create an empty SVAR object.
this = SVAR( );
this.B = nan(ny, ny, nv);
this.Std = nan(1, nv);

% Populate properties inherited from superclass VAR.
this = struct2obj(this, V);

% Identify the B matrix.
[this, data, B, count] = identify(this, data, opt);

if nargin<2 || nargout<2 || isempty(data)
    return
end

% Convert reduced-form residuals to structural shocks.
data = red2struct(this, data, opt);

end
