% TheParser  Main IRIS model file parser
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

classdef TheParser < handle
    properties
        FName = char.empty(1, 0)
        Caller = char.empty(1, 0)
        Code = char.empty(1, 0)
        Block = cell.empty(1, 0)
        AltKeyword = cell.empty(0, 2)
        AltKeywordRegexp = cell.empty(0, 2)
        AltKeywordWarn = cell.empty(0, 2)
        OtherKeyword = cell.empty(1, 0)
        AssignedDatabank = struct( )
        AssignedString = cell.empty(1, 0)
        AssignOrder = int8.empty(1, 0) % Order in which values assigned to names will be evaluated
    end
    
    
    properties (Constant)
        FN_EMPTY_BLOCK = @(x) isempty(x) || all(double(x)<=32);
    end
    
    
    methods
        function this = TheParser(caller, fileName, code, a)
            if nargin==0
                return
            end
            this.Caller = caller;
            switch this.Caller
                case 'model'
                    setupModel(this);
                case 'rpteq'
                    setupRpteq(this);
                otherwise
                    throw( exception.Base('General:Internal', 'error') );
            end
            this.FName = fileName;
            this.Code = code;
            this.AssignedDatabank = a;
        end%
    end
    
    
    methods
        varargout = assign(varargin)
        varargout = altSyntax(varargin)
        varargout = getBlockKeyword(varargin)
        varargout = parse(varargin)
        varargout = readBlockCode(varargin)
        varargout = setupModel(varargin)
        varargout = setupRpteq(varargin)
    end
end

