function varargout = tolerance(this, varargin)
% tolerance  Get or set model-specific tolerance levels
%
%
% Syntax for getting tolerance
% =============================
%
%     TolStruct = tolerance(M)
%     Tol = tolerance(M, Scope)
%
%
% Syntax for setting tolerance
% =============================
%
%     M = tolerance(M, TolStruct)
%     M = tolerance(M, @default)
%     M = tolerance(M, Scope, Tol)
%     M = tolerance(M, Scope, @default)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Scope` [ `'solve'` | `'eigen'` | `'mse'` ] - Scope in which the new
% tolerance level will be used.
%
% * `Tol` [ numeric ] - New tolerance level used to detect singularities
% and unit roots; if `@default` tolerance will be set to its default value.
%
% * `TolStruct` [ numeric ] - Structure with new levels of tolerance for
% each scope.
%
%
% Output arguments
% =================
%
% * `Tol` [ numeric ] - Currently assigned level of tolerance.
%
% * `TolStruct` [ numeric ] - Structure with currently assigned levels of
% tolerance for each scope.
%
% * `M` [ model ] - Model object with the new level of tolerance set.
%
%
% Description
% ============
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

template = model.DEFAULT_TOLERANCE_STRUCT;
lsField = fieldnames(template);

%--------------------------------------------------------------------------

if nargin==1
    % Get tolerance:
    % tolStruct = tolerance(this)
    varargout{1} = this.Tolerance;
    return
end

if nargin==2 && isstruct(varargin{1}) ...
        && isequal(sort(lsField), sort(fieldnames(varargin{1})))
    % Set tolerance:
    % this = tolerance(this, tolStruct)
    for i = 1 : numel(lsField)
        name = lsField{i};
        this.Tolerance.(name) = varargin{1}.(name);
    end
    return
end

if nargin==2 && isequal(varargin{1},@default)
    % Set tolerance:
    % this = tolerance(this, @default)
    this.Tolerance = model.DEFAULT_TOLERANCE_STRUCT;
    varargout{1} = this;
    return
end
    
scope = varargin{1};
switch lower(scope)
    case {'solution', 'solve'}
        scope = 'Solve';
        def = model.DEFAULT_SOLVE_TOLERANCE;
    case {'eigen', 'unitroot'}
        scope = 'Eigen';
        def = model.DEFAULT_EIGEN_TOLERANCE;
    case {'mse'}
        scope = 'Mse';
        def = model.DEFAULT_MSE_TOLERANCE;
    case {'diffstep'}
        scope = 'DiffStep';
        def = model.DEFAULT_DIFF_STEP;
    case {'sevn2', 'sevn2patch'}
        scope = 'Sevn2Patch';
        def = model.DEFAULT_SEVN2PATCH_TOLERANCE;
    otherwise
        utils.error('model:tolerance', ...
            'Invalid tolerance scope');
end

if nargin==2
    % Get tolerance:
    % Tol = tolerance(M,Scope)
    varargout{1} = this.Tolerance.(scope);
    return
end

if nargin==3
    tol = varargin{2};
    if isnumericscalar(tol) && tol>0
        % Set tolerance:
        % M = tolerance(M,Scope,Tol)
        this.Tolerance.(scope) = tol;
    elseif isequal(tol, @default)
        % Set tolerance:
        % M = tolerance(M,Scope,@default)        
        this.Tolerance.(scope) = def;
    else
        utils.error('model:tolerance', ...
            'Tolerance level must be positive scalar');
    end
    varargout{1} = this;
    return
end

end
