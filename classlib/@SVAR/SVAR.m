% SVAR  Structural Vector Autoregressions (SVAR Objects).
%
%
% SVAR methods:
%
% Constructor
% ============
%
% * [`SVAR`](SVAR/SVAR) - Convert reduced-form VAR to structural VAR.
%
% SVAR objects can call any of the [VAR](VAR/Contents) functions. In
% addition, the following functions are available for SVAR objects.
%
%
% Getting information about SVAR objects
% =======================================
%
% * [`get`](SVAR/get) - Query SVAR object properties.
%
%
% Simulation
% ===========
%
% * [`srf`](SVAR/srf) - Shock (impulse) response function.
%
%
% Stochastic properties
% ======================
%
% * [`fevd`](SVAR/fevd) - Forecast error variance decomposition for SVAR variables.
%
%
% Manipulating SVAR objects
% ==========================
%
% * [`sort`](SVAR/sort) - Sort SVAR parameterisations by squared distance of shock reponses to median.
%
% See help on [VAR](VAR/Contents) objects for other functions available.
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
    
classdef SVAR < VAR
    properties
        B = [ ]; % Coefficient matrix in front of structural residuals.
        Std = [ ]; % Std dev of structural residuals.
        Method = { }; % Identification method.
        Rank = Inf;        
    end
    
    
    
    
    methods
        function This = SVAR(varargin)
            % SVAR  Convert reduced-form VAR to structural VAR.
            %
            % Syntax
            % =======
            %
            %     [S,DATA,B,COUNT] = SVAR(V,DATA,...)
            %
            % Input arguments
            % ================
            %
            % * `V` [ VAR ] - Reduced-form VAR object.
            %
            % * `DATA` [ struct | tseries ] - Data associated with the input VAR
            % object.
            %
            % Output arguments
            % =================
            %
            % * `S` [ VAR ] - Structural VAR object.
            %
            % * `DATA` [ struct | tseries ] - Data with transformed structural
            % residuals.
            %
            % * `B` [ numeric ] - Impact matrix of structural residuals.
            %
            % * `COUNT` [ numeric ] - Number of draws actually performed (both
            % successful and unsuccessful) when `'method'='draw'`; otherwise `COUNT=1`.
            %
            % Options
            % ========
            %
            % * `'maxIter='` [ numeric | *`0`* ] - Maximum number of attempts when
            % `'method'='draw'`.
            %
            % * `'method='` [ *`'chol'`* | `'householder'` | `'qr'` | `'svd'` ] -
            % Method that will be used to identify structural VAR and structural shocks.
            %
            % * `'nDraw='` [ numeric | *`0`* ] - Target number of successful draws when
            % `'method'='draw'`.
            %
            % * `'reorder='` [ numeric | *empty* ] - Reorder VAR variables before
            % identifying structural shocks, and bring the variables back in original
            % order afterwards. Use the option '`backorderResiduals='` to control if
            % also the structural shocks are to be brought back in original order.
            %
            % * `'output='` [ *`'auto'`* | `'dbase'` | `'tseries'` ] - Format of output
            % data.
            %
            % * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
            % command window.
            %
            % * `'rank='` [ numeric | *`Inf`* ] - Reduced rank of the covariance matrix of
            % structural residuals when `'method=' 'svd'`; `Inf` means full rank is
            % preserved.
            %
            % * `'backOrderResiduals='` [ *`true`* | `false` ] - Bring the identified
            % structural shocks back in original order after identification; works with
            % `'reorder='`.
            %
            % * `'std='` [ numeric | *`1`* ] - Std deviation of structural residuals;
            % the resulting structural covariance matrix will be re-scaled (divided) by
            % this factor.
            %
            % * `'test='` [ char ] - Works with `'method=draw'` only; a string that
            % will be evaluated for each random draw of the impact matrix `B`. The
            % evaluation must result in `true` or `false`; only the matrices `B` that
            % evaluate to `true` will be kept. See Description for more on how to write
            % the option `'test='`.
            %
            % Description
            % ============
            %
            % Identification random Householder transformations
            % --------------------------------------------------
            %
            % The structural impact matrices `B` are randomly generated using a
            % Householder transformation algorithm. Each matrix is tested by evaluating
            % the `test` string supplied by the user. If it evaluates to true the
            % matrix is kept and one more SVAR parameterisation is created, if it is
            % false the matrix is discarded.
            %
            % The `test` string can refer to the following characteristics:
            %
            % * `S` -- the impulse (or shock) response function; the `S(i,j,k)` element
            % is the response of the `i`-th variable to the `j`-th shock in
            % period `k`.
            %
            % * `Y` -- the asymptotic cumulative response function; the `Y(i,j)`
            % element is the asumptotic (long-run) cumulative response of the `i`-th
            % variable to the `j`-th shock.
            %
            % Example
            % ========
            %
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
            This = This@VAR( );
            if nargin == 0
                return
            elseif nargin == 1 && isa(varargin{1},'SVAR')
                This = varargin{1};
                return
            end
            % The case with a VAR object as the first input argument is
            % handled as a VAR method because otherwise we couldn't return
            % SVAR data as a second output argument (not allowed in
            % constructors).
        end
    end
    
    
    
    
    methods
        varargout = fevd(varargin)        
        varargout = irf(varargin)              
        varargout = get(varargin)
        varargout = sort(varargin)        
        varargout = srf(varargin)        
        varargout = sspace(varargin)
    end
    
    
    
    
    methods (Hidden)
        varargout = myidentify(varargin)        
        varargout = myred2struct(varargin)        
        varargout = implementGet(varargin)
    end
    
    
    
    
    methods (Access=protected,Hidden)
        varargout = mybmatrix(varargin)
        varargout = mycompatible(varargin)
        varargout = mycovmatrix(varargin)
        varargout = myparsetest(varargin)
        varargout = subsalt(varargin)
        specdisp(varaargin)
    end
end
