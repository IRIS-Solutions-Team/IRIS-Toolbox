classdef hdataobj < handle
    % hdataobj  [Not a public class] Handle class for memory-efficient storing of output data.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2017 IRIS Solutions Team.

    
    properties
        Data = struct( );
        Range = zeros(1,0);
        Id = cell(1,0);
        IxLog = false(1,0);
        
        Name = cell(1,0);
        Label = cell(1,0);
        
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
        function This = hdataobj(varargin)
            if nargin == 0
                return
            end
            if nargin == 1 && isa(varargin{1},'hdataobj')
                This = varargin{1};
                return
            end
            if nargin > 1
                % hdataobj(CallerObj,Range,[Size2,...],...)
                CallerObj = varargin{1};
                This.Range = varargin{2};
                Size = varargin{3};
                varargin(1:3) = [ ];
                nPer = length(This.Range);
                if isempty(Size)
                    utils.error('hdataobj:hdataobj', ...
                        'Size in second dimension not supplied.');
                end
                
                for i = 1 : 2 : length(varargin)
                    name = strrep(varargin{i},'=','');
                    This.(name) = varargin{i+1};
                end
                    
                hdatainit(CallerObj,This);
                
                % Initialize all variables in each block with NaN arrays. Max lag is
                % computed for each block.
                for i = 1 : length(This.Id) 
                    if isempty(This.Id{i})
                        continue
                    end
                    imagId = imag(This.Id{i});
                    realId = real(This.Id{i});
                    maxLag = -min(imagId);
                    nRow = nPer;
                    if This.IncludeLag && maxLag > 0
                        nRow = nRow + maxLag;
                    end
                    for j = sort(realId(imagId == 0))
                        name = This.Name{j};
                        This.Data.(name) = nan(nRow,Size,This.Precision);
                    end
                end 
                
                if This.IncludeParam
                    This.ParamDb = addparam(CallerObj);
                end
            end
        end
    end
end
