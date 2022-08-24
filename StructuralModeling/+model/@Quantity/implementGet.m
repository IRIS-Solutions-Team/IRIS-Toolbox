function [answ, isValid, query] = implementGet(this, query, varargin)

answ = [ ];
isValid = true;
compare = @(x, y) any(strcmpi(x, y));

query1 = lower(query);
query1 = replace(query1, "list", "names");
query1 = replace(query1, "descriptions", "descript");
query1 = replace(query1, "description", "descript");
query1 = replace(query1, "aliases", "alias");

if startsWith(query1, ["Quantity.", "Quantity:"], "ignoreCase", true)
    property = extractAfter(query1, 9);;
    try
        answ = this.(property);
        return
    end
end

if compare(query1, {'Names', 'AllNames'})
    answ = this.Name;
    return

elseif compare(query1, { ...
            'ynames', 'xnames', 'enames', 'vnames', 'wnames', 'pnames', 'gnames', ...
            'ydescript', 'xdescript', 'edescript', 'vdescript', 'wdescript', 'pdescript', 'gdescript', ...
            'yalias', 'xalias', 'ealias', 'valias', 'walias', 'palias', 'galias' ...
        })
    ixType = getType(extractBetween(query1, 1, 1));
    prop = getProperty(extractAfter(query1, 1));
    answ = this.(prop)(ixType);
    return

elseif compare(query1, {'Descript', 'Desc', 'Description', 'Descriptions'})
    answ = cell2struct(this.Label, cellstr(this.Name), 2);
    return

elseif compare(query1, 'Alias')
    answ = cell2struct(this.Alias, cellstr(this.Name), 2);
    return

elseif compare(query1, 'CanBeExogenized:Simulate')
    answ = this.Type==1 | this.Type==2;
    return

elseif compare(query1, 'CanBeEndogenized:Simulate')
    answ = this.Type==31 | this.Type==32;
    return

elseif compare(query1, 'LogStatus')
    answ = cell2struct(num2cell(this.InxLog), cellstr(this.Name), 2);
    return

else
    isValid = false;

end

return


    function ixType = getType(query)
        if strcmpi(query, 'y')
            ixType = this.Type==1;
        elseif strcmpi(query, 'x')
            ixType = this.Type==2;
        elseif strcmpi(query, 'e')
            ixType = this.Type==31 | this.Type==32;
        elseif strcmpi(query, 'w')
            ixType = this.Type==(31);
        elseif strcmpi(query, 'v')
            ixType = this.Type==(32);
        elseif strcmpi(query, 'p')
            ixType = this.Type==4;
        elseif strcmpi(query, 'g')
            ixType = this.Type==5;
        end
    end%


    function prop = getProperty(query)
        if compare(query, ["List", "Name", "Names"])
            prop = "Name";
        elseif compare(query, ["Descript", "Description", "Descriptions"])
            prop = "Label";
        elseif compare(query, ["Alias", "Aliases"])
            prop = "Alias";
        end
    end%
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Quantity/implementGetUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once

q = model.Quantity;
q.Name =      {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'};
q.Type = int8([ 1 ,  1 ,  2 ,  2 ,  31,  31,  32,  32,  4 ,  4 ,  5 ,  5 ]);
q.Label = strcat(upper(q.Name), upper(q.Name));
q.Alias = strcat(q.Name, q.Name);
testCase.TestData.Quantity = q;
testCase.TestData.Map = struct( ...
    'Y', 1, 'X', 2, 'W', 31, 'V', 32, 'P', 4, 'G', 5 ...
);


%% Test Get Names

q = testCase.TestData.Quantity;
map = testCase.TestData.Map;

for prefix = keys(map)
    [output, isValid, query] = implementGet(q, prefix+"Names");
    inx = q.Type==map.(prefix);
    assertEqual(testCase, output, q.Name(inx));
    assertEqual(testCase, isValid, true);
    assertEqual(testCase, query, prefix+"Names");
end


%% Test Get Labels

q = testCase.TestData.Quantity;
map = testCase.TestData.Map;

for prefix = keys(map)
    [output, isValid, query] = implementGet(q, prefix+"Descript");
    inx = q.Type==map.(prefix);
    expected = strcat(upper(q.Name(inx)), upper(q.Name(inx)));
    assertEqual(testCase, output, expected);
    assertEqual(testCase, isValid, true);
    assertEqual(testCase, query, prefix+"Descript");
end


%% Test Get Alias

q = testCase.TestData.Quantity;
map = testCase.TestData.Map;

for prefix = keys(map)
    [output, isValid, query] = implementGet(q, prefix+"Alias");
    inx = q.Type==map.(prefix);
    expected = strcat(q.Name(inx), q.Name(inx));
    assertEqual(testCase, output, expected);
    assertEqual(testCase, isValid, true);
    assertEqual(testCase, query, prefix+"Alias");
end


%% Test Get Empty Names

q = testCase.TestData.Quantity;
map = testCase.TestData.Map;

for prefix = keys(map)
    inx = q.Type==map.(prefix);
    q.Name(inx) = [ ];
    q.Type(inx) = [ ];
    q.Label(inx) = [ ];
    [output, isValid, query] = implementGet(q, prefix+"Names");
    assertEqual(testCase, output, cell.empty(1, 0));
    assertEqual(testCase, isValid, true);
    assertEqual(testCase, query, prefix+"Names");
end


%% Test Get Empty Labels

q = testCase.TestData.Quantity;
map = testCase.TestData.Map;

for prefix = keys(map)
    inx = q.Type==map.(prefix);
    q.Name(inx) = [ ];
    q.Type(inx) = [ ];
    q.Label(inx) = [ ];
    [output, isValid, query] = implementGet(q, prefix+"Descript");
    assertEqual(testCase, output, cell.empty(1, 0));
    assertEqual(testCase, isValid, true);
    assertEqual(testCase, query, prefix+"Descript");
end


%% Test Get Empty Alias

q = testCase.TestData.Quantity;
map = testCase.TestData.Map;

for prefix = keys(map)
    inx = q.Type==map.(prefix);
    q.Name(inx) = [ ];
    q.Type(inx) = [ ];
    q.Label(inx) = [ ];
    [output, isValid, query] = implementGet(q, prefix+"Alias");
    assertEqual(testCase, output, cell.empty(1, 0));
    assertEqual(testCase, isValid, true);
    assertEqual(testCase, query, prefix+"Alias");
end


##### SOURCE END #####
%}
