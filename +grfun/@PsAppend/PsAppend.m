classdef PsAppend < handle
    
    
    
    
    properties
        FileName = '';
        PageCount = 0;
        PageNumberFormat = '%g';
        Orientation = 'landscape';
        Driver = '-dpsc';
        Resize = '-fillpage';
        DisplayPageNumber = true;
        Echo = false;
    end
    
    
    
    
    methods
        function this = PsAppend(varargin)
            if isempty(varargin)
                return
            end
            fileName = varargin{1};
            [~, ~, ext] = fileparts(varargin{1});
            if isempty(ext)
                fileName = [fileName, '.ps'];
            end
            this.FileName = fileName;
            if exist(this.FileName, 'file')
                delete(this.FileName)
            end
        end
        
        
        
        
        function add(this, varargin)
            if ~isempty(varargin)
                f = varargin{1};
                figure(f);
            end
            page = this.PageCount + 1;
            orient(this.Orientation);
            t = grfun.ftitle( ...
                sprintf(this.PageNumberFormat, page), ...
                'FontWeight', 'Normal', ...
                'Location', 'South' ...
                );
            cmd = cell(1, 0);
            cmd{end+1} = this.Driver;
            if any(strcmpi(this.Resize, {'-fillpage', '-bestfit'}))
                cmd{end+1} = lower(this.Resize);
            end
            cmd{end+1} = this.FileName;
            cmd{end+1} = '-append';
            print( cmd{:} );
            delete(t);
            this.PageCount = page;
        end
        
        
        
        
        function pdf(this, varargin)
            cmd = cell(1, 0);
            cmd{end+1} = ['/usr/local/bin/ps2pdf ', this.FileName];
            if this.Echo
                cmd{end+1} = '-echo';
            end
            system( cmd{:} );
        end
    end
end
            
