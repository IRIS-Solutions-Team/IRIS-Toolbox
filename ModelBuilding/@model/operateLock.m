function varargout = operateLock(this, type, action, varargin)
% operateLock  Query, enable, disable links and revisions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;
PTR = @int16;
LS_TYPE = {'!links', 'links', '!revisions', 'revisions'};

if isempty(varargin)
    list = @all;
else
    list = varargin;
end

pp = inputParser( );
pp.addRequired('m', @(x) isa(x, 'model'));
pp.addRequired('type', @(x) ischar(x) && any(strcmpi(x, LS_TYPE)));
pp.addRequired('list', @(x) isequal(x, @all) || iscellstr(x));
pp.parse(this, type, list);

%--------------------------------------------------------------------------

nQty = length(this.Quantity);

type = strrep(type, '!', '');
type = upper(type(1));
switch type
    case 'L' % !links
        ptr = this.Link.LhsPtr;
        lsName = [ ...
            this.Quantity.Name, ...
            getStdName(this.Quantity), ...
            getCorrName(this.Quantity), ...
            ];        
    case 'R' % !revisions
        ptr = this.Pairing.Revision;
        lsName = this.Quantity.Name;
end

absPtr = abs(ptr);

if action==0
    % Get status (Action==0), active=true, inactive=false.
    if isequal(list, @all)
        ixActive = ptr>PTR(0);
        ixInactive = ptr<PTR(0);
        ixInclude = ixActive | ixInactive;
        varargout{1} = cell2struct( ...
            num2cell(ixActive(ixInclude)), ...
            lsName(absPtr(ixInclude)), 2 ...
            );        
    else
        posQuery = matchNames( );
        varargout{1} = ptr(posQuery)>PTR(0);
    end
else
    % Disable (Action==-1) or enable (Action==1).
    if isequal(list, @all)
        posToChange = ':';
    else
        posToChange = matchNames( );
    end
    if ~isempty(posToChange)
        ptr(posToChange) = PTR( action*abs(ptr(posToChange)) );
        switch type
            case 'L'
                this.Link.LhsPtr = ptr;
            case 'R'
                this.Pairing.Revision = ptr;
        end
    end
    varargout{1} = this;    
end

return




    function posLock = matchNames( )
        ixValid = false(size(list));
        ell = lookup(this.Quantity, list);
        posLock = [ ];
        for i = 1 : length(list)
            ixMatch = ell.PosName(i)==absPtr;
            if any(ixMatch)
                ixValid(i) = true;
                posLock(end+1) = find(ixMatch); %#ok<AGROW>
                continue
            end
            ixMatch = ell.PosStdCorr(i)+nQty==absPtr;
            if any(ixMatch)
                ixValid(i) = true;
                posLock(end+1) = find(ixMatch); %#ok<AGROW>
                continue
            end
        end
        if any(~ixValid)
            switch type
                case 'L'
                    throw( ...
                        exception.Base('Equation:INVALID_LHS_LINK_LOCK', 'error'), ...
                        list{~ixValid} ...
                        );
                case 'R'
                    throw( ...
                        exception.Base('Equation:INVALID_LHS_REVISION_LOCK', 'error'), ...
                        list{~ixValid} ...
                        );
            end
        end
    end 
end
