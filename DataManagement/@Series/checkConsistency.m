function flag = checkConsistency(this)
% checkConsistency  Check internal consistency of Series properties
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = checkConsistency@iris.mixin.GetterSetter(this) ...
    && checkConsistency@iris.mixin.UserDataContainer(this) ...
    && hereCheckConsistency( );

return


    function flag = hereCheckConsistency( )
        numelStart = numel(this.Start);
        sizeData = size(this.Data);
        sizeComment = size(this.Comment);
        flag = numelStart==1 && sizeComment(1)==1 && isequal(sizeData(2:end), sizeComment(2:end));
    end%
end%

