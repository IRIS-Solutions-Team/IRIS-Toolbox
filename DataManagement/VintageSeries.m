classdef VintageSeries < Series
    properties
        VintageStart = DateWrapper.NaD( )
    end

    methods
        function this = VintageSeries(varargin)
            vintageDates = DateWrapper.NaD( );
            if nargin>=2
                vintageDates = varargin{2};
                varargin(2) = [ ];
            end
            this = this@Series(varargin{:});
            this = initVintages(this, vintageDates);
        end%


        function varargout = subsref(this, s, varargin)
            if isstruct(s) && isequal(s(1).type, '.')
                [varargout{1:nargout}] = builtin('subsref', this, s);
                return
            end
            [s, this] = convertSubscript(this, s, varargin{:});
            [varargout{1:nargout}] = subsref@Series(this, s);
        end%


        function varargout = subsasgn(this, s, value, varargin)
            if isstruct(s) && isequal(s(1).type, '.')
                [varargout{1:nargout}] = builtin('subsasgn', this, s, value);
                return
            end
            [s, this] = convertSubscript(this, s, varargin{:});
            [varargout{1:nargout}] = subsasgn@Series(this, s, value);
        end%


        function index = end(this, k, varargin)
            if k==1
                index = addTo(this.Start, size(this.Data, 1)-1);
            elseif k==2
                index = addTo(this.VintageStart, size(this.Data, 2)-1);
            else
                index = size(this.Data, k);
            end
        end%
    end


    methods (Access=protected, Hidden)
        function this = initVintages(this, vintageDates)
            sizeOfData = size(this.Data);
            numberOfVintageDates = numel(vintageDates);
            if numberOfVintageDates==1
                if sizeOfData(2)==0
                    this.VintageSeries = DateWrapper.NaD( );
                    return
                else
                    this.VintageStart = vintageDates;
                    return
                end
            end

            if numberOfVintageDates~=sizeOfData(2)
                throw( exception.Base('VintageSeries:DatesDataDimensionMismatch', 'error') );
            end

            freq = getFrequency( getFirst(vintageDates) );
            serials = getSerial(vintageDates);
            minSerial = min(serials);
            posOfSerials = round(serials - minSerial + 1);
            sizeOfNewData = sizeOfData;
            sizeOfNewData(2) = max(posOfSerials);
            newData = repmat(this.MissingValue, sizeOfNewData);
            newData(:, posOfSerials, :) = this.Data(:, :, :);
            this.Data = newData;
            this.VintageStart = DateWrapper.fromSerial(freq, minSerial);
        end%


        function [s, this] = convertSubscript(this, s, varargin)
            if ~isstruct(s)
                % Short-cut call subsref(this, ref1, ref2, ...)
                subs = [ {s}, varargin ];
                s = struct( );
                s.type = '()';
                s.subs = subs;
            end
            sizeOfData = size(this.Data);
            indexExisting = logical.empty(1, 0);
            shift = NaN;
            if numel(s.subs)>=2 
                posOfVintages = s.subs{2};
                if isa(posOfVintages, 'DateWrapper')
                    % Convert dates in second dimension to subscripts
                    if isnan(this.VintageStart)
                        this.VintageStart = min(posOfVintages);
                    end
                    posOfVintages = rnglen(this.VintageStart, posOfVintages);
                end
                if isnumeric(posOfVintages)
                    maxPos = max(posOfVintages);
                    if maxPos>sizeOfData(2)
                        sizeOfDataToAdd = sizeOfData;
                        sizeOfDataToAdd(2) = maxPos - sizeOfData(2);
                        dataToAdd = repmat(this.MissingValue, sizeOfDataToAdd);
                        this.Data = [this.Data, dataToAdd];
                        commentsToAdd = repmat({this.EMPTY_COMMENT}, 1, sizeOfDataToAdd(2));
                        this.Comment = [this.Comment, commentsToAdd];
                    end
                    minPos = min(posOfVintages);
                    if minPos<1
                        sizeOfDataToAdd = sizeOfData;
                        sizeOfDataToAdd(2) = 1 - minPos;
                        dataToAdd = repmat(this.MissingValue, sizeOfDataToAdd);
                        this.Data = [dataToAdd, this.Data];
                        commentsToAdd = repmat({this.EMPTY_COMMENT}, 1, sizeOfDataToAdd(2));
                        this.Comment = [commentsToAdd, this.Comment];
                        this.VintageStart = addTo(this.VintageStart, minPos-1);
                        posOfVintages = posOfVintages - minPos + 1;
                    end
                    s.subs{2} = posOfVintages;
                end
            end
        end%
    end


    methods (Hidden)
        function this = trim(this)
            p = [2, 1, 3:ndims(this.Data)];
            [newData, newVintageStart, first, last] = ...
                this.trimRows(permute(this.Data, p), this.VintageStart, this.MissingValue, this.MissingTest);
            this.Data = ipermute(newData, p);
            this.VintageStart = newVintageStart;
            if ~isempty(first)
                this.Comment = this.Comment(first:last);
            end
            this = trim@Series(this);
        end%
    end
end
