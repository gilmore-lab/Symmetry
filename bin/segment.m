classdef segment < presentation
    %PRESSEGMENT Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties (GetAccess = private)
%     end
    
%     properties
%     end
        
    methods
        function sobj = segment(img,varargin)
            if ~isempty(varargin)
                sobj.debug = varargin{1};
            end
            sobj.setImage(img)
        end
        
        function execute(obj)
        end
        
        function testExecute(this)
            disp(this.NAME)
            disp('test')
        end
        
    end    
end

