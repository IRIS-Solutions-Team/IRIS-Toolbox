% Export  Implement export of user functions to disk files
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

classdef Export < handle
    properties
        FileName = char.empty(1, 0)
        Contents = char.empty(1, 0)
    end
    
    
    properties (Constant, Hidden)
        FILE_HEADER = '% IRIS Export File $TimeStamp$';
    end
    
    
    methods
        function this = Export(varargin)
            if nargin==0
                return
            end
            this.FileName = varargin{1};
            this.Contents = varargin{2};
        end%
        
        
        function beenDeleted = export(this)
            n = numel(this);
            beenDeleted = false(1, n);
            if n==0
                return
            end
            BR = sprintf('\n');
            stamp = strrep( ...
                shared.Export.FILE_HEADER, ...
                '$TimeStamp$', ...
                datestr(now( )) ...
                );
            for i = 1 : n
                fileName = this(i).FileName;
                contents = this(i).Contents;
                if isempty(fileName)
                    return
                end
                fileName = fullfile(pwd( ), fileName);
                if exist(fileName, 'file')
                    beenDeleted(i) = true;
                end
                contents = [stamp, BR, BR, contents]; %#ok<AGROW>
                char2file(contents, fileName);
            end
            rehash( );
        end%
        
        
        function [answ, flag, query] = implementGet(this, query, varargin)
            answ = [ ];
            flag = true;
            if any(strcmpi(query, {'Export', 'ExportedFile', 'ExportedFiles'}))
                answ = this;
            else
                flag = false;
            end
        end%


        function implementDisp(this)
            CONFIG = iris.get( );
            fprintf(CONFIG.DispIndent);
            fprintf('Export File(s): [%g]\n', numel(this));
        end%
    end
end
