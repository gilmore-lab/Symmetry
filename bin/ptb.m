classdef ptb < handle
    %ptb Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        whichScreen
        rect
        center_W
        center_H
        black
        white
        gray
        absoluteDifferenceBetweenWhiteAndGray
        w
        tex
    end
    
    methods (Static)
        function [keys] = keyGet
            % Key prep
            KbName('UnifyKeyNames');
            keys.akey = KbName('a');
            keys.tkey = KbName('t');
            keys.esckey = KbName('Escape');
            keys.spacekey = KbName('SPACE');
        end
                
        function initPres
            % initPres
            ListenChar(2);
            HideCursor;
            if ispc
                try
                    ShowHideFullWinTaskbarMex(0);
                catch ME
                    ShowHideWinTaskbarMex(0);
                end
            end
        end
        
        function endPres
            % EndPres
            ListenChar(0);
            ShowCursor;
            if ispc
                try
                    ShowHideFullWinTaskbarMex(1);
                catch ME
                    ShowHideWinTaskbarMex(1);
                end
            end
            
            % Close all screens
            Screen('CloseAll');
        end 
    end
    
    methods
        function obj = ptb(debug)
            if debug
                % Find out how many screens and use largest screen number (desktop, dev extended monitor screen).
                whichScreen = max(Screen('Screens'));
            else
                % Find out how many screens and use lowest screen number (entire screen).
                whichScreen = min(Screen('Screens'));
            end
            
            % Rect for screen
            rect = Screen('Rect', whichScreen);
            
            % Screen center calculations
            center_W = rect(3)/2;
            center_H = rect(4)/2;
            
            % ---------- Color Setup ----------
            % Gets color values.
            
            % Retrieves color codes for black and white and gray.
            black = BlackIndex(whichScreen);  % Retrieves the CLUT color code for black.
            white = WhiteIndex(whichScreen);  % Retrieves the CLUT color code for white.
            
            gray = (black + white) / 2;  % Computes the CLUT color code for gray.
            if round(gray)==white
                gray=black;
            end
            
            % Taking the absolute value of the difference between white and gray will
            % help keep the grating consistent regardless of whether the CLUT color
            % code for white is less or greater than the CLUT color code for black.
            absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
            
            % Data structure for monitor info
            obj.whichScreen = whichScreen;
            obj.center_W = center_W;
            obj.center_H = center_H;
            obj.black = black;
            obj.white = white;
            obj.gray = gray;
            obj.absoluteDifferenceBetweenWhiteAndGray = absoluteDifferenceBetweenWhiteAndGray;
            
            %             % Text formatting
            %             Screen('TextSize',monitor.display_window,20);
            %             Screen('TextFont',monitor.display_window,'Helvetica');
            %             Screen('TextStyle',monitor.display_window,0);
        end
        
        function open(this)
            [this.w, this.rect] = Screen('OpenWindow', this.whichScreen, this.gray); % Open Screen
        end
        
        function blank(this)
            Screen('FillRect',this.w,this.gray);
            Screen('Flip',this.w);
        end
        
        function [secs] = screenflip(this)
            % screenflip
            [secs] = Screen('Flip',this.w);
        end
        
        function mkimg(this,img)
            % mkimg
            this.tex = Screen('MakeTexture',this.w,img);
            Screen('DrawTexture',this.w,this.tex);
        end
        
        function [result] = closetex(this)
            % Closetex
            try
                Screen('close',this.tex);
                result = 0;
            catch me
                disp(me);
                result = 1;
            end
        end
        
        function [w] = get_window(this)
           w = this.w; 
        end
        
        function [tex] = get_tex(this)
           tex = this.tex; 
        end
%         
%         %% Fixshow
%         % Arguments: Monitor data structure
%         function fixshow(monitor)
% %             x_offset = 7;
% %             y_offset = 25;
% %             xy_offset = [x_offset y_offset];
%             Screen('DrawLine',monitor.w,monitor.black,(monitor.center_W-20)-xy_offset(1),monitor.center_H-xy_offset(2),(monitor.center_W+20)-xy_offset(1),monitor.center_H-xy_offset(2),7);
%             Screen('DrawLine',monitor.w,monitor.black,monitor.center_W-xy_offset(1),(monitor.center_H-20)-xy_offset(2),monitor.center_W-xy_offset(1),(monitor.center_H+20)-xy_offset(2),7);
%             Screen('Flip',monitor.w);
%         end
    end
    
end

