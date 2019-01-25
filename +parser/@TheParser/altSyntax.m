function altSyntax(this)
% altSyntax  Replace alternative syntax with standard syntax.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Obsolete alternative syntax, throw a warning.
for iBlk = 1 : size(this.AltKeywordWarn, 1)
    this.Code = regexprep( ...
        this.Code, ...
        this.AltKeywordWarn{iBlk, 1}, ...
        this.AltKeywordWarn{iBlk, 2} ...
        );
end

% Alternative or abbreviated syntax, do not report.
for iBlk = 1 : size(this.AltKeyword, 1)
    this.Code = regexprep( ...
        this.Code, ...
        this.AltKeyword{iBlk, 1}, ...
        this.AltKeyword{iBlk, 2} ...
        );
end

end
