classdef segment < presentation
    %PRESSEGMENT Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties (GetAccess = private)
%     end
    
    properties
        PATH
        NAME
        IMAGE
        FIX
    end
        
    methods
        function sobj = segment(name,path,varargin)
            if ~isempty(varargin)
                sobj.debug = varargin{1};
            end
            sobj.setName(name)
        end
            
        function startup(this)
            path = fullfile(this.PATH,this.NAME,['.' this.IMAGETYPE]);
            this.readImage(path);
        end
        
        function execute(obj)
        end
        
        function testExecute(this)
            disp(this.NAME)
            disp('test')
        end
        
    end    
end

