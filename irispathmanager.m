function varargout = irispathmanager(Req,varargin)
% irispathmanager  [Not a public function] IRIS path manager.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

switch lower(Req)
    case 'cleanup'
        % Remove all IRIS roots and subs found on the Matlab temporary
        % and permanent search paths.
        thisRoot = fileparts(mfilename('fullpath'));
        list = which('irisstartup.m','-all');
        removed = { };
        for i = 1 : numel(list)
            root = fileparts(list{i});
            if isempty(root) || strcmpi(root,thisRoot)
                continue
            end
            [~,allp] = irisgenpath(root);
            xxRmPath(allp{:},root);
            removed{end+1} = root; %#ok<AGROW>
        end
        % Remove the current IRIS root last; otherwise `irisgenpath( )` will not be
        % found.
        [~,allp] = irisgenpath(thisRoot);
        xxRmPath(allp{:},thisRoot);
        removed{end+1} = thisRoot;
        
        varargout{1} = removed;
        rehash( );
    
    case 'addroot'
        % Add the specified root to the temporary search paths.
        addpath(varargin{1},'-begin');
    
    case 'addcurrentsubs'
        % Add subfolders within the current root to the temporary
        % search path.
        [p,allp] = irisgenpath( );
        if true % ##### MOSW
            % Do nothing.
        else 
            if ~isempty(p.OctBegin) %#ok<UNRCH>
                addpath(p.OctBegin{:},'-begin');
            end
        end
        if ~isempty(p.Begin)
            addpath(p.Begin{:},'-begin');
        end
        if ~isempty(p.End)
            addpath(p.End{:},'-end');
        end
        if true % ##### MOSW
            % Do nothing.
        else
            if ~isempty(p.OctEnd) %#ok<UNRCH>
                addpath(p.OctEnd{:},'-end');
            end
        end
        varargout{1} = allp;
        
    case 'removecurrentsubs'
        % Remove subfolders within the current root from the temporary
        % and permanent search paths.
        [~,allp] = irisgenpath( );
        xxRmPath(allp{:});
        varargout{1} = allp;
end

end


% Subfunctions...


%**************************************************************************


function xxRmPath(varargin)
if isempty(varargin)
    return
end
status = warning('query','all');
warning('off','MATLAB:rmpath:DirNotFound');
rmpath(varargin{:});
warning(status);
end % xxRmPath( )
