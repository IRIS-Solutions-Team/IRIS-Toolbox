% reportobj  Top level report object
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team


classdef reportobj < report.genericobj
    properties
        CleanupOnDelete = true
    end


    methods
        function this = reportobj(varargin)
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            this = this@report.genericobj(varargin{:});
            this.default = [this.default, { ...
                'centering', true, islogicalscalar, false, ...
                'epstopdf', Inf, @(x) isequal(x, Inf) || ischar(x), false, ...
                'orientation', 'landscape', ...
                @(x) any(strcmpi(x, {'landscape', 'portrait'})), false, ...
                'typeface', '', @ischar, false, ...
                }];
            this.parent = [ ];
            this.hInfo = report.hinfoobj( );
        end%
        

        function [this, varargin] = setoptions(this, varargin)
            this = setoptions@report.genericobj(this, varargin{:});
            this.hInfo.orientation = this.options.orientation;
            this.hInfo.epstopdf = this.options.epstopdf;
        end%        
        

        function delete(this)
            if this.CleanupOnDelete
                cleanup(this);
            end
        end%
        

        varargout = cleanup(varargin)
        varargout = merge(varargin)
        varargout = publish(varargin)
    end

    
    
    
    methods (Access=protected, Hidden)
        varargout = add(varargin)
        varargout = speclatexcode(varargin)
    end
    
    
    
    
    methods
        % Level 1 objects
        %-----------------
        function [this, newObj] = section(this, varargin)
            newObj = report.sectionobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = table(this, varargin)
            newObj = report.tableobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = matrix(this, varargin)
            newObj = report.matrixobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = array(this, varargin)
            newObj = report.arrayobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = figure(this, varargin)
            newObj = report.figureobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = userfigure(this, varargin)
            newObj = report.userfigureobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = tex(this, varargin)
            newObj = report.texobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = texcommand(this, varargin)
            newObj = report.texcommandobj(varargin{1});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = text(this, varargin)
            [this, newObj] = tex(this, varargin{:});
        end
        
        function [this, newObj] = include(this, varargin)
            newObj = report.includeobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = modelfile(this, varargin)
            newObj = report.modelfileobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = pagebreak(this, varargin)
            newObj = report.pagebreakobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = clearpage(this, varargin)
            this = pagebreak(this, varargin{:});
        end
        
        function [this, newObj] = align(this, varargin)
            newObj = report.alignobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = empty(this, varargin)
            newObj = report.emptyobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        % Level 2 and 3 objects
        %-----------------------
        function [this, newObj] = graph(this, varargin)
            newObj = report.graphobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = series(this, varargin)
            newObj = report.seriesobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = band(this, varargin)
            newObj = report.bandobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = fanchart(this, varargin)
            newObj = report.fanchartobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = vline(this, varargin)
            newObj = report.vlineobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = highlight(this, varargin)
            newObj = report.highlightobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end
        
        function [this, newObj] = subheading(this, varargin)
            newObj = report.subheadingobj(varargin{:});
            this = add(this, newObj, varargin{2:end});
        end  
    end
    
    
    
    
    methods (Static)
        varargout = insertDocSubstitutions(varargin)
    end
end
