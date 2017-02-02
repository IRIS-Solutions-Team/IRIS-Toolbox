% ProgressBar  Display command line progress bar.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef ProgressBar < handle    
    properties
        title = '';
        nProgress = 40;
        nBar = 0;
        display = '*';
    end
    
    
    
    
    methods
        function this = ProgressBar(varargin)
            if nargin>0
                this.title = varargin{1};
            end
            x = '-';
            screen = ['[', x(ones(1, this.nProgress)), ']'];
            if ~isempty(this.title)
                this.title = this.title(1:min(end, this.nProgress-4));
                screen(3+(1:length(this.title))) = this.title;
            end
            textfun.loosespace( );
            disp(screen);
            fprintf('[]');
        end
    
        
        
        
        function this = update(this, n)
            x = this.nBar;
            this.nBar = round(this.nProgress*n);
            if this.nBar>x
                c = this.display(1);
                fprintf('\b');
                fprintf(c(ones(1, this.nBar-x)));
                fprintf(']');
                if this.nBar>=this.nProgress
                    fprintf('\n');
                    textfun.loosespace( );
                end
            end
        end
    end
end
