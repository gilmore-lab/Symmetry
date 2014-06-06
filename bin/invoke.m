classdef invoke < handle
    %INVOKE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable)
        sequence = cell([1,1]);
        iter = 1;
    end
    
    methods
        function obj = invoke() 
        end
        
        function startup(this,segment)
            this.sequence{end+1} = segment;
            segment.startup();
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
    end
    
end

