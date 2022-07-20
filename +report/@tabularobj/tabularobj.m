classdef tabularobj < report.genericobj
    
    properties
        ncol = NaN;
        nlead = NaN;
        nrow = NaN;
        vline = [ ];
        highlight = [ ];
    end
    
    events
        longTable
    end
    
    methods
        
        
        function This = tabularobj(varargin)
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            This = This@report.genericobj(varargin{:});
            This.default = [This.default, { ...
                'arraystretch',1.15,@(x) isnumericscalar(x) && x > 0,true, ...
                'colspec','',@ischar,true, ...                
                'colwidth',NaN,@isnumeric,true, ...
                'long',false,islogicalscalar,true, ...
                'longfoot','',@ischar,true, ...
                'longfootposition','l', ...
                    @(x) ischar(x) && any(strncmpi(x,{'l','c','r'},1)),true, ...
                'sideways',false,islogicalscalar,true, ...
                'tabcolsep',NaN,@(x) isnumericscalar(x) && (isnan(x) || x >= 0), true, ...
            }];
        end
        
        
        function [This,varargin] = setoptions(This,varargin)
            This = setoptions@report.genericobj(This,varargin{:});
            if This.options.long
                This.hInfo.package.longtable = true;
            end
        end
        
        
        function C = begin(This)
            br = sprintf('\n');
            C = '';
            C = [C,beginsideways(This)];
            if ~This.options.long
                space = 7;
            else
                space = 0;
            end
            % Set arraystretch and tabcolsep.
            params = [ ...
                br,'\renewcommand{\arraystretch}{', ...
                sprintf('%g',This.options.arraystretch),'}', ...
                ];
            if ~isnan(This.options.tabcolsep)
                params = [params, ...
                br,'\settowidth\tabcolsep{m}', ...
                '\setlength\tabcolsep{', ...
                sprintf('%g',This.options.tabcolsep), ...
                '\tabcolsep}'];
            end
            % Wrap the content using another tabular to keep the
            % title and subtitle on the same page.
            C = [C,beginwrapper(This,space)];
            if ~This.options.long
                C = [C,'{',params,br,'\begin{tabular}'];
            else
                C = [C,finishwrapper(This)];
                C = [C,'\vspace*{-3pt}'];
                C = [C,'{',params,br,'\begin{longtable}'];
            end
            if This.options.colspec(1) ~= '{'
                This.options.colspec = ['{',This.options.colspec];
            end
            if This.options.colspec(end) ~= '}'
                This.options.colspec = [This.options.colspec,'}'];
            end
            C = [C,This.options.colspec];
            if This.options.long && ~isempty(This.options.longfoot)
                C = [C,br, ...
                    '\\[-10pt] \multicolumn', ...
                    '{',sprintf('%g',This.nlead+This.ncol),'}', ...
                    '{',This.options.longfootposition(1),'}', ...
                    '{',interpret(This,This.options.longfoot),'}', ...
                    br,'\endfoot\endlastfoot'];
            end
        end
        
        
        function C = finish(This)
            br = sprintf('\n');
            C = '\hline';
            if ~This.options.long
                C = [C,br,'\end{tabular}}'];
                C = [C,finishwrapper(This)];
            else
                C = [C,br,'\end{longtable}}'];
            end
            C = [C,finishsideways(This)];
        end
        
        
        function C = beginwrapper(This,Space)
            br = sprintf('\n');
            C = ['\begin{tabular}[t]{@{\hspace*{-3pt}}c@{ }}',br];
            C = [C,printcaption(This,1,'c',Space),br];
        end
        
        
        function C = finishwrapper(This) %#ok<MANU>
            br = sprintf('\n');
            C = [br,'\end{tabular}'];
        end
        
        
        function C = beginsideways(This)
            C = '';
            if This.options.sideways
                This.hInfo.package.rotating = true;
                br = sprintf('\n');
                C = [C,br,'\begin{sideways}'];
            end
        end
        
        
        function C = finishsideways(This)
            C = '';
            if This.options.sideways
                br = sprintf('\n');
                C = [C,br,'\end{sideways}'];
            end
        end
        
        
        function C = colspec(This)
            % Create column specs for tabular environment with all lead
            % columns aligned left, all data columns aligned right and
            % vertical lines inserted at This.vline positions.
            C = char('l'*ones(1,This.nlead));
            if This.ncol == 0
                return
            end
            % Pre-sample vertical line.
            if any(This.vline == 0)
                C = [C,'|'];
            end
            
            c1 = char('r'*ones(1,This.ncol));
            c1(This.highlight) = upper(c1(This.highlight));
            
            c2 = char(' '*ones(1,This.ncol));
            This.vline(This.vline < 1 | This.vline > This.ncol) = [ ];
            c2(This.vline) = '|';

            c3 = [c1;c2];
            c3 = transpose(c3(:));
            C = [C,c3];
            C(C == char(32)) = '';
        end
        
        
    end
    
end
