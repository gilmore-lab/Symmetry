classdef PTB < handle
    %ptb Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        w
        debug
        debugmsg
        verbose
        verbosemsg
        autoclosetex = true
        tex
    end
    
    properties
        whichScreen
        rect
        center_W
        center_H
        black
        white
        gray
        absoluteDifferenceBetweenWhiteAndGray
        fix
    end
    
    methods (Static)
        function [keys] = keyGet
            % Key prep
            KbName('UnifyKeyNames');
            keys.akey = KbName('a'); % Left thumb/index a, b
            keys.bkey = KbName('b');
            keys.ckey = KbName('c'); % Right thumb/index d, c
            keys.dkey = KbName('d');
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
        function obj = PTB(debug,verbose)
            obj.debug = debug;
            obj.verbose = verbose;
            if obj.debug
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
            
            % PPD parameters
            monitorWidth   = 48;   % horizontal dimension of viewable screen (cm)
            viewingDistance      = 60;   % viewing distance (cm)
            
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
            
            % Fixation parameters
            fix.color = {uint8([255, 0, 0]),uint8([0, 255, 0])};
            fix.radius = .15;
            fix.line = 2;
            fix.type = {'FillOval'};
            [ windowCenter(1), windowCenter(2) ] = RectCenter( rect );
            pixelsPerDegree = ( pi / 360 ) * ( rect(3) - rect(1) ) ...
                / atan(   ( monitorWidth / 2 ) / viewingDistance  );     % pixels per degree
            fix.fixationPointCoordinates = [ (  windowCenter - ( fix.radius * pixelsPerDegree )  ) ...
                (  windowCenter + ( fix.radius * pixelsPerDegree )  ) ];
            
            % Data structure for monitor info
            obj.whichScreen = whichScreen;
            obj.center_W = center_W;
            obj.center_H = center_H;
            obj.black = black;
            obj.white = white;
            obj.gray = gray;
            obj.absoluteDifferenceBetweenWhiteAndGray = absoluteDifferenceBetweenWhiteAndGray;
            obj.fix = fix;
            
            %             % Text formatting
            %             Screen('TextSize',monitor.display_window,20);
            %             Screen('TextFont',monitor.display_window,'Helvetica');
            %             Screen('TextStyle',monitor.display_window,0);
        end
        
        function [w] = getWindow(this)
            w = this.w;
        end
        
        function [tex] = getTex(this)
            tex = this.tex;
        end
        
        function setVerboseMsg(this,txt)
            this.verbosemsg = txt;
        end
        
        function txt = getVerboseMsg(this)
            txt = this.verbosemsg;
        end
        
        function [result] = toggleAutoCloseTex(this)
            this.autoclosetex = ~this.autoclosetex;
            result = this.autoclosetex;
        end

        function setdebugtxt(this)
            DrawFormattedText(this.w,['Debug\n' this.debugmsg],'center',[],[255 0 0]);
        end
        
        function setverbosetxt(this)
            DrawFormattedText(this.w,['Verbose\n' this.verbosemsg],[],[],[255 0 0]);
        end
        
        function open(this)
            [this.w, this.rect] = Screen('OpenWindow', this.whichScreen, this.gray); % Open Screen
            if this.debug
                this.debugmsg = 'PTB.open';
            end
            
            this.flip;
        end
                
        function drawtxt(this,txt)
            if this.debug
                this.debugmsg = 'PTB.drawtxt';
            end
            DrawFormattedText(this.w,txt,'center','center',this.black);
            this.flip;
        end
        
        function drawblank(this)
            Screen('FillRect',this.w,this.gray);
            if this.debug
                this.debugmsg = 'PTB.drawblank';
            end
            
            this.flip;
        end
        
        function [secs] = drawimg(this,img,fix_color)
            this.tex = Screen('MakeTexture',this.w,img);
            Screen('DrawTexture',this.w,this.tex);
            if ~isempty(fix_color)
                Screen(this.fix.type{1},this.w,fix_color,this.fix.fixationPointCoordinates);
            end
            if this.debug
                this.debugmsg = 'PTB.drawimg';
            end
            
            [secs] = this.flip;
        end
        
        function [secs] = flip(this)
            % flip
            if this.debug
                this.setdebugtxt;
            end
            if this.verbose
                [secs] = Screen('Flip',this.w,[],1);
                this.setVerboseMsg([this.getVerboseMsg sprintf('%s:%s\n','Flip',num2str(secs))]);
                this.setverbosetxt;
                this.setVerboseMsg([]);
                Screen('Flip',this.w,[],0);
            else
                [secs] = Screen('Flip',this.w);
            end
            
            if this.autoclosetex
                if ~this.closetex
                    fprintf('%s\n','ptb.flip: Issue with auto-closing tex.  Aborting....');
                    this.endPres;
                end
            end
        end
        
        function [result] = closetex(this)
            try
                Screen('close',this.getTex);
                this.tex = [];
                result = true;
            catch me
                disp(me);
                result = false;
            end
        end
        
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

