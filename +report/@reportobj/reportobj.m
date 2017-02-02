classdef reportobj < report.genericobj
    % reportobj  [Not a public class] Top level report object.
    %
    % Backed IRIS class.
    % No help provided.
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2017 IRIS Solutions Team.
    
    
    methods
        % Constructor
        %-------------
        function This = reportobj(varargin)
            This = This@report.genericobj(varargin{:});
            This.default = [This.default,{ ...
                'centering',true,@islogicalscalar,false, ...
                'epstopdf',Inf,@(x) isequal(x,Inf) || ischar(x),false, ...
                'orientation','landscape', ...
                @(x) any(strcmpi(x,{'landscape','portrait'})),false, ...
                'typeface','',@ischar,false, ...
                }];
            This.parent = [ ];
            This.hInfo = report.hinfoobj( );
        end
        
        function [This,varargin] = setoptions(This,varargin)
            This = setoptions@report.genericobj(This,varargin{:});
            This.hInfo.orientation = This.options.orientation;
            This.hInfo.epstopdf = This.options.epstopdf;
        end        
        
        % Destructor
        %------------
        function delete(This)
            cleanup(This);
        end
        
        varargout = cleanup(varargin)
        varargout = merge(varargin)
        varargout = publish(varargin)
    end

    
    
    
    methods (Access=protected,Hidden)
        varargout = add(varargin)
        varargout = speclatexcode(varargin)
    end
    
    
    
    
    methods
        % Level 1 objects
        %-----------------
        function [This,NewObj] = section(This,varargin)
            NewObj = report.sectionobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = table(This,varargin)
            NewObj = report.tableobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = matrix(This,varargin)
            NewObj = report.matrixobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = array(This,varargin)
            NewObj = report.arrayobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = figure(This,varargin)
            NewObj = report.figureobj(varargin{:});
            This = add(This, NewObj, varargin{2:end});
        end
        
        function [This,NewObj] = userfigure(This,varargin)
            NewObj = report.userfigureobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = tex(This,varargin)
            NewObj = report.texobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = texcommand(This,varargin)
            NewObj = report.texcommandobj(varargin{1});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = text(This,varargin)
            [This,NewObj] = tex(This,varargin{:});
        end
        
        function [This,NewObj] = include(This,varargin)
            NewObj = report.includeobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = modelfile(This,varargin)
            NewObj = report.modelfileobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = pagebreak(This,varargin)
            NewObj = report.pagebreakobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = clearpage(This,varargin)
            This = pagebreak(This,varargin{:});
        end
        
        function [This,NewObj] = align(This,varargin)
            NewObj = report.alignobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = empty(This,varargin)
            NewObj = report.emptyobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        % Level 2 and 3 objects
        %-----------------------
        function [This,NewObj] = graph(This,varargin)
            NewObj = report.graphobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = series(This,varargin)
            NewObj = report.seriesobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = band(This,varargin)
            NewObj = report.bandobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = fanchart(This,varargin)
            NewObj = report.fanchartobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = vline(This,varargin)
            NewObj = report.vlineobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = highlight(This,varargin)
            NewObj = report.highlightobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end
        
        function [This,NewObj] = subheading(This,varargin)
            NewObj = report.subheadingobj(varargin{:});
            This = add(This,NewObj,varargin{2:end});
        end  
    end
    
    
    
    
    methods (Static)
        varargout = insertDocSubstitutions(varargin)
    end
end