function flag = chkConsistency(this)
% chkConsistency  Check internal consistency of object properties
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

flag =    chkConsistency@shared.GetterSetter(this) ...
       && chkConsistency@shared.UserDataContainer(this) ...
       && hereCheckConsistency( );

return


    function flag = hereCheckConsistency( )
        sizeData = size(this.Data);
        sizeComment = size(this.Comment);
        flag =    sizeComment(1)==1 ...
               && isequal(sizeData(2:end), sizeComment(2:end));
    end%
end%

