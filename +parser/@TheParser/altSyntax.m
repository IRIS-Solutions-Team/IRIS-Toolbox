function altSyntax(this)
% altSyntax  Replace alternative syntax with standard syntax
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

%
% Legacy syntax with warning
%
for i = 1 : size(this.AltKeywordWarn, 1)
    this.Code = regexprep( ...
        this.Code, ...
        this.AltKeywordWarn{i, 1}, ...
        this.AltKeywordWarn{i, 2} ...
    );
end

%
% Alternative or abbreviated syntax, do not report
%
for i = 1 : size(this.AltKeywordRegexp, 1)
    this.Code = regexprep( ...
        this.Code, ...
        this.AltKeywordRegexp{i, 1}, ...
        this.AltKeywordRegexp{i, 2} ...
    );
end

for i = 1 : size(this.AltKeyword, 1)
    this.Code = replace( ... 
        this.Code, ...
        this.AltKeyword{i, 1}, ...
        this.AltKeyword{i, 2} ...
    );
end

end%

