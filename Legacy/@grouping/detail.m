function detail(this)
% detail  Display details of grouping object.
%
% Syntax
% =======
%
%     detail(g)
%
%
% Input arguments
% ================
%
% * `g` [ grouping ] - Grouping object.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

textfun.loosespace( );

if isempty(this)
    return
end

isOther = any(this.OtherContents) ;
GroupNames = this.GroupNames ;
groupContents = this.GroupContents ;
if isOther
    GroupNames = [GroupNames, {this.OTHER_NAME}] ;
    groupContents = [groupContents, {this.OtherContents}] ;
end
nGroup = length(GroupNames) ;

for iGroup = 1:nGroup
    fprintf('\t+Group ''%s'':\n', GroupNames{iGroup}) ;
    list = this.List(groupContents{iGroup}) ;
    label = this.Label(groupContents{iGroup}) ;
    for iCont = 1:numel(list)
        iName = list{iCont} ;
        iLabel = label{iCont} ;
        dispName( ) ;
    end
end

textfun.loosespace( );

return




    function dispName( )
        fprintf('\t\t') ;
        fprintf('+%s', iName);
        if ~isempty(iLabel)
            fprintf(' ''%s''', iLabel) ;
        end
        fprintf('\n');
    end
end


