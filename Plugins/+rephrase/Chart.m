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
            this.Settings.ChartType = 'Series';
            this.Settings.StartDate = double(startDate);
            this.Settings.EndDate = double(endDate);
        end%


        function build(this, varargin)
            this = locallyResolveDates(this);
            build@rephrase.Container(this, varargin{:});
            if isfield(this.Settings, 'Highlight')
                if isscalar(this.Settings.Highlight) && ~iscell(this.Settings.Highlight)
                    this.Settings.Highlight = {this.Settings.Highlight};
                end
            end
            if ~isfield(this.Settings, 'DateFormat')
                try
                    this.Settings.DateFormat = string(this.Parent.Settings.DateFormat);
                catch
                    this.Settings.DateFormat = locallyCreateDefaultDateFormat(this.Settings.StartDate);
                end
            end
        end%
    end


    methods (Static)
        function this = fromSeries(chartInputs, varargin)
            this = rephrase.Chart(chartInputs{:});
            for i = 1 : numel(varargin)
                series = rephrase.Series.fromMultivariate(varargin{i}{:});
                add(this, series);
            end
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


function this = locallyResolveDates(this)
    %(
    if isempty(this.Settings.StartDate) || isinf(this.Settings.StartDate)
        try
            this.Settings.StartDate = double(this.Parent.Settings.StartDate);
        end
    end
    if isempty(this.Settings.EndDate) || isinf(this.Settings.EndDate)
        try
            this.Settings.EndDate = double(this.Parent.Settings.EndDate);
        end
    end
    this.Settings.StartDate = dater.toIsoString(this.Settings.StartDate, "m");
    this.Settings.EndDate = dater.toIsoString(this.Settings.EndDate, "m");
    %)
end%
