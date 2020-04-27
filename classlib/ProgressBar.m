% ProgressBar  Display command line progress bar
%
% Backend [IrisToolbox] class
% No help provided

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

classdef ProgressBar < handle    
    properties
        Title = ''
        TitleRow = ''
        NumProgress = 40
        LastIndicatorRow = ''
        LastNumFullBars = 0
        Done = false
    end




    properties (Constant)
        FULL_BAR = char(9608)
        PARTIAL_BAR = char(9615:-1:9608)
        EMPTY_BAR = ' '
        TITLE_FILL = '•'
        DIVIDER = '|'
    end
    
    
    
    
    methods
        function this = ProgressBar(varargin)
            if nargin>=1
                this.Title = varargin{1};
            end
            if nargin>=2
                this.NumProgress = varargin{2};
            end
            this.TitleRow = [this.TITLE_FILL , repmat(this.TITLE_FILL, 1, this.NumProgress), this.TITLE_FILL];
            if ~isempty(this.Title)
                this.Title = this.Title(1:min(end, this.NumProgress-4));
                this.TitleRow(3+(1:length(this.Title))) = this.Title;
            end
            textual.looseLine( );
            fprintf('%s', this.TitleRow);
            this.LastIndicatorRow = sprintf('%s%*s%s', this.DIVIDER, this.NumProgress, ' ', this.DIVIDER);
            fprintf('\n');
            fprintf('%s', this.LastIndicatorRow);
        end%
    
        
        
        
        function update(this, varargin)
            if this.Done
                return
            end
            [numFullBars, posPartialBar, fraction] = getNumBars(this, varargin{:});
            fullBars = repmat(this.FULL_BAR, 1, numFullBars);
            if posPartialBar>0
                partialBar = this.PARTIAL_BAR(posPartialBar);
            else
                partialBar = char.empty(1, 0);
            end
            emptyBars = repmat(this.EMPTY_BAR, 1, this.NumProgress - numel(fullBars) - numel(partialBar));
            deleteLastIndicatorRow(this);
            this.LastIndicatorRow = [ 
                this.DIVIDER, fullBars, partialBar, emptyBars, this.DIVIDER, ...
                sprintf(' %5.1f%%', 100*fraction)
            ];
            fprintf('%s', this.LastIndicatorRow);
            if numFullBars==this.NumProgress
                this.Done = true;
                fprintf('\n');
                textual.looseLine( );
            end
        end%




        function deleteLastIndicatorRow(this)
            fprintf(repmat('\b', 1, length(this.LastIndicatorRow)));
        end%


        

        function [numFullBars, partialBar, fraction] = getNumBars(this, varargin)
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
            numPartialBarsAvailable = length(this.PARTIAL_BAR);
            numFullBars = floor(this.NumProgress*fraction);
            partialBar = round((this.NumProgress*fraction - numFullBars)*numPartialBarsAvailable);
            if partialBar==numPartialBarsAvailable
                numFullBars = numFullBars + 1;
                partialBar = 0;
            end
        end%
    end
end
