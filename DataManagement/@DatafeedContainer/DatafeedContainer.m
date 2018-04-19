classdef DatafeedContainer < handle
    properties
        Name = cell.empty(1, 0)
        Frequency = Frequency.empty(1, 0)
        Ymd = cell(1, 0)
        Data = cell.empty(1, 0)
        ColumnNames = cell.empty(1, 0)
        UserData = cell.empty(1, 0)
    end


    methods
        function this = DatafeedContainer(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'DatafeedContainer')
                this = varargin{1};
                return
            end
            persistent INPUT_PARSER
            if isempty(INPUT_PARSER)
                INPUT_PARSER = extend.InputParser('DatafeedContainer/DatafeedContainer');
                INPUT_PARSER.addRequired('NumOfSeries', @(x) isnumeric(x) && numel(x)==1 && x==round(x));
            end
            INPUT_PARSER.parse(varargin{:});
            numSeries = INPUT_PARSER.Results.NumOfSeries;
            this.Name = repmat({''}, 1, numSeries);
            this.Frequency = repmat(Frequency.NaF, 1, numSeries);
            this.Ymd = cell(1, numSeries);
            this.Data = cell(1, numSeries);
            this.ColumnNames = repmat({''}, 1, numSeries);
            this.UserData = cell(1, numSeries);
        end


        function ith(this, i, name, frequency, ymd, data, columnComments, userData)
            this.Name{i} = name;
            this.Frequency(i) = frequency;
            this.Ymd{i} = ymd;
            this.Data{i} = data;
            this.ColumnNames{i} = columnComments;
            this.UserData{i} = userData;
        end


        function n = length(this)
            n = length(this.Name);
        end


        function outputData = export(this, outputData, dateFromSerial, timeSeriesConstructor)
            if nargin<3
                dateFromSerial = getappdata(0, 'IRIS_DateFromSerial');
            end
            if nargin<4
                timeSeriesConstructor = getappdata(0, 'IRIS_TimeSeriesConstructor');
            end
            numSeries = length(this);
            for i = 1 : numSeries
                ithFrequency = this.Frequency(i);
                ithYmd = this.Ymd{i};
                ithSerial = ymd2serial(ithFrequency, ithYmd(:, 1), ithYmd(:, 2), ithYmd(:, 3));
                ithDates = dateFromSerial(ithFrequency, ithSerial);
                ithName = this.Name{i};
                ithData = this.Data{i};
                ithColumnNames = this.ColumnNames{i};
                ithUserData = this.UserData{i};
                outputData.(ithName) = timeSeriesConstructor(ithDates, ithData, ithColumnNames, ithUserData);
            end
        end


        function checkFrequencies(this)
            ixUnknown = isnan(this.Frequency);
            if any(ixUnknown)
                throw( ...
                    exception.Base('Datafeed:FeedUnknownFrequency', 'warning'), ...
                    this.Name(ixUnknown) ...
                );
            end
        end
    end


    methods (Static)
        varargout = fromFred(varargin)
    end
end
