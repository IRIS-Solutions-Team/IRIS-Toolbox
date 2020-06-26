% ProgressBar  Display command line progress bar
%
% Backend [IrisToolbox] class
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling 
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

classdef ProgressBar < handle    
    properties
        Title = ''
        TitleRow = ''
        NumProgress = 40
        TotalCount = 0
        RunningCount = 0
        LastIndicatorRow = ''
        LastNumFullBars = 0
        Done = false
        Diary = cell.empty(0, 2)
    end


    properties (Constant)
        FULL_BAR =  char(9608)
        PARTIAL_BAR =  char(9615:-1:9608)
        EMPTY_BAR = ' '
        TITLE_FILL = '.'
        LEFT_EDGE = '|'
        RIGHT_EDGE = '|'
    end
    
    
    methods
        function this = ProgressBar(varargin)
            if nargin>=1
                this.Title = varargin{1};
            end
            if nargin>=2
                this.TotalCount = double(varargin{2});
                this.RunningCount = 0;
            end
            %{
            this.TitleRow = [this.TITLE_FILL , repmat(this.TITLE_FILL, 1, this.NumProgress), this.TITLE_FILL];
            if ~isempty(this.Title)
                this.Title = this.Title(1:min(end, this.NumProgress-4));
                this.TitleRow(3+(1:length(this.Title))) = this.Title;
            end
            %}
            this.TitleRow = [repmat(' ', 1, strlength(this.LEFT_EDGE)), this.Title];
            textual.looseLine( );
            fprintf('%s', this.TitleRow);
            this.LastIndicatorRow = sprintf('%s%*s%s', this.LEFT_EDGE, this.NumProgress, ' ', this.RIGHT_EDGE);
            fprintf('\n');
            fprintf('%s', this.LastIndicatorRow);
            this.Diary = cell.empty(0, 2);
        end%
    
        
        function update(this, varargin)
            if this.Done
                return
            end
            [numFullBars, posPartialBar, permille] = getNumBars(this, varargin{:});
            fullBars = repmat(this.FULL_BAR, 1, numFullBars);
            if posPartialBar>0
                partialBar = this.PARTIAL_BAR(posPartialBar);
            else
                partialBar = char.empty(1, 0);
            end
            emptyBars = repmat(this.EMPTY_BAR, 1, this.NumProgress - numel(fullBars) - numel(partialBar));
            deleteLastIndicatorRow(this);
            indicatorRow = [ 
                this.LEFT_EDGE, fullBars, partialBar, emptyBars, this.RIGHT_EDGE ...
                sprintf(' %5.1f%%', permille/10)
            ];
            fprintf('%s', indicatorRow);
            this.LastIndicatorRow = indicatorRow;
            this.Diary(end+1, :) = {permille, indicatorRow};
            if permille==1000
                done(this);
            end
        end%


        function done(this)
            if ~this.Done
                this.Done = true;
                fprintf('\n');
                textual.looseLine( );
            end
        end%


        function increment(this)
            this.RunningCount = this.RunningCount + 1;
            if this.RunningCount>this.TotalCount
                this.RunningCount = this.TotalCount;
            end
            update(this, this.RunningCount/this.TotalCount);
        end%


        function deleteLastIndicatorRow(this)
            fprintf(repmat('\b', 1, numel(this.LastIndicatorRow)));
        end%


        function [numFullBars, partialBar, permille] = getNumBars(this, varargin)
            if numel(varargin)==1
                fraction = varargin{1};
            else
                position = varargin{1};
                index = varargin{2};
                fraction = nnz(index(1:position)) / nnz(index);
            end
            if ~isfinite(fraction)
                fraction = 1;
            end
            numPartialBarsAvailable = numel(this.PARTIAL_BAR);
            numFullBars = floor(this.NumProgress*fraction);
            partialBar = floor((this.NumProgress*fraction - numFullBars)*numPartialBarsAvailable);
            if partialBar==numPartialBarsAvailable
                numFullBars = numFullBars + 1;
                partialBar = 0;
            end
            permille = floor(fraction*1000);
        end%
    end
end
