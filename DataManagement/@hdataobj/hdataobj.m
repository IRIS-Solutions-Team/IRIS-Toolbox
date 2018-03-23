classdef hdataobj<handle
    % hdataobj  [Not a public class] Handle class for memory-efficient storing of output data.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2018 IRIS Solutions Team.

    
    properties
        Data = struct( );
        Range = double.empty(1, 0);
        Id = cell.empty(1, 0);
        IxLog = logical.empty(1, 0);
        
        Name = cell.empty(1, 0);
        Label = cell.empty(1, 0);
        
        Precision = 'double';
        IncludeLag = true; % Include lags of variables in output tseries.
        IncludeParam = true; % Include parameter database.
        IsVar2Std = false; % Convert variance to std dev.
        Contributions = [ ]; % If non-empty, contains labels for contributions.
        ParamDb = struct( );
    end
    
    
    methods
        varargout = hdataassign(varargin)
        varargout = hdata2tseries(varargin)
    end
    
    
    methods (Static)
        varargout = hdatafinal(varargin)
    end
    
    
    methods
        function this = hdataobj(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'hdataobj')
                this = varargin{1};
                return
            end
            if nargin>1
                % hdataobj(callerObj, range, [size2, ...], ...)
                callerObj = varargin{1};
                this.Range = varargin{2};
                Size = varargin{3};
                varargin(1:3) = [ ];
                nPer = length(this.Range);
                if isempty(Size)
                    utils.error('hdataobj:hdataobj', ...
                        'Size in second dimension not supplied.');
                end
                
                for i = 1 : 2 : length(varargin)
                    name = strrep(varargin{i}, '=', '');
                    this.(name) = varargin{i+1};
                end
                    
                hdatainit(callerObj, this);
                
                % Initialize all variables in each block with NaN arrays. Max lag is
                % computed for each block.
                for i = 1 : length(this.Id) 
                    if isempty(this.Id{i})
                        continue
                    end
                    imagId = imag(this.Id{i});
                    realId = real(this.Id{i});
                    maxLag = -min(imagId);
                    nRow = nPer;
                    if this.IncludeLag && maxLag>0
                        nRow = nRow + maxLag;
                    end
                    for j = sort(realId(imagId==0))
                        name = this.Name{j};
                        this.Data.(name) = nan(nRow, Size, this.Precision);
                    end
                end 
                
                if this.IncludeParam
                    this.ParamDb = addToDatabank('Default', callerObj);
                end
            end
        end
    end
end
