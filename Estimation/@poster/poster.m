classdef poster < iris.mixin.GetterSetter
% poster  Posterior Simulator (poster Objects).
%
% Posterior simulator objects allow evaluating the behaviour of the
% posterior dsitribution, and drawing model parameters from the posterior
% distibution.
%
% Posterior objects are set up within the
% [`model/estimate`](model/estimate) function and returned as the second
% output argument - the set up and initialisation of the posterior object
% is fully automated in this case. Alternatively, you can set up a
% posterior object manually, by setting all its properties appropriately.
%
%
% Poster methods:
%
% __Constructor__
%
% * [`poster`](poster/poster) - Create new empty posterior simulation (poster) object.
%
%
% __Evaluating Posterior Density__
%
% * [`arwm`](poster/arwm) - Adaptive random-walk Metropolis posterior simulator.
% * [`eval`](poster/eval) - Evaluate posterior density at specified points.
% * [`regen`](poster/regen) - Regeneration time MCMC Metropolis posterior simulator.
%
%
% __Chain Statistics__
%
% * [`stats`](poster/stats) - Evaluate selected statistics of ARWM chain.
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

    properties
        % Names of parameters.
        ParameterNames (1, :) string = string.empty(1, 0)

        % Objective function.
        MinusLogPostFunc = [ ]
        MinusLogPostFuncArgs = { }
        MinusLogLikFunc = [ ]
        MinusLogLikFuncArgs = { }
        LogPriorFunc = { }

        % Log posterior density at initial vector.
        InitLogPost = NaN

        % Initial vector of parameters.
        InitParam = zeros(1, 0)

        % Initial proposal cov matrix; will be multiplied by squared
        % `.InitScale`.
        InitProposalCov = [ ]

        % Cholesky factor of initial proposal cov matrix; if empty,
        % chol(...) is performed on `.InitProposalCov`.
        InitProposalChol = [ ]

        % Initial sqrt of factor by which cov matrix will be multiplied.
        InitScale = 1/3

        % Initial counts of draws, acceptances, and burn-ins.
        InitCount = [0, 0, 0]

        % Lower and upper bounds on individual parameters.
        Lower = [ ]
        Upper = [ ]
    end


    methods
        function this = poster(varargin)
            % poster  Create new empty posterior simulation (poster) object.
            %
            % Syntax
            % =======
            %
            %     P = poster( )
            %
            %
            % Description
            % ============
            %
            % Creating and initialising posterior simulation objects manually is
            % unnecessary. Posterior simulation objects are created and initialised
            % automatically within estimation methods of various other objects, such as
            % [`model/estimate`](model/estimate).
            %

            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2022 IRIS Solutions Team.

            if isempty(varargin)
                return
            elseif length(varargin)==1 && isa(varargin{1}, 'poster')
                this = varargin{1};
            elseif length(varargin)==1 && isstruct(varargin{1})
                this = struct2obj(this, varargin{1});
            end
        end


        varargout = arwm(varargin)
        varargout = neighbors(varargin)
        varargout = plotNeighbors(varargin)
        varargout = eval(varargin)
        varargout = stats(varargin)


        function this = set.ParameterNames(this, list)
            if ischar(list) || isstring(list) || iscellstr(list)
                if ischar(list)
                    list = regexp(list,' \w+', 'match');
                end
                this.ParameterNames = textual.stringify(list);
                n = numel(this.ParameterNames);
                if n~=numel(unique(this.ParameterNames))
                    utils.error('poster:set:ParameterNames', ...
                        'Parameter names must be unique.');
                end
                this.LogPriorFunc = cell(1, n); %#ok<MCSUP>
                this.Lower = -inf(1, n); %#ok<MCSUP>
                this.Upper = inf(1, n); %#ok<MCSUP>
            elseif isnumeric(list) && isscalar(list)
                this.ParameterNames = "p" + string(1:list);
            else
                utils.error('poster:set:ParameterNames', ...
                    'Invalid assignment to poster.ParameterNames.');
            end
        end




        function this = set.InitParam(this, init)
            n = numel(this.ParameterNames); %#ok<MCSUP>
            if isnumeric(init)
                init = init(:).';
                if length(init)==n
                    this.InitParam = init;
                    chkbounds(this);
                else
                    utils.error('poster:set:InitParam', ...
                        ['Length of the initial parameter vector ', ...
                        'must match the number of parameters.']);
                end
            else
                utils.error('poster:set:InitParam', ...
                    'Invalid assignment to poster.InitParam.');
            end
        end




        function this = set.Lower(this, X)
            n = numel(this.ParameterNames); %#ok<MCSUP>
            if numel(X)==n
                this.Lower = -inf(1, n);
                this.Lower(:) = X(:);
                chkbounds(this);
            else
                utils.error('poster:set:LowerBounds', ...
                    ['Length of lower bounds vector must match ', ...
                    'the number of parameters.']);
            end
        end




        function this = set.Upper(this, X)
            n = numel(this.ParameterNames); %#ok<MCSUP>
            if numel(X)==n
                this.Upper = -inf(1, n);
                this.Upper(:) = X(:);
                chkbounds(this);
            else
                utils.error('poster:set:UpperBounds', ...
                    ['Length of upper bounds vector must match ', ...
                    'the number of parameters.']);
            end
        end




        function this = set.InitProposalCov(this, C)
            if ~isnumeric(C)
                utils.error('poster:set:InitProposalCov', ...
                    'Invalid assignment to poster.InitProposalCov.');
            end
            n = numel(this.ParameterNames); %#ok<MCSUP>
            C = C(:,:);
            if any( size(C)~=n )
                utils.error('poster:set:InitProposalCov', ...
                    ['Size of the initial proposal covariance matrix ', ...
                    'must match the number of parameters.']);
            end
            C = (C + C')/2;
            CDiag = diag(C);
            if ~all( CDiag>0 )
                utils.error('poster:set:InitProposalCov', ...
                    ['Diagonal elements of the initial proposal ', ...
                    'cov matrix must be positive.']);
            end
            ok = false;
            adjusted = false;
            offDiagIndex = eye(size(C))==0;
            count = 0;
            while ~ok && count<100
                try
                    chol(C);
                    ok = true;
                catch %#ok<CTCH>
                    C(offDiagIndex) = 0.9*C(offDiagIndex);
                    C = (C + C')/2;
                    adjusted = true;
                    ok = false;
                    count = count + 1;
                end
            end
            if ~ok
                utils.error('poster:set:InitProposalCov', ...
                    ['Cannot make the initial proposal cov matrix ', ...
                    'positive definite.']);
            elseif adjusted
                utils.warning('poster:set:InitProposalCov', ...
                    ['The initial proposal cov matrix ', ...
                    'adjusted to be numerically positive definite.']);
            end
            this.InitProposalCov = C;
        end
    end




    methods (Hidden)
        function disp(this)
            builtin('disp', this);
        end




        function this = setlowerbounds(this, varargin)
            this = setbounds(this,'lower',varargin{:});
        end




        function this = setupperbounds(this, varargin)
            this = setbounds(this,'upper',varargin{:});
        end




        function this = setbounds(this, lowerUpper, varargin)
            if length(varargin)==1 && isnumeric(varargin{1})
                if lowerUpper(1)=='l'
                    this.Lower = varargin{1};
                else
                    this.Upper = varargin{1};
                end
            elseif length(varargin)==2 ...
                    && (ischar(varargin{1}) || iscellstr(varargin{1})) ...
                    && isnumeric(varargin{2})
                userList = varargin{1};
                if ischar(userList)
                    userList = regexp(userList, '\w+', 'match');
                end
                userList = textual.stringify(userList);
                pos = nan(size(userList));
                for i = 1 : numel(userList)
                    temp = find(this.ParameterNames==userList(i));
                    if ~isempty(temp)
                        pos(i) = temp;
                    end
                end
                if any(isnan(pos))
                    utils.error('poster:setbounds', ...
                        'This is not a valid parameter name: ''%s''.', ...
                        userList(isnan(pos)));
                end
                if lowerUpper(1)=='l'
                    this.Lower(pos) = reshape(varargin{2}, 1, []);
                else
                    this.Upper(pos) = reshape(varargin{2}, 1, []);
                end
            end
            chkbounds(this);
        end




        function this = setprior(this, name, func)
            if (isstring(name) || ischar(name)) && isa(func, 'function_handle')
                pos = find(this.ParameterNames==string(name));
                if ~isempty(pos)
                    this.LogPriorFunc{pos} = func;
                else
                    utils.error('poster:setprior', ...
                        'This is not a valid parameter name: ''%s''.', ...
                        name);
                end
            end
        end%


        function chkbounds(this)
            n = numel(this.ParameterNames);
            if isempty(this.InitParam)
                return
            end
            if isempty(this.Lower)
                this.Lower = -inf(1, n);
            end
            if isempty(this.Upper)
                this.Upper = inf(1, n);
            end
            inx = this.InitParam<this.Lower | this.InitParam>this.Upper;
            if any(inx)
                utils.error('poster:chkbounds', ...
                    'The initial value for this parameter is out of bounds: %s', ...
                    this.ParameterNames(inx));
            end
        end%
    end


    methods (Access=protected, Hidden)
        varargout = mylogpost(varargin)
        varargout = mysimulate(varargin)
    end


    methods (Static, Hidden)
        varargout = loadobj(varargin)
        varargout = myksdensity(varargin)
    end
end
