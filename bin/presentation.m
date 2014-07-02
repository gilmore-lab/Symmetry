classdef presentation < handle
    % Presentation interface
    
    properties (SetAccess = protected, GetAccess = protected)
       debug
    end
    
    properties
        IMAGE
        FIX
    end
    
    methods
        function setImage(this,img)
            if (this.debug)
                disp('setImage')
            else
                this.IMAGE = img;
            end
        end
        function img = getImage(this)
            if (this.debug)
                disp('getImage')
                img = [];
            else
                img = this.IMAGE;
            end
        end
        function setFixation(this,fix)
           this.FIX = fix; 
        end
        function FIX = getFixation(this)
           FIX = this.FIX;
        end        
    end

    methods (Abstract)
       execute(obj)
    end
    
end
