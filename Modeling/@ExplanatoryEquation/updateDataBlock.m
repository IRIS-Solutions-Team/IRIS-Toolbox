function updateDataBlock(this, dataBlock, plainData, residuals)
% updateDataBlock  Update dataBlock from plainData after simulation
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if ~isempty(this.Runtime.PosUpdateTo) && ~isempty(this.Runtime.PosUpdateFrom)
    dataBlock.YXEPG(this.Runtime.PosUpdateTo, :, :) = plainData(this.Runtime.PosUpdateFrom, :, :);
end

end%

