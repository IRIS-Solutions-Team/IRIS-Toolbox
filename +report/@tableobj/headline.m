function c = headline(this)
% headline  Latex code for table headline.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

isDates = isempty(this.options.colstruct);
if isDates
    range = double(this.options.range);
else
    numColumns = numel(this.options.colstruct);
    range = 1 : numColumns;
end

dateFormat = this.options.dateformat;
nLead = this.nlead;

if isDates
    yearFmt = dateFormat{1};
    currentFmt = dateFormat{2};
    isTwoLines = isDates && ~isequaln(yearFmt, NaN);
else
    isTwoLines = false;
    for i = 1 : numColumns
        isTwoLines = ~isequaln(this.options.colstruct(i).name{1}, NaN);
        if isTwoLines
            break
        end
    end
end

lead = '&';
lead = lead(ones(1,nLead-1));
if isempty(range)
    if isnan(yearFmt)
        c = lead;
    else
        c = [lead, newline( ) ,'\\',lead];
    end
    return
end

range = reshape(range, 1, [ ]);
numPeriods = numel(range);
if isDates
    currentDates = dat2str( range, ...
                            'dateFormat',currentFmt, ...
                            'months',this.options.months, ...
                            'standinMonth',this.options.standinmonth );
    if ~isnan(yearFmt)
        yearDates = dat2str( range, ...
                             'dateFormat',yearFmt, ...
                             'months',this.options.months, ...
                             'standinMonth',this.options.standinmonth );
        yearDates = interpret(this,yearDates);
    end
    currentDates = interpret(this,currentDates);
    [year,per,freq] = dat2ypf(range); %#ok<ASGLU>
end

firstLine = lead; % First line.
secondLine = lead; % Main line.
divider = lead; % Dividers between first and second lines.
yCount = 0;

colFootDate = [ this.options.colfootnote{1:2:end} ];
colFootText = this.options.colfootnote(2:2:end);

for i = 1 : numPeriods
    isLastCol = i == numPeriods;
    yCount = yCount + 1;
    colW = this.options.colwidth(min(i,end));
    f = '';
    if isDates
        s = currentDates{i};
        if isTwoLines
            f = yearDates{i};
            isFirstLineChg = isLastCol ...
                || (year(i) ~= year(i+1) || freq(i) ~= freq(i+1));
        end
    else
        s = this.options.colstruct(i).name{2};
        if isTwoLines
            f = this.options.colstruct(i).name{1};
            isFirstLineChg = isLastCol ...
                || ~isequaln(this.options.colstruct(i).name{1}, ...
                this.options.colstruct(i+1).name{1});
            if isequaln(f, NaN)
                f = '';
            end
        end
    end
    
    % Footnotes in the headings of individual columns
    inx = dater.eq(colFootDate, range(i));
    for j = find(inx)
        if ~isempty(colFootText{j})
            s = [s, ...
                footnotemark(this,colFootText{j})]; %#ok<AGROW>
        end
    end

    col = this.options.headlinejust;
    if any(this.highlight == i)
        col = upper(col);
    end
    if i == 1 && any(this.vline == 0)
        col = ['|',col]; %#ok<AGROW>
    end
    if any(this.vline == i)
        col = [col,'|']; %#ok<AGROW>
    end    

    % Second=Main line.
    s = ['&\multicolumn{1}{',col,'}{', ...
        report.tableobj.makebox(s,'',colW,this.options.headlinejust,''), ...
        '}'];
    secondLine = [secondLine,s]; %#ok<AGROW>
    
    % Print the first line text across this and all previous columns that have
    % the same date/text on the first line.
    % hRule = [hRule,'&\multicolumn{1}{c|}{ }'];
    if isTwoLines && isFirstLineChg
        command = [ ...
            '&\multicolumn{', ...
            sprintf('%g',yCount), ...
            '}{c}'];
        firstLine = [firstLine,command, ...
            '{',report.tableobj.makebox(f,'',NaN,'',''),'}']; %#ok<AGROW>
        divider = [divider,command]; %#ok<AGROW>
        if ~isempty(f)
            divider = [divider,'{\hrulefill}']; %#ok<AGROW>
        else
            divider = [divider,'{}']; %#ok<AGROW>
        end
        yCount = 0;
    end
end

if isTwoLines
    c = [firstLine, '\\[-8pt]',  newline( ), divider, '\\', newline( ), secondLine];
else
    c = secondLine;
end

if iscellstr(c)
    c = [c{:}];
end

end
