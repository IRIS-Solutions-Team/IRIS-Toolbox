classdef basefigureobj < report.tabularobj
    
    
    properties
        handle = [ ];
    end
        
    
    methods
        function This = basefigureobj(varargin)
            if true % ##### MOSW
                IsVisibleDefault = false;
            else
                IsVisibleDefault = true; %#ok<UNRCH>
            end
            validFn = iris.options.validfn;
            This = This@report.tabularobj(varargin{:});
            This.childof = {'report','align'};
            This.default = [This.default,{ ...
                'aspectratio',@auto, ...
                @(x) isequal(x,@auto) || (isnumeric(x) && length(x) == 2 && all(x > 0)), ...
                true,...
                'close',true,@islogicalscalar,true, ...
                'figureopt,figureoptions',{ },validFn.figureopt,true, ...
                'figurescale','auto', ...
                @(x) isnumericscalar(x) || strcmpi(x,'auto'), ...
                true, ...
                'figuretrim',[40,20,40,20], ...
                @(x) isnumeric(x) && (length(x) == 1 || length(x) == 4) && all(x >= 0), ...
                true, ...
                'papertype','usletter', ...
                @(x) any(strcmpi(x,{'usletter','uslegal','A4'})), ...
                true, ...
                'subplot',@auto,validFn.subplot,true, ...
                'separator','\medskip\par',@ischar,true, ...
                'style',[ ],@(x) isempty(x) || isstruct(x),true, ...
                'typeface','',@ischar,false, ...                
                'visible',IsVisibleDefault,@islogical,true, ...
                }];
        end
        
        
        % Process class-specific input arguments.
        function [This,varargin] = specargin(This,varargin)
        end
        
        
        function This = setoptions(This,varargin)
            This = setoptions@report.tabularobj(This,varargin{:});
            This.options.long = false;
            if true % ##### MOSW
                % Do nothing.
            else
                % Figure windows must be visible for printing in Octave.
                This.options.visible = true; %#ok<UNRCH>
            end
        end
    end

    
    methods (Access=protected,Hidden)
        varargout = mycompilepdf(varargin)
        varargout = myplot(varargin)
        varargout = speclatexcode(varargin)
    end
    
    
end
