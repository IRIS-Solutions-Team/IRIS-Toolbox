function flag = checkConsistency(this)
% checkConsistency  Check internal consistency of NumericTimeSubscriptable properties
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = checkConsistency@shared.GetterSetter(this) ...
    && checkConsistency@shared.UserDataContainer(this) ...
    && hereCheckConsistency( );

return


    function flag = hereCheckConsistency( )
        numelStart = numel(this.Start);
        sizeData = size(this.Data);
        sizeComment = size(this.Comment);
        flag = numelStart==1 && sizeComment(1)==1 && isequal(sizeData(2:end), sizeComment(2:end));
    end%
end%

