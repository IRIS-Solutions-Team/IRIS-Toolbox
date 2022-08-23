function [this, data, A0, B0, count] = SVAR(V, data, varargin)
% SVAR  Identify SVAR from reduced-form VAR
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

try
    data; %#ok<VUNUS>
catch
    data = [ ];
end

% Parse required input arguments.
ip = inputParser();
ip.addRequired('Data', @(x) isempty(x) || isnumeric(x) || isa(x, 'Series') || isstruct(x));
ip.parse(data);


isnumericscalar = @(x) isnumeric(x) && isscalar(x);
islogicalscalar = @(x) islogical(x) && isscalar(x);
defaults = {
    'MaxIter',0,@(x) isnumericscalar(x) && x >= 0, ...
    'method','chol',@(x) validate.anyString(x,"chol","qr","svd","householder"), ...
    'ndraw',0,@(x) isnumericscalar(x) && x >= 0, ...
    'reorder,ordering',[ ],@(x) isempty(x) || isnumeric(x) || iscellstr(x) || isstring(x), ...
    'progress',false,islogicalscalar, ...
    'backorderresiduals,backorderresidual,reorderresiduals,reorderresidual', ...
    true,@islogical, ...
    'rank',Inf,isnumericscalar, ...
    'std',1,isnumericscalar, ...
    'test','',@ischar, ...
};


opt = passvalopt(defaults, varargin{1:end});

%--------------------------------------------------------------------------

ny = size(V.A, 1);
nv = size(V.A, 3);

% Create an empty SVAR object
this = SVAR();
this.B = nan(ny, ny, nv);
this.B0 = nan(ny, ny, nv);
this.A0 = nan(ny, ny, nv);
this.Std = nan(1, nv);

% Populate properties inherited from superclass VAR
this = struct2obj(this, V);

% Identify the VAR
[this, data, A0, B0, count] = identify(this, data, opt);

if nargin<2 || nargout<2 || isempty(data)
    return
end

% Convert reduced-form residuals to structural shocks
data = red2struct(this, data, opt);

end%

