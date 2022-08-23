% SVAR  Structural Vector Autoregressions
%{
% This section describes the `SVAR` class of objects.
%
% Description
% ------------
%
% Structural autoregressions are VAR models with a vector of the original
% forecast errors transformed into a vector of structural errors. The
% structural errors are uncorrelated, and have an impact matrix associated
% with them:
%
% \[
% y_t = \sum_{k=1}^{p} A_k\, y_{t-k} + K + J g_t + B u_t
% \]
%
% where \(u_t\) is a vector of structural errors; compare the [reduced-form
% VARs](VAR/index.html#Description), and 
%
% \[
% \mathrm{E} [u_t u_t'] = \mathrm{diag}(\sigma_1^2, ..., \sigma_n^2) .
% \]
%
% The transformation \( B \) is not unique: there are infinitely many
% possible transformations that give rise to uncorrelated errors. To chose
% among them, the user needs to specify a set of identifying restrictions.
% IRIS supports the following types of identifying restrictions:
%
% * triangular impact matrix by Cholesky factorization;
% * triangular matrix of long-run multipliers;
% * reduced-rank singular value decomposition;
% * random Householder transformations satisfying user restrictions.
%
% SVAR methods:
%
%
% SVAR objects inherit all properties and methods (functions) from the underlying VAR objects, and
% add those described here. See [`VAR`](VAR/index.html) to get  help on the properties and methods
% inherited from VAR.
%
%
% Categorical List
% -----------------
%
% __Constructor__
%
%   SVAR - Create structural VAR by identifying reduced-form VAR
%
% __Properties Directly Accessible__
%
%   B - Impact matrix of structural errors
%   Std - Std deviations of structural errors
%   Method - Identification method
%   Rank - Rank of covariance matrix
%
%
% __Getting Information about SVAR Objects__
%
%   get - Query SVAR object properties
%
%
% __Simulation__
%
%   srf - Shock response function
%
%
% __Stochastic Properties__
%
%   fevd - Forecast error variance decomposition for SVAR variables
%
%
% __Manipulating SVAR Objects__
%
%   sort - Sort SVAR parameterisations by squared distance of shock reponses to median
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team
    
classdef (CaseInsensitiveProperties=true) ...
    SVAR ...
    < VAR

    properties
        % B  Matrix of instantaneous shock multipliers
        B = double.empty(0)

        B0 = double.empty(0)
        A0 = double.empty(0)

        % Std  Std deviations of structural errors
        Std = double.empty(0)

        % Method  Identification method
        Method = cell.empty(1, 0)

        % Rank  Rank of covariance matrix
        Rank = double.empty(1, 0)
    end
    
    
    
    
    methods
        function this = SVAR(varargin)
            % SVAR  Create structural VAR by identifying reduced-form VAR
            %
            % __Syntax__
            %
            %     [S, DATA, B, COUNT] = SVAR(V, DATA, ...)
            %
            %
            % __Input Arguments__
            %
            % * `V` [ VAR ] - Reduced-form VAR object.
            %
            % * `DATA` [ struct | tseries ] - Data associated with the input VAR
            % object.
            %
            %
            % __Output Arguments__
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
            %
            % __Options__
            %
            % * `'maxIter'` [ numeric | *`0`* ] - Maximum number of attempts when
            % `'method'='draw'`.
            %
            % * `'method'` [ *`'chol'`* | `'householder'` | `'qr'` | `'svd'` ] -
            % Method that will be used to identify structural VAR and structural shocks.
            %
            % * `'nDraw'` [ numeric | *`0`* ] - Target number of successful draws when
            % `'method'='draw'`.
            %
            % * `'reorder'` [ numeric | *empty* ] - Reorder VAR variables before
            % identifying structural shocks, and bring the variables back in original
            % order afterwards. Use the option `BackorderResiduals` to control if
            % also the structural shocks are to be brought back in original order.
            %
            % * `'output'` [ *`'auto'`* | `'dbase'` | `'Series'` ] - Format of output
            % data.
            %
            % * `'progress'` [ `true` | *`false`* ] - Display progress bar in the
            % command window.
            %
            % * `'rank'` [ numeric | *`Inf`* ] - Reduced rank of the covariance matrix of
            % structural residuals when `Method='svd'`; `Inf` means full rank is
            % preserved.
            %
            % * `'backOrderResiduals'` [ *`true`* | `false` ] - Bring the identified
            % structural shocks back in original order after identification; works with
            % `'reorder'`.
            %
            % * `'std'` [ numeric | *`1`* ] - Std deviation of structural residuals;
            % the resulting structural covariance matrix will be re-scaled (divided) by
            % this factor.
            %
            % * `'test'` [ char ] - Works with `'method=draw'` only; a string that
            % will be evaluated for each random draw of the impact matrix `B`. The
            % evaluation must result in `true` or `false`; only the matrices `B` that
            % evaluate to `true` will be kept. See Description for more on how to write
            % the option `'test'`.
            %
            %
            % __Description__
            %
            % _Identify SVAR by Random Householder Transformations_
            %
            % The structural impact matrices `B` are randomly generated using a
            % Householder transformation algorithm. Each matrix is tested by evaluating
            % the `test` string supplied by the user. If it evaluates to true the
            % matrix is kept and one more SVAR parameterisation is created, if it is
            % false the matrix is discarded.
            %
            % The `test` string can refer to the following characteristics:
            %
            % * `S` -- the impulse (or shock) response function; the `S(i, j, k)` element
            % is the response of the `i`-th variable to the `j`-th shock in
            % period `k`.
            %
            % * `Y` -- the asymptotic cumulative response function; the `Y(i, j)`
            % element is the asumptotic (long-run) cumulative response of the `i`-th
            % variable to the `j`-th shock.
            %
            % __Example__
            %
            
            % -IRIS Macroeconomic Modeling Toolbox
            % -Copyright (c) 2007-2022 IRIS Solutions Team
            
            this = this@VAR( );
            this.IsIdentified = true;
            if nargin==0
                return
            elseif nargin==1 && isa(varargin{1}, 'SVAR')
                this = varargin{1};
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
        varargout = identify(varargin)        
        varargout = red2struct(varargin)        
        varargout = implementGet(varargin)
        varargout = testCompatible(varargin)        
    end
    
    
    methods (Access=protected, Hidden)
        varargout = populateFromVAR(varargin)

        varargout = myparsetest(varargin)
        varargout = subsalt(varargin)
        specdisp(varaargin)
    end


    methods (Static)
        varargout = fromPlainRestrictionsA0B(varargin)
    end
end

