% TheParser  Main IRIS model file parser.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef TheParser < handle
    properties
        FName = ''
        Caller = ''
        Code = ''
        Block = cell(1, 0)
        AltKeyword = cell(0, 2)
        AltKeywordWarn = cell(0, 2)
        OtherKeyword = cell(1, 0)
        DbaseAssigned = struct( )
        StrAssigned = cell(1, 0)
        AssignOrd = repmat(parser.TheParser.TYPE(0), 1, 0) % Order in which values assigned to names will be evaluated.
    end
    
    
    
    
    properties (Constant)
        TYPE = @int8;
        STD_PREFIX = 'std_';
        CORR_PREFIX = 'corr_';
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
                    throw( exception.Base('General:INTERNAL', 'error') );
            end
            this.FName = fileName;
            this.Code = code;
            this.DbaseAssigned = a;
        end
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
