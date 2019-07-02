classdef texobj < report.userinputobj
    properties
    end
    
    
    
    
    methods
        function this = texobj(varargin)
            this = this@report.userinputobj(varargin{:});
            this.default = [this.default, { ...
                'separator', '\medskip\par', @ischar, true, ...
                }];
        end
        
        
        
        
        function [this, varargin] = specargin(this, varargin)
            % If the number of input arguments behind `Cap` is odd and the first input
            % argument after `Cap` is char, we grab it as input code/text; otherwise we
            % grab the comment block from caller.
            if mod(length(varargin), 2)==1 && ischar(varargin{1})
                this.userinput = varargin{1};
                varargin(1) = [ ];
            else
                caller = exception.Base.getStack( );
                if length(caller)>=4
                    caller = caller(4);
                    this.userinput = report.texobj.grabCommentBlk(caller);
                else
                    utils.warning('report:texobj', ...
                        'No block comment to grab for text or LaTeX input.');
                end
            end
        end
    end
    
    
    
    
    methods (Access=protected, Hidden)
        varargout = speclatexcode(varargin)
    end
    
    
    
    
    methods (Static)%, Access=protected, Hidden)
        varargout = grabCommentBlk(varargin)
    end
end
