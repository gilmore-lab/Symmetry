classdef invoke < handle
    %INVOKE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable)
        sequence = cell(0);
        meta = cell(0);        
        iter = 1;
    end
    
    methods
        function obj = invoke() 
        end
        
        function register(this,segment,meta)
            this.sequence{end+1} = segment;
            this.meta{end+1} = meta;
        end
        function execute(this)
            this.sequence{this.iter}.execute();
%             if (mod(this.iter,2))==1
%                 disp('invokeOdd')
%             else
%                 disp('invokeEven')
%             end
            this.iter = this.iter + 1;
%             segment.execute();
        end
        
%         function unittests(this)
%             strcmp('01',cellfun(@(y)(y.group),inv.meta,'UniformOutput',false))'
%         end
    end
    
end