function flag = checkConsistency(this)

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
