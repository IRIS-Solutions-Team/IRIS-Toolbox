function C = latexdata(This,Row,Time,Data,Format,Mark,Text)
% latexdata  [Not a public function] LaTeX code for data part of a table row.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = '';
par = This.parent;
isDates = isempty(par.options.colstruct);
if isempty(Data)
    return
end
nPer = numel(Data);
ixHighlight = false(1,nPer);
for i = reshape(double(This.options.highlight), 1, [ ])
    ixHighlight = ixHighlight | dater.eq(Time, i);
end
c1 = cell(1,nPer);
[year,per,freq] = dat2ypf(Time);

for t = 1 : nPer
    hColor = '';
    if ixHighlight(t)
        hColor = 'highlightcolor';
    end    
    a = struct( );
    doAttributes( );
    c1{t} = testnformat(This,a,NaN,'',hColor);
end

for t = 1 : nPer
    if ~isempty(Format)
        if ~isempty(strfind(Format,'?'))
            c1{t} = strrep(Format,'?',c1{t});
        else
            c1{t} = [Format,' ',c1{t}];
        end
    end
    C = [C,' & ',c1{t}]; %#ok<AGROW>
end


% Nested functions...


%**************************************************************************

    
    function doAttributes( )
        % Prepare an attribute struct for cond formatting.
        a.value = Data(t);
        a.rowvalues = Data(:).';
        a.date = Time(t);
        a.mark = Mark;
        a.text = Text;
        a.row = Row;
        a.col = t;
        if ~isDates
            a.colname = par.options.colstruct(t).name{2};
        end
        a.year = year(t);
        a.period = per(t);
        a.freq = freq(t);
        a.ishighlight = ixHighlight(t);
    end % doAttributes( )


end
