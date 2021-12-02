classdef Chart ...
    < rephrase.Element ...
    & rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.CHART
    end


    properties (Constant, Hidden)
        PossibleChildren = [ 
            rephrase.Type.SERIES
        ]
    end


    methods
        function this = Chart(title, startDate, endDate, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings.StartDate = double(startDate);
            this.Settings.EndDate = double(endDate);
        end%


        function build(this, varargin)
            build@rephrase.Container(this, varargin{:});
            if isfield(this.Settings, 'Highlight')
                if isscalar(this.Settings.Highlight) && ~iscell(this.Settings.Highlight)
                    this.Settings.Highlight = {this.Settings.Highlight};
                end
            end
            if ~isfield(this.Settings, 'DateFormat')
                this.Settings.DateFormat = locallyCreateDefaultDateFormat(this.Settings.StartDate);
            end
            this.Settings.StartDate = dater.toIsoString(this.Settings.StartDate, "m");
            this.Settings.EndDate = dater.toIsoString(this.Settings.EndDate, "m");
        end%
    end


    methods (Static)
        function this = fromSeries(chartInputs, seriesInputs)
            this = rephrase.Chart(chartInputs{:});
            series = rephrase.Series.fromMultivariate(seriesInputs{:});
            add(this, series);
        end%
    end
end 

%
% Local functions
%

function dateFormat = locallyCreateDefaultDateFormat(startDate)
    %(
    switch dater.getFrequency(startDate)
        case Frequency__.Yearly
            dateFormat = "YYYY";
        case Frequency__.Quarterly
            dateFormat = "YYYY-Q";
        case {Frequency__.HalfYearly, Frequency__.Monthly}
            dateFormat = "YYYY-MM";
        case Frequency__.Integer
            dateFormat = "YY";
        otherwise
            dateFormat = "YYYY-MM-DD";
    end
    %)
end%


