classdef emptyobj < report.genericobj

    methods

      function This = emptyobj(varargin)
         This = This@report.genericobj(varargin{:});
         This.childof = {'report','align','figure'};
         This.default = [This.default,{ }];
      end
      
      function [This,varargin] = specargin(This,varargin)
      end
      
      function This = setoptions(This,varargin)
          This = setoptions@report.genericobj(This,varargin{:});
          This.options.typeface = '';
      end
            
      % The methods `plot` and `subplot` are called from within figure. Do
      % nothing, and let the subplot position counter move to the next one.
      function plot(This,varargin) %#ok<INUSD>
      end
      
      function Ax = subplot(This,varargin) %#ok<INUSD>
         Ax = [ ];
      end
      
   end
   
   methods (Access=protected,Hidden)
       
        varargout = speclatexcode(varargin)
        
   end
   
end