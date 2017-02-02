classdef Pseudosubs
    properties (Constant)
        PSEUDOSUBS_OPEN = {'$[', '<'}
        PSEUDOSUBS_CLOSE = {']$', '>'}
    end
    
    
    
    
    methods (Static)
        function code = parse(varargin)
            import parser.Pseudosubs;
            import parser.Preparser;
            if nargin==1
                % (Preparser):
                p = varargin{1};
                code = p.Code;
                assigned = p.Assigned;
            else % (code, assigned):
                code = varargin{1};
                assigned = varargin{2};
            end
            strOpen = Pseudosubs.PSEUDOSUBS_OPEN;
            strClose = Pseudosubs.PSEUDOSUBS_CLOSE;
            for i = 1 : numel(strOpen)
                sh = Pseudosubs.createShadowCode(code, strOpen{i}, strClose{i});
                level = cumsum(sh);
                if any(level>1)
                    posNested = find(level>1, 1);
                    throwCode( exception.ParseTime('Preparser:PSEUDOSUBS_NESTED', 'error'), ...
                        code(posNested:end) );
                end
                lenOpen = length(strOpen{i});
                lenClose = length(strClose{i});
                while true
                    posOpen = find(level==1, 1);
                    if isempty(posOpen)
                        break
                    end
                    posClose = posOpen + find(level(posOpen+1:end)==0, 1);
                    if isempty(posClose)
                        throwCode( exception.ParseTime('Preparser:PSEUDOSUBS_NOT_CLOSED', 'error'), ...
                            code(posOpen:end) );
                    end
                    expn = code(posOpen+lenOpen:posClose-1);
                    try
                        value = Preparser.eval(expn, assigned);
                        s = Pseudosubs.printValue(value);
                    catch
                        throwCode( exception.ParseTime('Preparser:PSEUDOSUBS_EVAL_FAILED', 'error'), ...
                            code(posOpen:posClose+lenClose-1) );
                    end
                    code = [ ...
                        code(1:posOpen-1), ...
                        s, ...
                        code(posClose+lenClose:end), ...
                        ];
                    level = [ ...
                        level(1:posOpen-1), ...
                        zeros(1, length(s), 'int8'), ...
                        level(posClose+lenClose:end), ...
                        ];
                end
            end
            p.Code = code;
        end
        
        
        
        
        function sh = createShadowCode(c, strOpen, strClose)
            import parser.Pseudosubs;
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
        
        
        
        
        function c = printValue(value)
            if isnumeric(value) || islogical(value) || ischar(value)
                value = num2cell(value);
            elseif ~iscell(value)
                value = { value };
            end
            c = '';
            for i = 1 : numel(value)
                if ischar(value{i})
                    c = [c, value{i}, ',']; %#ok<AGROW>
                elseif isnumeric(value{i})
                    c = [c, sprintf('%g,', value{i})]; %#ok<AGROW>
                elseif isequal(value{i},true)
                    c = [c, 'true,']; %#ok<AGROW>
                elseif isequal(value{i},false)
                    c = [c, 'false,']; %#ok<AGROW>
                else
                    c = char(value{i});
                    c = c(:).';
                end
            end
            c = c(1:end-1);
        end
    end
end
