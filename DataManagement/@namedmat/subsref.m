function output = subsref(this, varargin)

s = varargin{1};
if strcmp(s(1).type, ".")
    output = builtin("subsref", this, s);
    return
end


% Linear indexing by numeric or logical vector/array - convert to double
if numel(s)==1 && isequal(s(1).type, '()') && numel(s(1).subs)==1 ...
        && (isnumeric(s(1).subs{1}) || islogical(s(1).subs{1}))
    output = double(this);
    output = builtin("subsref", output, s);
    return
end


isPreserved = strcmp(s(1).type, '()');

if strcmp(s(1).type, '()')
    % Convert row names to positions
    if (isstring(s(1).subs{1}) || ischar(s(1).subs{1}) || iscellstr(s(1).subs{1})) ...
            && ~isequal(s(1).subs{1}, ':')
        s(1).subs{1} = locallyPositionsFromNames(s(1).subs{1}, this, "Row");
    end

    % Convert column names to positions
    if numel(s(1).subs)>=2 ...
            && (isstring(s(1).subs{2}) || ischar(s(1).subs{2}) || iscellstr(s(1).subs{2})) ...
            && ~isequal(s(1).subs{2}, ':')
        s(1).subs{2} = locallyPositionsFromNames(s(1).subs{2}, this, "Column");
    end

    % If the user refers to only row and column names but the matrix has
    % more dimensions, add ":" to subs references to preserve the shape of
    % the resulting matrix
    if numel(s(1).subs)<=2 && numel(s(1).subs)<ndims(this)
        s(1).subs(end+1:ndims(this)) = {':'};
    end
end

if isPreserved
    rowNames = this.RowNames;
    colNames = this.ColumnNames;
    s1 = s(1);
    s1.subs = s1.subs(1);
    rowNames = subsref(rowNames, s1);
    s2 = s(1);
    s2.subs = s2.subs(2);
    colNames = subsref(colNames, s2);
end

output = double(this);
output = subsref(output, s, varargin{2:end});

if isPreserved
    output = namedmat(output, rowNames, colNames);
end

end%

%
% Local Functions
%

function subs = locallyPositionsFromNames(subs, this, dimensionName)
    inputNames = subs;
    inputNames = reshape(string(inputNames), 1, [ ]);
    numInputNames = numel(inputNames);
    subs = textual.locate(inputNames, this.(dimensionName+"Names"));
    inxNa = isnan(subs);
    if any(inxNa)
        exception.error([
            "NamedMatrix:InvalidRowReference"
            "This is not a valid reference to %1 in NamedMatrix object: %s"
        ], dimensionName+"Names", inputNames(inxNa));
    end
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=NamedMatrix/subsrefTest.m

this = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once
dataX = rand(3, 5);
x = namedmat(dataX, ["a", "b", "c"], compose("Col%g", 1:5));
dataY = rand(3, 5, 4, 8);
y = namedmat(dataY, ["aa", "bb", "cc"], compose("CCol%g", 1:5));

%% Test Two Dimensions

assertSize(this, x("a"), [1, 5]);
assertSize(this, x("a", :), [1, 5]);
assertSize(this, x("a", ["Col1", "Col3"]), [1, 2]);

%% Test Higher Dimensions

assertSize(this, y("aa"), [1, 5, 4, 8]);
assertSize(this, y("aa", :), [1, 5, 4, 8]);
assertSize(this, y("aa", ["CCol1", "CCol3"]), [1, 2, 4, 8]);

%% Test Dot Reference

assertEqual(this, x.RowNames, ["a", "b", "c"]);
assertEqual(this, x.ColumnNames, compose("Col%g", 1:5));

##### SOURCE END #####
%}

