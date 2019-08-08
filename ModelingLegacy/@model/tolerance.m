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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

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

if nargin==2 && isequal(varargin{1}, @default)
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
    case {'steady', 'sstate'}
        scope = 'Steady';
        def = model.DEFAULT_STEADY_TOLERANCE;
    otherwise
        THIS_ERROR = { 'Model:InvalidToleranceScope'
                       'This is not a valid tolerance scope: %s ' };
        throw( exception.Base(THIS_ERROR, 'error'), ...
               scope );
end

if nargin==2
    % Get tolerance:
    % Tol = tolerance(model, scope)
    varargout{1} = this.Tolerance.(scope);
    return
end

if nargin==3
    tol = varargin{2};
    if Valid.numericScalar(tol) && tol>0
        % Set tolerance:
        % model = tolerance(model, scope, tol)
        this.Tolerance.(scope) = tol;
    elseif isequal(tol, @default)
        % Set tolerance:
        % model = tolerance(model, scope, @default)        
        this.Tolerance.(scope) = def;
    else
        THIS_ERROR = { 'Model:InvalidToleranceValue'
                       'Tolerance level must be a positive numeric scalar' };
        throw( exception.Base(THIS_ERROR, 'error') );
    end
    varargout{1} = this;
    return
end

end%

