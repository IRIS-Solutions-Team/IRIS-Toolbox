classdef userfigureobj < report.basefigureobj
    
    
    properties
        savefig = [ ];
    end
    
    
    methods    
        function This = userfigureobj(varargin)
            This = This@report.basefigureobj(varargin{:});
        end
        
        
        % Process class-specific input arguments.
        function [This,varargin] = specargin(This,varargin)
            % Create a saved hardcopy of the figure, and store it in binary form.
            h = varargin{1};
            varargin(1) = [ ];
            if ~isempty(h)
                if length(h) ~= 1 || ~ishghandle(h) ...
                        || ~strcmp(get(h,'type'),'figure')
                    utils.error('report', ...
                        ['The input argument H into a report figure must be ' ...
                        'a valid handle to a figure window.']);
                end
                figFile = [tempname(pwd( )),'.fig'];
                if true % ##### MOSW
                    % Matlab only
                    %-------------
                    % Do nothing.
                else
                    % Octave only
                    %-------------
                    a = findobj(h,'type','axes'); %#ok<UNRCH>
                    if ~isempty(a)
                        xLimMode = get(a,'xLimMode');
                        yLimMode = get(a,'yLimMode');
                        zLimMode = get(a,'zLimMode');
                        setappdata(h,'xLimMode',xLimMode);
                        setappdata(h,'yLimMode',yLimMode);
                        setappdata(h,'zLimMode',zLimMode);
                        set(a, ...
                            'xLimMode','manual', ...
                            'yLimMode','manual', ...
                            'zLimMode','manual');
                    end
                end
                hgsave(h,figFile);
                fid = fopen(figFile);
                This.savefig = fread(fid);
                fclose(fid);
                delete(figFile);
            end
        end
        
        
        function This = setoptions(This,varargin)
            This = setoptions@report.basefigureobj(This,varargin{:});
        end
        
        
    end
    
    
    methods (Access=protected,Hidden)    
        varargout = myplot(varargin)
    end
    
    
end
