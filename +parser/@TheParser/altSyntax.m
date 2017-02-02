function altSyntax(this)
% altSyntax  Replace alternative syntax with standard syntax.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Steady-state reference $Name -> &Name.
this.Code = regexprep(this.Code, '\$\<([a-zA-Z]\w*)\>(?!\$)', '&$1');

% Obsolete alternative syntax, throw a warning.
nBlkWarn = size(this.AltKeywordWarn, 1);
ixObsolete = false(nBlkWarn, 1);

for iBlk = 1 : nBlkWarn
    ptn = ['\<', this.AltKeywordWarn{iBlk,1}, '\>'];
    if true % ##### MOSW
        replaceFunc = @replace; %#ok<NASGU>
        this.Code = regexprep(this.Code, ptn, '${replaceFunc( )}');
    else
        This.Code = mosw.dregexprep(This.Code,ptn, @replace, [ ]); %#ok<UNRCH>
    end
end




    function C = replace( )
        C = this.AltKeywordWarn{iBlk, 2};
        ixObsolete(iBlk) = true;
    end




% Create a cellstr {obsolete, new, obsolete, new,...} for obsolete syntax.
if any(ixObsolete)
    lsObsolete = this.AltKeywordWarn(ixObsolete, :).';
    lsObsolete = lsObsolete(:).';
    throw( exception.Base('Obsolete:KEYWORD_USE_INSTEAD', 'warning'), ...
        lsObsolete{:} );
end

% Alternative or abbreviated syntax, do not report.
nAltBlk = size(this.AltKeyword, 1);
for iBlk = 1 : nAltBlk
    this.Code = regexprep(...
        this.Code, ...
        [this.AltKeyword{iBlk,1}, '\>'], ...
        this.AltKeyword{iBlk,2} ...
        );
end

end
