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
        function this = Chart(title, range, varargin)
% >=R2019b
%(
            arguments
                title (1, :) string
                range double
            end

            arguments (Repeating)
                varargin
            end
%)
% >=R2019b

            [startDate, endDate, varargin] = local_parseInputDates(range, varargin);

            this = this@rephrase.Element(title, varargin{:});
            this.Content = cell.empty(1, 0);

            this.Settings.ChartType = "Series";
            this.Settings.StartDate = double(startDate);
            this.Settings.EndDate = double(endDate);
        end%

            function build(this, varargin)
                build@rephrase.Container(this, varargin{:});
                this = local_resolveDates(this);
                if isfield(this.Settings, 'Highlight')
                    if isscalar(this.Settings.Highlight) && ~iscell(this.Settings.Highlight)
                        this.Settings.Highlight = {this.Settings.Highlight};
                    end
                end
                if ~isfield(this.Settings, 'DateFormat')
                    try
                        this.Settings.DateFormat = string(this.Parent.Settings.DateFormat);
                    catch
                        this.Settings.DateFormat = local_createDefaultDateFormat(this.Settings.StartDate);
                    end
                end
                this.Settings.StartDate = dater.toIsoString(this.Settings.StartDate, "m");
                this.Settings.EndDate = dater.toIsoString(this.Settings.EndDate, "m");
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

function dateFormat = local_createDefaultDateFormat(startDate)
    %(
    switch dater.getFrequency(startDate)
        case frequency.YEARLY
            dateFormat = "YYYY";
        case frequency.QUARTERLY
            dateFormat = "YYYY-Q";
        case {frequency.HALFYEARLY, frequency.MONTHLY}
            dateFormat = "YYYY-MM";
        case frequency.INTEGER
            dateFormat = "YY";
        otherwise
            dateFormat = "YYYY-MM-DD";
    end
    %)
end%


function this = local_resolveDates(this)
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
    %)
end%


function [startDate, endDate, repeating] = local_parseInputDates(range, repeating)
    %(
    range = double(range);
    if isempty(repeating) || ~isnumeric(repeating{1}) || isempty(repeating{1})
        startDate = range(1);
        endDate = range(end);
    else
        startDate = range(1);
        endDate = double(repeating{1});
        endDate = endDate(end);
        repeating(1) = [];
    end
    %)
end%


