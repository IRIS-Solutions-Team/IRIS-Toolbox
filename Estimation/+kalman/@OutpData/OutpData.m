classdef OutpData < handle
    properties
        StorePredict = false
        StoreFilter = false
        StoreSmooth = false
        StoreAhead = false
        RescaleVar = false
        Ahead = 0
        
        Range = [ ]                  % Filter range
        aInit = [ ]
        PaInit = [ ]
        
        MinLogLik = NaN
        VarScale = 1
        
        w0 = [ ]
        w1 = [ ]
        ww1 = [ ]
        w2 = [ ] 
        Pw0 = [ ]
        Pw1 = [ ]
        Pw2 = [ ]
        
        pe = [ ]
        y0 = [ ]
        y1 = [ ]
        yy1 = [ ]
        y2 = [ ] 
        Py0 = [ ]
        Py1 = [ ]
        Py2 = [ ]
        
        e0 = [ ]
        e1 = [ ]
        ee1 = [ ] 
        e2 = [ ]
        
        a2 = [ ]                     % Smoothed initial condition for alpha.
        Pa2 = [ ]                    % Smoothed initial condition for MSE alpha.
        
        RR = [ ]
        TT = [ ]
        HH = [ ]
        OOmg = [ ]
        ixa = false(0, 1)

        ixyy = cell(1, 0)
        P = cell(1, 0)
        K = cell(1, 0)
        ZFZ = cell(1, 0)
        ZFpe = cell(1, 0)
        Fpe = cell(1, 0)
        L = cell(1, 0)
    end
    
    
    
    
    methods
        function prealloc(this, s, inp)
            nPer = size(inp.y, 2);
            [nx, ~] = size(s.T);
            [ny, ne] = size(s.H);
            this.w0 = nan(nx, nPer);            
            this.w1 = nan(nx, nPer);
            this.w2 = nan(nx, nPer);
            this.Pw0 = nan(nx, nx, nPer);
            this.Pw1 = nan(nx, nx, nPer);
            this.Pw2 = nan(nx, nx, nPer);
            this.pe = nan(ny, nPer);
            this.y0 = nan(ny, nPer);
            this.y1 = nan(ny, nPer);
            this.y2 = nan(ny, nPer);
            this.Py0 = nan(ny, ny, nPer);
            this.Py1 = nan(ny, ny, nPer);
            this.Py2 = nan(ny, ny, nPer);

            if this.Ahead>0
                n = 1 + this.Ahead;
                this.yy1 = nan(ny, nPer, n);
                this.ww1 = nan(nx, nPer, n);
                this.ee1 = nan(ne, nPer, n);
            end
            
            this.e0 = nan(ne, nPer);
            this.e1 = nan(ne, nPer);
            this.e2 = nan(ne, nPer);
            
            this.ixyy = cell(1, nPer);
            this.K = cell(1, nPer);
            this.ZFZ = cell(1, nPer);
            this.ZFpe = cell(1, nPer);
            this.Fpe = cell(1, nPer);
            this.L = cell(1, nPer);
        end
    end
end
