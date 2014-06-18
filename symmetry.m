function [routine] = symmetry

p = mfilename('fullpath');
[p,~,~] = fileparts(p);

% Bin
bin = [p filesep 'bin'];
addpath(bin);

flags = {
    'debug',false;
    'verbose',true;
    'path',p;
    'input','stim';
    'output','data';
    'io','io';    
    };

client = Client(flags);
client.bootstrap;

% plugin = PTB(client.get_defaults_value('debug'),client.get_defaults_value('verbose'));
plugin = PTB(~client.get_defaults_value('debug'),client.get_defaults_value('verbose'));
KbName('UnifyKeyNames');
        
if client.get_defaults_value('debug')
    [~,~,~,~,debug_exec] = paradigm(client,plugin);
    client.startThreads;
    debug_exec();
    client.stopThreads;
    client.cleanUpIO;
else
    
    [t,kill,setOutput,exp,routine] = paradigm(client,plugin);
    abort = 0;
    keys = plugin.keyGet;
    plugin.initPres;
    
    % Loop runs
    for i = 1:exp.run
        
        setOutput(int2str(i));
        
        plugin.drawtxt('Preparing experiment. Please wait.');
        client.startThreads;
        
        if client.get_defaults_value('verbose')
            fprintf('%s...\n','Run index');
            fprintf('\t%d\n',i);
            fprintf('%s.\n','Ready');
        end
        
        % Experimenter press
        plugin.drawtxt('Experimenter press spacebar.');
        RestrictKeysForKbCheck(keys.spacekey);
        KbStrokeWait;
        % Trigger
        plugin.drawtxt('Waiting for trigger');
        RestrictKeysForKbCheck(keys.tkey);
        KbStrokeWait;
        
        RestrictKeysForKbCheck([keys.esckey keys.akey]);
        
        start(t);
        
        while strcmp('on', get(t,'Running')) % While timer is running
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                if find(keyCode)==keys.esckey
                    kill(t);
                    abort = 1;
                    break;
                end
            end
        end
        
        client.stopThreads;
        client.cleanUpIO;
        
        if abort
            break;
        end
        
        RestrictKeysForKbCheck([]);
    end
    delete(t);
    plugin.endPres;
end

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