function updateDataBlock(this, dataBlock, plainData, residuals)
% updateDataBlock  Update dataBlock from plainData after simulation
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if ~isempty(this.Runtime.PosUpdateInDataBlock) && ~isempty(this.Runtime.PosUpdateInPlainData) ...
    && ~isempty(plainData)
    dataBlock.YXEPG(this.Runtime.PosUpdateInDataBlock, :, :) = plainData(this.Runtime.PosUpdateInPlainData, :, :);
end

if nargin>=4 && ~isempty(this.Runtime.PosResidualInDataBlock) ...
    && ~isempty(residuals)
    dataBlock.YXEPG(this.Runtime.PosResidualInDataBlock, :, :) = residuals;
end

end%

