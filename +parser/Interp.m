classdef Interp
    properties (Constant)
        OPEN = '<'
        CLOSE = '>'
    end
    
    
    
    
    methods (Static)
        function [code, value, postCode] = parse(varargin)
            import parser.Interp
            import parser.Preparser
            maxInterp = uint32(Inf);
            if nargin==1
                % (Preparser):
                p = varargin{1};
                code = p.Code;
                assigned = p.Assigned;
            else 
                % (code, assigned):
                code = varargin{1};
                assigned = varargin{2};
                if nargin==3
                    % (code, assigned, maxInterp)
                    maxInterp = uint32(varargin{3});
                end
            end

            sh = Interp.createShadowCode(code, Interp.OPEN, Interp.CLOSE);
            level = cumsum(sh);
            if any(level>1)
                posNested = find(level>1, 1);
                throwCode( ...
                    exception.ParseTime('Preparser:INTERP_NESTED', 'error'), ...
                    code(posNested:end) ...
                    );
            end
            count = uint32(0);
            value = [ ];
            while count<maxInterp
                posOpen = find(level==1, 1);
                if isempty(posOpen)
                    break
                end
                posClose = posOpen + find(level(posOpen+1:end)==0, 1);
                if isempty(posClose)
                    throwCode( ...
                        exception.ParseTime('Preparser:INTERP_NOT_CLOSED', 'error'), ...
                        code(posOpen:end) ...
                        );
                end
                expn = code(posOpen+1:posClose-1);
                try
                    value = Preparser.eval(expn, assigned);
                    value = Interp.any2cellstr(value);
                    s = '';
                    if ~isempty(value)
                        s = sprintf('%s,', value{:});
                        s = s(1:end-1);
                    end
                catch
                    throwCode( ...
                        exception.ParseTime('Preparser:InterpEvalFailed', 'error'), ...
                        code(posOpen:posClose) ...
                        );
                end
                if nargout>2
                    postCode = code(posClose+1:end);
                end
                code = [ ...
                    code(1:posOpen-1), ...
                    s, ...
                    code(posClose+1:end), ...
                    ];
                level = [ ...
                    level(1:posOpen-1), ...
                    zeros(1, length(s), 'int8'), ...
                    level(posClose+1:end), ...
                    ];
                count = count + 1;
            end
            p.Code = code;
        end
        
        
        
        
        function sh = createShadowCode(c, strOpen, strClose)
            import parser.Interp;
            sh = zeros(1, length(c), 'int8');
            posOpen = strfind(c, strOpen);
            if ~isempty(posOpen)
                sh(posOpen) = 1;
            end
            posClose = strfind(c, strClose);
            if ~isempty(posClose)
                sh(posClose) = -1;
            end
        end
        
        
        
        
        function value = any2cellstr(value)
            if isnumeric(value) || islogical(value) || ischar(value)
                value = num2cell(value);
            elseif ~iscell(value)
                value = { value };
            end
            for i = 1 : numel(value)
                if ischar(value{i})
                    % Do nothing.
                elseif isnumeric(value{i})
                    value{i} = sprintf('%g', value{i});
                elseif isequal(value{i}, true)
                    value{i} = 'true';
                elseif isequal(value{i}, false)
                    value{i} = 'false';
                else
                    error('IRIS:Intermediate', 'Intermediate Error');
                    return
                end
            end
        end
    end
end
