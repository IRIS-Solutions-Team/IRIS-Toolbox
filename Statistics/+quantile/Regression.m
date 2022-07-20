classdef Regression < iris.mixin.UserDataContainer & iris.mixin.CommentContainer
    properties
        OutputSeries = cell.empty(1, 0)
        InputSeries = cell.empty(1, 0)
        %Standardize = zeros(2, 0)
        Quantile = double.empty(1, 0)
        Horizon = 1
        Beta = cell(1, 1)
        IxFitted = cell(1, 1)
    end




    properties (SetAccess=protected)
        IsConstant = true
        IsTrend = false
    end




    methods
        function this = Qreg(varargin)
            if isempty(varargin)
                return
            end
            if nargin==1 && isa(varargin{1}, 'quantile.Regression')
                this = varargin{1};
                return
            end
            temp = varargin{1};
            if ischar(temp)
                this.OutputSeries = temp;
            else
                this.OutputSeries = temp{1};
                if numel(temp)>1 && isnumeric(temp{2})
                    this.Horizon = temp{2};
                end
            end
            this.InputSeries = varargin{2};
            this.Quantile = reshape(varargin{3}, 1, [ ]);
        end




        function [this, info] = estimate(this, d, vecDat, varargin)
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            default = {
                'Constant', true, islogicalscalar
                'NonCrossing, NonCross', false, islogicalscalar
                'Smoothing', 0, @(x) isnumericscalar(x) && x>=0
                'Trend', false, islogicalscalar
            };
            opt = passvalopt(default, varargin{:});
            this.IsConstant = opt.Constant;
            this.IsTrend = opt.Trend;

            nx = numel(this.InputSeries);
            [y, x, c] = getData(this, d, vecDat);
            nq = numel(this.Quantile);
            nh = numel(this.Horizon);
            nRhs = size(x, 2) + size(c, 2);
            vecTau = this.Quantile;
            vecTau = sort(vecTau);
            [~, posMedTau] = min(abs(vecTau-0.5));
            this.Beta = repmat({nan(nRhs, nq)}, 1, nh);
            switch opt.Smoothing
                case 0
                    fnSmoothing = @(e, ~) double(e>=0);
                otherwise
                    scale = opt.Smoothing;
                    fnSmoothing = @(e, iqr) 1./(1 + exp(-e./(scale*iqr)));
            end
            ooUnc = optimoptions('fminunc', ...
                'MaxFunctionEvaluations', 10000, ...
                'Display', 'Notify' ...
                );
            ooCon = optimoptions('fmincon', ...
                'MaxFunctionEvaluations', 10000, ...
                'Display', 'Notify' ...
                );
            for i = 1 : nh
                data = [y(:, i), x, c];
                ixMiss = any(isnan(data), 2);
                this.IxFitted{i} = ~ixMiss;
                data = data(~ixMiss, :);
                dataIqr = iqr(data(:, 1));
                A = [ ];
                if opt.NonCrossing
                    A = [x, c];
                    ixMiss = any(isnan(A), 2);
                    A = A(~ixMiss, :);
                end
                tau = vecTau(posMedTau);
                betaMed = singleton(tau, [ ], [ ], [ ]);
                betaAbove = betaMed;
                for j = posMedTau-1 : -1 : 1
                    B = [ ];
                    if opt.NonCrossing
                        B = A*betaAbove;
                    end
                    betaAbove = singleton(vecTau(j), [ ], A, B);
                end
                betaBelow = betaMed;
                A = -A;
                for j = posMedTau+1 : nq
                    B = [ ];
                    if opt.NonCrossing
                        B = A*betaBelow;
                    end
                    betaBelow = singleton(vecTau(j), [ ], A, B);
                end
            end

            if nargout>1
                info = struct( );
                info.Y = y;
                info.X = x;
                info.C = c;
            end

            return




            function beta = singleton(tau, beta0, A, B)
                if isempty(beta0)
                    beta0 = zeros(nRhs, 1);
                end
                if isnan(tau)
                    % Mean
                    beta = data(:, 2:end) \ data(:, 1);
                    this.Beta{i}(:, isnan(this.Quantile)) = beta;
                else
                    % Quantiles
                    problem = struct( );
                    problem.objective = @(beta) this.rho(beta, tau, data, fnSmoothing, dataIqr);
                    problem.x0 = beta0;
                    if isempty(B)
                        problem.solver = 'fminunc';
                        problem.options = ooUnc;
                        [beta, ~, exitFlag] = fminunc(problem);
                    else
                        problem.solver = 'fmincon';
                        problem.options = ooCon;
                        problem.Aineq = A;
                        problem.Bineq = B;
                        [beta, ~, exitFlag] = fmincon(problem);
                    end
                    this.Beta{i}(:, tau==this.Quantile) = beta;
                end
            end
        end




        function [y, info] = forecast(this, d, dat, varargin)
            [outp, info] = run(this, d, dat, varargin{:});
            nh = numel(this.Horizon);
            temp = [ ];
            for i = 1 : nh
                temp = [temp; outp{i}];
            end
            y = Series(dat+this.Horizon, temp);
        end




        function [y, info] = fit(this, d, vecDat, varargin)
            [outp, info] = run(this, d, vecDat, varargin{:});
            nh = numel(this.Horizon);
            y = cell(nh, 1);
            for i = 1 : nh
                h = this.Horizon(i);
                y{i} = Series(vecDat+h, outp{i});
            end
        end




        function [outp, info] = run(this, d, vecDat, w)
            try, w; catch, w = [ ]; end
            x = getInputData(this, d, vecDat);
            c = getDetermData(this, d, vecDat);
            nh = numel(this.Horizon);
            outp = cell(nh, 1);
            for i = 1 : nh
                h = this.Horizon(i);
                beta = this.Beta{i};
                if ~isempty(w)
                    beta = beta*w;
                end
                outp{i} = [x, c]*beta;
            end
            if nargout>1
                info = struct( );
                info.Y = outp;
                info.X = x;
                info.C = c;
            end
        end




        function [y, x, c] = getData(this, d, vecDat)
            y = getOutputData(this, d, vecDat);
            x = getInputData(this, d, vecDat);
            c = getDetermData(this, d, vecDat);
        end




        function y = getOutputData(this, d, vecDat)
            vecDat = vecDat(:);
            numOfPeriods = numel(vecDat);
            nh = numel(this.Horizon);
            y = nan(numOfPeriods, nh);
            name = this.OutputSeries;
            for i = 1 : nh
                h = this.Horizon(i);
                y(:, i) = d.(name)(vecDat+h);
            end
        end




        function data = getInputData(this, d, vecDat)
            list = this.InputSeries;
            vecDat = vecDat(:);
            dateFreq = dater.getFrequency(vecDat(1));
            numOfPeriods = numel(vecDat);
            data = zeros(numOfPeriods, 0);
            nList = numel(list);
            i = 1;
            while i<=nList
                name = list{i};
                i = i + 1;
                x = d.(name);
                xFreq = dater.getFrequency(x.Start);
                vecSh = 0;
                if i<=nList && isnumeric(list{i})
                    vecSh = list{i};
                    i = i + 1;
                end
                temp = vecDat;
                if xFreq>dateFreq
                    temp = convert(temp, xFreq, 'ConversionMonth', 'last');
                end
                for sh = vecSh(:).'
                    data = [data, x(temp+sh)];
                end
            end
        end




        function c = getDetermData(this, d, vecDat);
            vecDat = vecDat(:);
            numOfPeriods = numel(vecDat);
            c = zeros(numOfPeriods, 0);
            if this.IsConstant
                c = [c, ones(numOfPeriods, 1)];
            end
            if this.IsTrend
                c = [c, dat2ttrend(vecDat)];
            end
        end 
    end




    methods (Static)
        function z = rho(beta, tau, data, fnSmoothing, dataIqr)
            e = data*[1; -beta];
            k = fnSmoothing(e, dataIqr);
            z = sum(tau*e.*k + (tau-1)*e.*(1-k));
        end




        function z = ssq(beta, data)
            e = data*[1; -beta];
            z = e.' * e;
        end




        function [xx, m, s] = standardize(x)
            m = median(x, 1);
            s = iqr(x, 1);
            xx = (x - m) ./ s;
        end
    end
end 
