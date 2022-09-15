function implementDisp(this)
% implementDisp  Implement disp method for Grouping objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

if isempty(this)
    if isempty(this.Type)
        fprintf('\tEmpty %s Object\n', ccn);
    else
        fprintf('\tEmpty %s %s Object\n', this.Type, ccn);
    end
else
    isOther = any(this.OtherContents) ;
    nGroup = length(this.GroupNames) + double(isOther) ;
    fprintf('\t%s %s Object: [%g] Group(s)\n', this.Type, ccn, nGroup) ;
end

if ~isempty(this.Type)
    names = 'Empty';
    if ~isempty(this.List)
        names = textfun.displist(this.List);
    end
    fprintf('\t%s Names: %s\n', this.Type, names);
    
    if ~isempty(this.GroupNames)
        names = this.GroupNames;
        if any(this.OtherContents)
            names = [names,this.OTHER_NAME];
        end
        names = textfun.displist(names);
    else
        names = 'Empty';
    end
    fprintf('\tGroup Names: %s',names);
    fprintf('\n');
end

implementDisp@iris.mixin.CommentContainer(this);
implementDisp@iris.mixin.UserDataContainer(this);

end%

