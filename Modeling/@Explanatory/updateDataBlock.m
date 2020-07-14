function updateDataBlock(this, dataBlock, plainData, residuals)
% updateDataBlock  Update dataBlock from plainData after simulation
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if ~isempty(this.Runtime.PosUpdateInDataBlock) && ~isempty(this.Runtime.PosUpdateInPlainData)
    dataBlock.YXEPG(this.Runtime.PosUpdateInDataBlock, :, :) = plainData(this.Runtime.PosUpdateInPlainData, :, :);
end

end%

