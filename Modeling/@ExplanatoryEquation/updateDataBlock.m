function updateDataBlock(this, dataBlock, plainData)
% updateDataBlock  Update dataBlock from plainData after simulation
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

dataBlock.YXEPG(this.Runtime.PosUpdateTo, :, :) = plainData(this.Runtime.PosUpdateFrom, :, :);

end%
