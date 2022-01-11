classdef Config
    properties (Constant)
        URL = "https://api.stlouisfed.org/fred"
        Key = "951f01181da86ccb9045ce8716f82f43"
        Parameters = "?series_id=%s&api_key=%s&file_type=json"
        FreqConversion = "&frequency=%s&aggregation_method=%s";
    end
end
