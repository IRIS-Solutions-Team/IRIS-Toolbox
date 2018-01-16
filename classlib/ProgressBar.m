% ProgressBar  Display command line progress bar.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

classdef ProgressBar < handle    
    properties
        Title = '';
        NumProgress = 40;
        NumBars = 0;
        Display = '*';
    end
    
    
    
    
    methods
        function this = ProgressBar(varargin)
            if nargin>0
                this.Title = varargin{1};
            end
            x = '-';
            screen = ['[', x(ones(1, this.NumProgress)), ']'];
            if ~isempty(this.Title)
                this.Title = this.Title(1:min(end, this.NumProgress-4));
                screen(3+(1:length(this.Title))) = this.Title;
            end
            textfun.loosespace( );
            disp(screen);
            fprintf('[]');
        end
    
        
        
        
        function this = update(this, varargin)
            oldNumBars = this.NumBars;
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
            this.NumBars = round(this.NumProgress*fraction);
            if this.NumBars>oldNumBars
                c = this.Display(1);
                fprintf('\b');
                fprintf(c(ones(1, this.NumBars-oldNumBars)));
                fprintf(']');
                if this.NumBars>=this.NumProgress
                    fprintf('\n');
                    textual.looseLine( );
                end
            end
        end
    end
end
