classdef presentation < handle
       % Presentation object
    
    properties (SetAccess = protected, GetAccess = protected)
       IMAGETYPE = 'pgm'
       debug
%         fix_color = {uint8([255, 0, 0]),uint8([0, 255, 0])};
%         fix_radius = 5;
%         fix_line = 2;
%         fix_p_chg = .7;
%         fix_type = {'FillOval'};
    end
    
    properties
        
    end
    
%     methods (Static)
%         % mkimg
%         % Arguments: Screen window, picture matrix
%         % Output: Texture handle
%         function [tex] = mkimg(w,pic)
%             tex = Screen('MakeTexture',w,pic);
%             Screen('DrawTexture',w,tex);
%         end
%         
%         % screenflip
%         % Arguments: Screen window, picture matrix
%         % Output: Texture handle
%         function [secs] = screenflip(w)
%             [secs] = Screen('Flip',w);
%         end
%         
%         % Closetex
%         % Arguments: Texture handle
%         % Output: Texture handle
%         function [result] = closetex(tex)
%             try
%                 Screen('close',tex);
%                 result = 0;
%             catch me
%                 disp(me);
%                 result = 1;
%             end
%         end
% %         
% %         %% Fixshow
% %         % Arguments: Monitor data structure
% %         function fixshow(monitor)
% % %             x_offset = 7;
% % %             y_offset = 25;
% % %             xy_offset = [x_offset y_offset];
% %             Screen('DrawLine',monitor.w,monitor.black,(monitor.center_W-20)-xy_offset(1),monitor.center_H-xy_offset(2),(monitor.center_W+20)-xy_offset(1),monitor.center_H-xy_offset(2),7);
% %             Screen('DrawLine',monitor.w,monitor.black,monitor.center_W-xy_offset(1),(monitor.center_H-20)-xy_offset(2),monitor.center_W-xy_offset(1),(monitor.center_H+20)-xy_offset(2),7);
% %             Screen('Flip',monitor.w);
% %         end
% %         
%     end
    methods
        function setName(this,name)
            if (this.debug)
                disp('setName')
            else
                this.NAME = name;
            end
        end
        function name = getName(this)
            if (this.debug)
                disp('getName')
                name = [];
            else
                name = this.NAME;
            end
        end        
        function setImage(this,img)
            if (this.debug)
                disp('setImage')
            else
                this.IMAGE = img;
            end
        end
    end

    methods (Abstract)
       startup(obj)
       execute(obj)
    end
    
end
