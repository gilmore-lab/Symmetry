classdef segment < presentation
    %SEGMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    events
        flip
    end

    methods
        function sobj = segment(img,varargin)
            if ~isempty(varargin)
                sobj.debug = varargin{1};
            end
            sobj.setImage(img);
        end
        
        function execute(this)
            notify(this,'flip');
        end
    end    
end