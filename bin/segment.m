classdef segment < presentation
    %SEGMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    events
        go
    end

    methods
        function sobj = segment(img,fix,varargin)
            if ~isempty(varargin)
                sobj.debug = varargin{1};
            end
            sobj.setImage(img);
            sobj.setFixation(fix);
        end
        
        function execute(this)
            notify(this,'go');
        end
    end    
end