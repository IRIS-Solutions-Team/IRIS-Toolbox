classdef SourceFiles < handle
    properties
        SingleFile = false
        FolderName = char.empty(1, 0)
        List = cell.empty(1, 0)
    end


    methods
        function this = SourceFiles(fileName, singleFile)
            [p, t, x] = fileparts(fileName);
            this.FolderName = fullfile(p, [t, '_SourceFiles']);
            cleanup(this);
            mkdir(this.FolderName);
            this.SingleFile = singleFile;
        end%


        function newFileName = getNewFileName(this, varargin)
            newFileName = tempname(this.FolderName);
            if ~isempty(varargin)
                newFileName = [newFileName, '.', varargin{1}];
            end
        end%


        function add(this, varargin)
            this.List = [this.List, varargin];
        end%


        function cleanup(this)
            if isempty(this)
                return
            end
            if isempty(this.FolderName)
                return
            end
            if ~exist(this.FolderName, 'dir')
                return
            end
            rmdir(this.FolderName, 's');
        end%
    end
end

