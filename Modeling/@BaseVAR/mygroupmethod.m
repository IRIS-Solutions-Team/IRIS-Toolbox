function outp = mygroupmethod(func, this, inp, varargin)
% mygroupmethod  Implement methods requiring input data for panel VARs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

% Empty input data are allowed in `resample`.
isEmptyInp = isempty(inp);

%--------------------------------------------------------------------------

nGrp = length(this.GroupNames);
outp = struct( );

% Verify that input data contain fields for each group.
if ~isEmptyInp
    ixValid = true(1, nGrp);
    for iGrp = 1 : nGrp
        name = this.GroupNames{iGrp};
        try
            inp.(name);
        catch
            ixValid(iGrp) = false;
        end
    end
    if any(~ixValid)
        throw( exception.Base('VAR:GROUP_NOT_INPUT_DATA', 'error'), ...
            this.GroupNames{~ixValid} );
    end
end

for iGrp = 1 : nGrp
    name = this.GroupNames{iGrp};
    iThis = group(this, name);
    if isEmptyInp
        iInp = [ ];
    else
        iInp = inp.(name);
    end
    outp.(name) = func(iThis, iInp, varargin{:});
end

end