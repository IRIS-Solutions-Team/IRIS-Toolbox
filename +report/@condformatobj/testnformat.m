function C = testnformat(This,A,ColW,Just,HColor)
% testnformat  [Not a public function] Test and format one table entry.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = '';
C1 = '?';
sprintFormat = This.options.format;

if isempty(This.format)
    doPrintValue( );
    return
end

args = { };
doInputArgs( );
nTest = length(This.format);
passed = false(1,nTest);

for i = 1 : nTest
    try %#ok<TRYNC>
        passed(i) = This.test{i}(args{:});
    end
end

for i = find(passed)
    % `This` is a handle object, and we therefore mustn't modify its
    % properties. Create a temp variable for the current format.
    thisFormat = This.format{i};
    % Find, read and remove sprintf formats, `\sprintf{XXX}`.
    doSprintf( );
    if isempty(thisFormat)
        continue
    end
    % Format may or may not have a reference to the
    % current string, ?. If the reference is not there,
    % put the current format before the current string.
    if ~isempty(strfind(thisFormat,'?'))
        C1 = strrep(thisFormat,'?',C1);
    else
        C1 = [thisFormat,' ',C1]; %#ok<AGROW>
    end
    C1 = ['\ensuremath{',C1,'}']; %#ok<AGROW>
end

% Print the value in a box.
doPrintValue( );

if ~all(strcmpi(C1,'?'))
    C = strrep(C1,'?',C);
end


% Nested functions...


%**************************************************************************


        function doInputArgs( )
            n = length(This.attribute);
            args = cell(1,n);
            for ii = 1 : n
                if isfield(A,This.attribute{ii})
                    args{ii} = A.(This.attribute{ii});
                else
                    args{ii} = NaN;
                end
            end
        end % doInputArgs( )
    
    
%**************************************************************************


    function doSprintf( )
        [tok,start,finish] = regexp(thisFormat, ...
            '\\sprintf\{(.*?)\}','tokens','start','end','once');
        if ~isempty(start)
            sprintFormat = tok{1};
            thisFormat(start:finish) = '';
            thisFormat = strtrim(thisFormat);
        end
    end % doSprintf( )


%**************************************************************************


    function doPrintValue( )
        C = report.seriesobj.sprintf(A.value,sprintFormat,This.options);
        C = report.seriesobj.makebox(C, ...
            '',ColW,Just,HColor);
    end % doPrintValue( )


end
