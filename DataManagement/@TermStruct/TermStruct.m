classdef (CaseInsensitiveProperties=true) TermStruct

    properties
        Terms (:, 1) double = double.empty(0, 1)
        Values (:, :) double = double.empty(0, 0)
        TermUnits = "YearFrac"
        Round = Inf
    end


    methods
        function this = TermStruct(terms, values, varargin)
            if nargin==0
                return
            end
            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
            this = add(this, terms, values);
        end%


        function this = clip(this, minTerm, maxTerm)
            maxTerm = max(maxTerm);
            minTerm = min(minTerm);
            inx = this.Terms>=minTerm & this.Terms<=maxTerm;
            this.Terms(~inx, :) = [];
            this.Values(~inx, :) = [];
        end%


        function varargout = plot(this, varargin)
            h = plot(this.Terms, this.Values, varargin{:});
            if nargout>0
                varargout = {h};
            end
        end%


        function this = add(this, terms, values)
            if ~isinf(this.Round)
                terms = round(double(terms(:, :)), this.Round);
            end
            values = double(values(:, :));
            intersectTerms = intersect(terms, this.Terms, 'stable');
            if ~isempty(intersectTerms)
                exception.error(["TermStruct", "This term already exists in the TermStruct object: %g"], intersectTerms);
            end
            this.Terms = [this.Terms; terms];
            this.Values = [this.Values; values];
            [terms, pos] = sort(terms);
            this.Terms = terms;
            this.Values = values(pos, :);
        end%
    end
end

