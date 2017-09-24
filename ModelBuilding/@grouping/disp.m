function disp(this)
% disp  Display method for grouping objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

if isempty(this)
    if isempty(this.Type)
        fprintf('\tempty %s object\n', ccn);
    else
        fprintf('\tempty %s %s object\n', this.Type, ccn);
    end
else
    isOther = any(this.OtherContents) ;
    nGroup = length(this.GroupNames) + double(isOther) ;
    fprintf('\t%s %s object: [%g] group(s)\n', this.Type, ccn, nGroup) ;
end

if ~isempty(this.Type)
    names = 'empty';
    if ~isempty(this.List)
        names = textfun.displist(this.List);
    end
    fprintf('\t%s names: %s\n', this.Type, names);
    
    if ~isempty(this.GroupNames)
        names = this.GroupNames;
        if any(this.OtherContents)
            names = [names,this.OTHER_NAME];
        end
        names = textfun.displist(names);
    else
        names = 'empty';
    end
    fprintf('\tgroup names: %s',names);
    fprintf('\n');
end

disp@shared.UserDataContainer(this, 1);
textfun.loosespace( );

end


