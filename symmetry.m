function [routine] = symmetry

p = mfilename('fullpath');
[p,~,~] = fileparts(p);

% Bin
bin = [p filesep 'bin'];
addpath(bin);

flags = {
    'debug',true;
    'verbose',true;
    'path',p;
    'input','stim';
    'output','data';
    };

client = Client(flags);
client.bootstrap;

plugin = PTB(client.get_defaults_value('debug'),client.get_defaults_value('verbose'));
plugin.open;

[t,kill,routine] = paradigm(client,plugin);

plugin.initPres;

start(t)

pause(1) % temp
while strcmp('on', get(t,'Running')) % While timer is running
    
    [keyIsDown, ~, ~] = KbCheck;
    
    if keyIsDown
        kill(t)
        break;
    end
    
end

plugin.endPres;

% % Initializing
% stimonset = [];

% % Task
% RT = 0;
% Hit = 0;
% Miss = 0;

% % Calculating pixelsPerDegree
% monitorWidth   = 48;   % horizontal dimension of viewable screen (cm)
% viewingDistance      = 60;   % viewing distance (cm)
%
% % Fixation setup
% fixationPointRadius = 0.15;
% [ windowCenter(1), windowCenter(2) ] = RectCenter( windowRectangle );
% pixelsPerDegree = ( pi / 360 ) * ( windowRectangle(3) - windowRectangle(1) ) ...
%                     / atan(   ( monitorWidth / 2 ) / viewingDistance  );     % pixels per degree
% params.display.fixationPointCoordinates = [ (  windowCenter - ( fixationPointRadius * pixelsPerDegree )  ) ...
%                 (  windowCenter + ( fixationPointRadius * pixelsPerDegree )  ) ];

%
%    % Show ready screen, wait for keypress to start
%    Screen('FillRect', windowPointer, params.display.gray);
%    DrawFormattedText(params.display.window, 'Waiting for Scanner Operator.', 'center', 'center', params.display.black );
%    Screen( 'Flip', params.display.window  );
%
%    KbStrokeWait;
%
%    Screen(  'FillRect', windowPointer, params.display.gray  );
%    DrawFormattedText(params.display.window, 'Pressed!', 'center', 'center', params.display.black );
%    Screen( 'Flip', params.display.window  );
%
%    % Preparing first display
%    tex_ptr = Screen('MakeTexture', params.display.window, pres_cell{stim_ind,3});
%    Screen('DrawTexture', params.display.window, tex_ptr);
%    Screen( params.default.fix_type{1} , params.display.window, pres_cell{stim_ind,5}, params.display.fixationPointCoordinates );
%
%    WaitSecs(4.75); % Waiting 4.75 seconds
%
% end % End if: useMCC_Flag

% start_t = GetSecs; % Start time
% start(t);
%
% while strcmp('on', get(t,'Running')) % While timer is running
%
%     [keyIsDown, sec, keyCode] = KbCheck;
%
%     if keyIsDown
%         if keyCode(escapeKey)
%
%             stop(t)
%             disp('User Cancelled')
%
%         elseif keyCode(cKey)
%
%             RT =  sec - get(t,'UserData');
%
%             % If there was a change at this task (Hit)
%             if pres_cell{get(t,'TasksExecuted') + 1, 4} % Accounting for initial flip
%                 Hit = 1;
%             end % End if: pres_cell{stimind, 4}
%
%             KbReleaseWait; % Wait for release
%
%         end % End if: keyCode(escapeKey)
%     end % End if: keyIsDown
%
% end % End while: strcmp('on', get(t, 'Running'))

end % End primary function