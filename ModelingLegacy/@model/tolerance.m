function varargout = tolerance(this, varargin)
% tolerance  Get or set model-specific tolerance levels
%{
% ## Syntax for Getting Tolerance ##
%
%     tolStruct = tolerance(model)
%     tol = tolerance(model, scope)
%
%
% ## Syntax for Setting Tolerance ##
%
%     model = tolerance(model, tolStruct)
%     model = tolerance(model, @default)
%     model = tolerance(model, scope, tol)
%     model = tolerance(model, scope, @default)
%
%
% ## Input Arguments ##
%
% * `model` [ model ] - Model object.
%
% * `scope` [ `'Solve'` | `'Eigen'` | `'MSE'` | `'Steady'` ] - Scope in
% which the new tolerance level will be used.
%
% * `tol` [ numeric ] - New tolerance level used to detect singularities
% and unit roots; if `@default` tolerance will be set to its default value.
%
% * `tolStruct` [ struct ] - Struct with new levels of tolerance for
% each scope.
%
%
% ## Output Arguments ##
%
% * `tol` [ numeric ] - Currently assigned level of tolerance.
%
% * `tolStruct` [ numeric ] - Structure with currently assigned levels of
% tolerance for each scope.
%
% * `model` [ model ] - Model object with the new levels of tolerance set.
%
%
% ## Description ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if nargin==1
    %
    % Get Tolerance:
    % tolStruct = tolerance(this)
    %
    varargout{1} = this.Tolerance;
    return
end

if nargin==2 && isa(varargin{1}, 'shared.Tolerance')
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

