% if  Functional or runtime form of an if-elseif-else structure
%{
% ## Syntax ##
%
%
%     output = simulate.if(cond, valueIfTrue, valueElse)
%     output = simulate.if(cond, valueIfTrue, elseifCond, valueElseifTrue, ..., valueElse)
%
%
% ## Input Arguments ##
%
%
% __`cond`__ [ logical ]
% >
% Condition that evaluates to a logical scalar (`true` or `false`) or a
% logical array.
%
%
% __`valueIfTrue`__ [ * ]
% >
% Value returned whenever the `cond` evaluates to `true`.
%
%
% __`valueElse`__ [ * ]
% >
% Value returned whenever the `cond` and each `elseifCond` evaluate to `false`.
%
% 
% __`elseIfCondition`__ [ logical ]
% >
% Condition evaluated whenever the first `cond` and each preceding
% `elseifCond` evaluate to `false`; there can be any number of
% `elseIfCondition`-`valueElseifTrue` pairs.
%
% 
% __`valueElseifTrue`__ [ logical ]
% >
% Value returned whenever the respective `elseifCond` evaluate to
% `true` (and the first `cond` and each preceding `elseifCond`
% evalute to `false`); there can be any number of
% `elseIfCondition`-`valueElseifTrue` pairs.
%
%
% ## Output Arguments ##
%
%
% __`output`__ [ | ]
% >
% Value returned depending on the `cond`.
%
%
% ## Description ##
%
% Use this function in an Explanatory to mimic the following
% if-elseif-else structure:
% 
%     if cond
%         valueIfTrue;
%     elseif elseifCond
%         valueElseifTrue;
%     ...
%     else
%         valueElse;
%     end
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function output = if_(varargin)

%--------------------------------------------------------------------------

final = varargin{end};
conditions = varargin(1:2:end-1);
values = varargin(2:2:end-1);

sizeCondition = size(conditions{1});
maxSizeCondition = max(sizeCondition);
if maxSizeCondition>1 
    if numel(values{1})==1
        values{1} = repmat(values{1}, sizeCondition);
    else
        values{1} = reshape(values{1}, sizeCondition);
    end
end

output = values{1};
dealt = conditions{1};
for i = 2 : numel(conditions)
    if all(dealt)
        break
    end
    if ~any(conditions{i})
        continue
    end
    condition__ = conditions{i};
    if numel(values{i})==1
        value__ = values{i};
    else
        if maxSizeCondition>1
            if numel(condition__)==1
                condition__ = repmat(condition__, sizeCondition);
            else
                condition__ = reshape(condition__, sizeCondition);
            end
        end
        value__ = values{i}(~dealt & condition__);
    end
    output(~dealt & condition__) = value__;
    dealt = dealt | condition__;
end

if any(~dealt)
    if numel(final)>1
        final = final(~dealt);
    end
    output(~dealt) = final;
end

end%




%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=simulate/ifUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


%% Test Scalar
    x = simulate.if(true, 1, true, 2, 3);
    assertEqual(testCase, x, 1);
    x = simulate.if(false, 1, true, 2, 3);
    assertEqual(testCase, x, 2);
    x = simulate.if(false, 1, false, 2, 3);
    assertEqual(testCase, x, 3);
    x = simulate.if(false, 1, false, 2, true, 3, 4);
    assertEqual(testCase, x, 3);


%% Test Vector
    x = simulate.if([false, false, true], [1, 2, 3], [true, false, true], [10, 20, 30], [100, 200, 300]);
    assertEqual(testCase, x, [10, 200, 3]);


%% Text Mixed
    x = simulate.if([false, false, true], 1, true, [10, 20, 30], NaN);
    assertEqual(testCase, x, [10, 20, 1]);
    x = simulate.if([false, false, true], 1, [false, false, false], [10, 20, 30], NaN);
    assertEqual(testCase, x, [NaN, NaN, 1]);
    x = simulate.if([true, false, true], 1, [false, true, true], [10, 20, 30], [100, 200, 300]);
    assertEqual(testCase, x, [1, 20, 1]);
    x = simulate.if([true, false, true], 1, [false, false, true], [10, 20, 30], [100, 200, 300]);
    assertEqual(testCase, x, [1, 200, 1]);

##### SOURCE END #####
%}
