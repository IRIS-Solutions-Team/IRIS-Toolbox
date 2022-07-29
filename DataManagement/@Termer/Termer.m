classdef (CaseInsensitiveProperties=true) Termer

    properties
        Terms (:, 1) double = double.empty(0, 1)
        Values (:, :) double = double.empty(0, 0)
        RowLabels (:, 1) string = string.empty(0, 1)
        TermUnits = "YearFrac"
        Round = Inf
        UniqueTerms = true
        OrderTerms = true
    end


    methods
        function this = Termer(terms, values, rowLabels, varargin)
            if nargin==0
                return
            end
            if nargin<3
                rowLabels = [];
            end
            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
            this = add(this, terms, values, rowLabels);
        end%


        function this = clip(this, minTerm, maxTerm)
            maxTerm = max(maxTerm);
            minTerm = min(minTerm);
            inx = this.Terms>=minTerm & this.Terms<=maxTerm;
            this.Terms(~inx, :) = [];
            this.Values(~inx, :) = [];
            this.RowLabels(~inx, :) = [];
        end%


        function varargout = plot(this, varargin)
            h = plot(this.Terms, this.Values, varargin{:});
            if nargout>0
                varargout = {h};
            end
        end%


        function this = add(this, terms, values, rowLabels)
            if ~isinf(this.Round)
                terms = round(double(terms(:, :)), this.Round);
            end
            values = double(values(:, :));
            rowLabels = reshape(string(rowLabels), [], 1);
            if this.UniqueTerms
                intersectTerms = intersect(terms, this.Terms, 'stable');
                if ~isempty(intersectTerms)
                    exception.error(["Termer", "This term already exists in the Termer object: %g"], intersectTerms);
                end
            end
            this.Terms = [this.Terms; terms];
            this.Values = [this.Values; values];
            if isempty(rowLabels)
                rowLabels = repmat("", numel(terms), 1);
            end
            this.RowLabels = [this.RowLabels; rowLabels];
            if this.OrderTerms
                [this.Terms, pos] = sort(this.Terms);
                this.Values = this.Values(pos, :);
                this.RowLabels = this.RowLabels(pos, :);
            end
        end%
    end
end

