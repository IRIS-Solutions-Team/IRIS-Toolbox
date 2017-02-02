% Exported  Shared class to implement user functions exported to disk files.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Exported
    properties
        ExportedFile = cell(0, 2)
    end
    
    
    
    
    properties (Constant, Hidden)
        FILE_HEADER = '% IRIS Exported File $TimeStamp$';
    end
    
    
    
    
    methods
        function this = Exported(varargin)
            if nargin==0
                return
            end
            this.ExportedFile = varargin(1:2).';
        end
        
        
        
        
        function hasBeenDeleted = export(this)
            n = size(this.ExportedFile, 2);
            hasBeenDeleted = false(1, n);
            if n==0
                return
            end
            BR = sprintf('\n');
            stamp = strrep( ...
                shared.Exported.FILE_HEADER, ...
                '$TimeStamp$', ...
                datestr(now( )) ...
                );
            for i = 1 : n
                fileName = this.ExportedFile{1, i};
                fileContent = this.ExportedFile{2, i};
                if isempty(fileName)
                    return
                end
                fileName = fullfile(pwd( ), fileName);
                if utils.exist(fileName, 'file')
                    hasBeenDeleted(i) = true;
                end
                fileContent = [stamp, BR, BR, fileContent]; %#ok<AGROW>
                char2file(fileContent, fileName);
            end
            rehash( );
        end
        
        
        
        
        function [answ, flag, query] = implementGet(this, query, varargin)
            answ = [ ];
            flag = true;
            switch lower(query)
                case {'export', 'exportedfile', 'exportedfiles'}
                    answ = shared.Exported;
                    answ.ExportedFile = this.ExportedFile;
                otherwise
                    flag = false;
            end
        end
        
        
        
        function disp(this, varargin)
            n = size(this.ExportedFile, 2);
            msg = sprintf('[%g]', n);
            fprintf('\texported file(s): %s\n', msg);
            if nargin==1
                textfun.loosespace( );
            end
        end
        
        
        
        
        function varargout = size(this)
            n = size(this.ExportedFile, 2);
            if nargout<=1
                varargout{1} = [1, n];
            else
                varargout = {1, n};
            end
        end
        
        
        
        
        function this = add(this, varargin)
            if length(varargin)==1
                if isa(varargin{1}, 'shared.Exported')
                    % add(this, obj)
                    this.ExportedFile = [ ...
                        this.ExportedFile, ...
                        varargin{1}.ExportedFile ...
                        ];
                elseif iscellstr(varargin{1})
                    % add(this, {fileName; fileContent})
                    this.ExportedFile = [ ...
                        this.ExportedFile, ...
                        varargin{1} ...
                        ];
                end
            else
                % add(this, fileName, fileContent)
                this.ExportedFile = [ ...
                    this.ExportedFile, ...
                    [ varargin(1); varargin(2) ], ...
                    ];
            end
        end
    end
end
