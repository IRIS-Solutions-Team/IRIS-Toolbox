function this = parseRightHandSide(this, rhsString)

%
% Legacy syntax for free parameters
%
rhsString = replace(rhsString, "?", "@");

if endsWith(rhsString, ";")
    rhsString = extractBefore(rhsString, strlength(rhsString));
end

%
% Add an implicit plus sign if RHS starts with an @ to make the
% start of all regression terms of one of the following forms: +@
% or -@ 
%
if startsWith(rhsString, "@")
    rhsString = "+" + rhsString;
end

%
% Switch between linear regression and nonlinear regression depending on
% the presence of @(k) in the equation
%
this.LinearStatus = ~contains(rhsString, "@(");

if this.LinearStatus
    [this, rhsString] = locallyParseExplanatoryTerms(this, rhsString);
end

%
% Add a fixed term (lump sum) if there is anything left
%
rhsString = string(rhsString);
rhsString = regexprep(rhsString, "\s+", "");
if startsWith(rhsString, "+")
    rhsString = extractAfter(rhsString, 1);
end
if strlength(rhsString)>0
    this = addExplanatoryTerm(this, 1, rhsString);
end

return

    function hereReportRegressionCoefficientsInIdentity( )
        thisError = [ 
            "Explanatory:RegressionInIdentity"
            "This Explanatory object specification includes regression "
            "coefficients even though it is marked as an identity: %s "
        ];
        throw(exception.Base(thisError, 'error'), this.InputString);
    end%
end%

%
% Local Functions
%

function [this, rhsString] = locallyParseExplanatoryTerms(this, rhsString)
    %(
    % Find all characters outside any brackets (round, curly, square);
    % these characters will have level==0
    %
    rhsString = char(rhsString);
    [level, allClosed] = textual.bracketLevel(rhsString, {'()', '{}', '[]'}, '--skip');

    %
    % Find the starts of all regression terms
    %
    posStart = sort([strfind(rhsString, '+@'), strfind(rhsString, '-@')]);
    if ~isempty(posStart) && this.IsIdentity
        hereReportRegressionCoefficientsInIdentity( );
    end

    %
    % Collect all regression terms first and see what's left afterwards
    %
    numRegressionTerms = numel(posStart);
    termStrings = repmat("", 1, numRegressionTerms);
    fixed = nan(1, numRegressionTerms);
    for ii = 1 : numRegressionTerms
        ithPosStart = posStart(ii);
        after = false(size(rhsString));
        after(ithPosStart+1:end) = true;
        %
        % Find the end of the current regression term; the end is
        % either a plus or minus sign outside brackets, or the end of
        % the string
        %
        ithPosEnd = find((rhsString=='+' | rhsString=='-') & level==0 & after, 1);
        if ~isempty(ithPosEnd)
            ithPosEnd = ithPosEnd - 1;
        else
            ithPosEnd = numel(rhsString);
        end
        temp = [rhsString(ithPosStart), rhsString(ithPosStart+3:ithPosEnd)];
        temp = replace(temp, " ", "");

        %
        % if the term string consists only of a plus or minus sign, it
        % is a regressin constant, e.g. +@ or -@; make it a valid
        % expression by creating a +1 or -1 string
        %
        if numel(temp)==1
            temp = [temp, '1'];
        end
        if strncmp(temp, '+', 1)
            temp(1) = '';
        end
        termStrings(ii) = string(temp);
        rhsString(ithPosStart:ithPosEnd) = ' ';
    end

    % 
    % Create an explanatory term for each regression term 
    %
    for ii = 1 : numel(termStrings)
        this = addExplanatoryTerm(this, fixed(ii), termStrings(ii));
    end
    %)
end%

    
