function varargout = tolerance(this, varargin)
% tolerance  Get or set model-specific tolerance levels


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if nargin==1
    %
    % Get Tolerance:
    % tolStruct = tolerance(this)
    %
    varargout{1} = this.Tolerance;
    return
end

if nargin==2 && isa(varargin{1}, 'iris.mixin.Tolerance')
    %
    % Assign Tolerance:
    % this = tolerance(this, Tolerance)
    %
    this.Tolerance = varargin{1};
    return
end

if nargin==2 && isstruct(varargin{1}) 
    %
    % Set Tolerance from struct:
    % this = tolerance(this, struct)
    %
    this.Tolerance = setFromStruct(this, varargin{1});
    varargout{1} = this;
    return
end

if nargin==2 && isequal(varargin{1}, @default)
    %
    % Reset Tolerance to default:
    % this = tolerance(this, @default)
    %
    this.Tolerance = reset(this.Tolerance);
    varargout{1} = this;
    return
end
    
scope = varargin{1};
switch lower(scope)
    case {'solution', 'solve'}
        scope = 'Solve';
    case {'eigen', 'unitroot'}
        scope = 'Eigen';
    case {'mse'}
        scope = 'Mse';
    case {'diffstep'}
        scope = 'DiffStep';
    case {'sevn2', 'sevn2patch'}
        scope = 'Sevn2Patch';
    case {'steady', 'sstate'}
        scope = 'Steady';
end

if nargin==2
    %
    % Get tolerance for one scope:
    % output = tolerance(this, scope)
    %
    varargout{1} = this.Tolerance.(scope);
    return
end

%
% Set tolerance for one scope:
% this = tolerance(this, scope, value)
%
this.Tolerance.(scope) = varargin{2};
varargout{1} = this;

end%

