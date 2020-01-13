classdef Interp
    properties (Constant)
        OPEN = char(10216)
        CLOSE = char(10217)
    end
    
    
    
    
    methods (Static)
        function varargout = parse(varargin)
            % Invoke unit tests
            %(
            if nargin==1 && isequal(varargin{1}, '--test')
                varargout{1} = unitTests( );
                return
            end
            %)

            import parser.Interp
            import parser.Preparser

            assigned = struct( );
            maxInterp = uint32(Inf);
            if nargin==1 && isa(varargin{1}, 'parser.Preparser')
                % parse(Preparser)
                p = varargin{1};
                code = p.Code;
                assigned = p.Assigned;
            else 
                % parse(code)
                % parse(code, assigned)
                % parse(code, assigned, maxInterp)
                code = char(varargin{1});
                if nargin>=2
                    assigned = varargin{2};
                end
                if nargin>=3
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
            codeAfter = '';
            while count<maxInterp
                posOpen = find(level==1, 1);
                if isempty(posOpen)
                    break
                end
                posClose = posOpen + find(level(posOpen+1:end)==0, 1);
                if isempty(posClose)
                    thisError = { 'Preparser:InterpolationStringNotClosed'
                                  'This interpolation string is not closed: %s ' };
                    throwCode( ...
                        exception.ParseTime(thisError, 'error'), ...
                        code(posOpen+1:end) ...
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
                before = posOpen - 1;
                after = posClose + 1;
                codeAfter = code(after:end);
                code = [code(1:before), s, code(after:end)];
                level = [level(1:before), zeros(1, length(s), 'int8'), level(after:end)];
                count = count + 1;
            end
            p.Code = code;
            

            if nargout>=1
                varargout = { code, value, codeAfter };
            end
        end%
        
        
        
        
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
        end%
        
        
        
        
        function value = any2cellstr(value)
            if isnumeric(value) || islogical(value) || ischar(value)
                value = num2cell(value);
            elseif isa(value, 'string')
                value = cellstr(value);
            elseif ~iscell(value)
                value = { value };
            end
            for i = 1 : numel(value)
                if ischar(value{i})
                    % Do nothing
                elseif isa(value{i}, 'string')
                    value{i} = char(value{i});
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
        end%




        function code = replaceRegularBrackets(code)
            code = strrep(code, '$[', parser.Interp.OPEN); 
            code = strrep(code, ']$', parser.Interp.CLOSE); 
        end%




        function code = replaceAngleBrackets(code)
            code = strrep(code, '<', parser.Interp.OPEN); 
            code = strrep(code, '>', parser.Interp.CLOSE); 
        end%
    end
end




%
% Unit Tests
%
%(
function tests = unitTests( )
    tests = functiontests({
        @setupOnce
        @parseTest
    });
    tests = reshape(tests, [ ], 1);
end%


function setupOnce(testCase)
end%


function parseTest(testCase)
    code = ' aaaa $[ A+1 ]$ ';
    code = parser.Interp.replaceRegularBrackets(code);
    assigned = struct('A', 1);
    act = parser.Interp.parse(code, assigned);
    exp = ' aaaa 2 ';
    assertEqual(testCase, act, exp);
end%
%)
