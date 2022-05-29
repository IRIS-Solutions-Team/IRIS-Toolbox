% runGroups  Implement methods requiring input data for panel VARs
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outp = runGroups(func, this, inp, varargin)

% Empty input data are allowed in `resample`.
isEmptyInp = isempty(inp);

%--------------------------------------------------------------------------

numGroups = this.NumGroups;
outp = struct( );

% Verify that input data contain fields for each group
if ~isEmptyInp
    inxValid = true(1, numGroups);
    for i = 1 : numGroups
        name = this.GroupNames(1);
        inxValid(i) = isfield(inp, name) && validate.databank(inp.(name));
    end
    if any(~inxValid)
        exception.error([
            "BaseVAR:GroupNotInDatabank"
            "This group is not included in the input databank: %s "
        ], this.GroupNames(~inxValid));
    end
end

for i = 1 : numGroups
    [this__, name] = group(this, i);
    if isEmptyInp
        iInp = [ ];
    else
        iInp = inp.(name);
    end
    outp.(name) = func(this__, iInp, varargin{:});
end

end%

