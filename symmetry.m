% function symmetry

%% Directory initialization
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

Client = client(flags);
Client.bootstrap;

PTBObj = ptb;

% t = paradigm();

% start(t)

% delete(timerfindall)
% clear all
% PsychJavaTrouble;

%% Cell 1: Start up
% params = param_setup; % Calling parameters
% 
% % Presentation cell
% pres_length = params.default.duration * params.expt.n_blocks; % 12 * 10 = 120 presentations
% 
% pres_cell = cell([pres_length 6]); % Preallocating
% stim_ind = 1;
% pres_ind = 1; % Starting index
% 
% flag12 = randi(2);
% fix_col = params.default.fix_color{flag12}; % Starting color
% 
% % For each block
% for i = 1:params.expt.n_blocks
%     
%     % For each element
%     for ii = 1:params.expt.block(i).n_elements(1)
%         
%         % Each pattern
%         pres_cell{pres_ind,1} = i; % Column 1: Block Number
%         pres_cell{pres_ind,2} = params.expt.block(i).pattern(1).p_type{ii}; % Column 2: Pattern type
%         pres_cell{pres_ind,3} = params.expt.block(i).pattern(1).img{ii}; % Column 3: Image matrix
%         pres_cell{pres_ind,4} = params.expt.block(i).pattern(1).fix(ii).change; % Column 4: Fixation change
%         
%         if params.expt.block(i).pattern(1).fix(ii).change % If change
%             flag12 = find([1 2] ~= flag12); % Switch index
%             fix_col = params.default.fix_color{flag12}; % New fix_col         
%         end % End if: params.expt.block(i).pattern(1).fix(ii).change
%         
%         pres_cell{pres_ind,5} = fix_col; % Column 5: Fixation color
%         pres_cell{pres_ind,6} = 'pattern'; % Column 6: Function string
%         pres_ind = pres_ind + 1; % Next index
%         
%     end % End: ii = 1:params.expt.block(i).n_elements(1)
%     
%     % For each element
%     for ii = 1:params.expt.block(i).n_elements(2)
%         
%         % Each blank
%         pres_cell{pres_ind,1} = i;
%         pres_cell{pres_ind,2} = params.expt.block(i).pattern(2).p_type{ii};
%         pres_cell{pres_ind,3} = {[]}; % Empty cell
%         pres_cell{pres_ind,4} = params.expt.block(i).pattern(2).fix(ii).change;
%         
%         if params.expt.block(i).pattern(1).fix(ii).change;
%             flag12 = find([1 2] ~= flag12);
%             fix_col = params.default.fix_color{flag12};  
%         end
%         
%         pres_cell{pres_ind,5} = fix_col;
%         pres_cell{pres_ind,6} = 'blank';
%         pres_ind = pres_ind + 1;
%     
%     end % End: ii = 1:params.expt.block(i).n_elements(2)
%     
% %     % For each off phase presentation
% %     for iii = 1:params.default.offpres
% %         
% %         pres_cell{pres_ind,1} = i;
% %         pres_cell{pres_ind,2} = 'none';
% %         pres_cell{pres_ind,3} = params.expt.block(i).offphase.img{iii};
% %         pres_cell{pres_ind,4} = params.expt.block(i).offphase.color{iii};
% %         pres_ind = pres_ind + 1;
% %         
% %     end % End for: iii = 1:params.default.offpres
%         
% end % End for: i = 1:params.expt.n_blocks

% % Initializing
% global tex_ptr
% stimonset = [];

% % Ask for auto-trigger
% useMCC_Flag = questdlg('Use trigger from scanner?'); 
% 
% switch useMCC_Flag
%     case 'Yes'
%         useMCC_Flag = 1;
%         
%         % Check OS
%         if ispc
%             % Initiate MCC_dio
%             MCC_dio = digitalio( 'mcc' ,'0' );
%             addline( MCC_dio, 0, 0, 'in' );
%             start( MCC_dio );
%         else ismac
%             daq = DaqFind;
%         end
%         
%     case 'No'
%         
%         useMCC_Flag = 0;
%         
%     case 'Cancel'
%         return;
% end % End switch

% % UI entry 
% prompt1 = {'Subject ID (YYMMDDffll):', 'Date (YYMMDD):'};
% dlg_title1 = 'Fill out Subject Information';    
% num_lines1 = 1;
% def1 = {'', datestr(now, 'yymmdd')}; % # of Defs = # prompt fields
% options.Resize = 'on';
% subjout = inputdlg(prompt1, dlg_title1, num_lines1, def1, options);

% % Subject data
% subj_id = subjout{1}; 
% subj_date = subjout{2};
% subj_str = [subj_id '_' subj_date];

% % Output setup
% filename = [file_dir filesep 'data' filesep subj_str '.csv'];
% fid = fopen(filename, 'a');
% 
% % Headers
% fprintf(fid, '%s,', 'Time(s)');
% fprintf(fid, '%s,', 'Block');
% fprintf(fid, '%s,', 'Display');
% fprintf(fid, '%s,', 'FixationChange');
% fprintf(fid, '%s,', 'RT');
% fprintf(fid, '%s,', 'Hit');
% fprintf(fid, '%s\n', 'Miss');
% 
% % Initializing
% RT = 0;
% Hit = 0;
% Miss = 0;
    
% % Function handle setup
% function pattern
%     Screen('Close', tex_ptr) % Close last tex_ptr
%     tex_ptr = Screen('MakeTexture', params.display.window, pres_cell{stim_ind,3});
%     Screen('DrawTexture', params.display.window, tex_ptr);
%     Screen( params.default.fix_type{1}, params.display.window, pres_cell{stim_ind,5}, params.display.fixationPointCoordinates );
% end
% function blank
%     Screen(  'FillRect', params.display.window, params.display.gray  );
%     Screen( params.default.fix_type{1}, params.display.window, pres_cell{stim_ind,5}, params.display.fixationPointCoordinates );
% end
% 
% % Timer setup
% t = timer;
% set(t, 'Name', 'PresentationTimer', 'ExecutionMode', 'fixedRate', 'Period', params.default.individual_duration, ...
%     'StartFcn', @start_callbck, 'TimerFcn', {@timer_callbck, fid}, 'StopFcn', {@stop_callbck, fid}, ...
%     'ErrorFcn', @err_callbck, 'TasksToExecute', (length(pres_cell) - 2), 'UserData', stimonset, 'StartDelay', params.default.individual_duration);
%     function start_callbck(~, ~)
%      
%         % Initial flip
%         [~,stimonset] = Screen('Flip', params.display.window);
%         set(t,'UserData',stimonset); % Set UserData
%         
%         stim_ind = stim_ind + 1;
% 
%         % Preparing second presentation
% %         tex_ptr = Screen('MakeTexture', params.display.window, pres_cell{stim_ind,3});
% %         Screen('DrawTexture', params.display.window, tex_ptr);
% %         Screen( params.default.fix_type{1} , params.display.window, pres_cell{stim_ind,4}, params.display.fixationPointCoordinates );
% %         fh_array{stim_ind}(stim_ind);
%         eval([pres_cell{stim_ind,6} ';'])
%         
%     end % End start_callbck(obj, event)
% 
%     function timer_callbck(~, ~, fid)
%         
%         fprintf(fid, '%3.4f,', (stimonset - start_t)); % Onset (Retrospectively)
%         
%         % Display picture
%         [~,stimonset] = Screen('Flip', params.display.window);
%         set(t,'UserData',stimonset); % Set UserData
%         
%         % Writing data (Retrospectively)
%         fprintf(fid, '%1.f,', pres_cell{stim_ind-1,1}); % Block number
%         fprintf(fid, '%s,', pres_cell{stim_ind-1,2}); % Pattern type
%         fprintf(fid, '%1.f,', pres_cell{(stim_ind-1),4}); % Fixation change
%         fprintf(fid, '%3.4f,', RT); % RT
%         fprintf(fid, '%1.f,', Hit); % Hit
%         
%         if pres_cell{(stim_ind-1), 4} && Hit == 0 % If last was a fixation change, and no Hit was reported
%                 Miss = 1; % Miss is 1
%         end % End if: fix_change(get(t, 'TasksExecuted')) 
%         
%         fprintf(fid, '%1.f\n', Miss); % Miss
%         
%         % Resetting
%         RT = 0;
%         Hit = 0;
%         Miss = 0;
%         
%         stim_ind = stim_ind + 1;
%         
%         % Prepare next presentation
% %         tex_ptr = Screen('MakeTexture', params.display.window, pres_cell{stim_ind,3});
% %         Screen('DrawTexture', params.display.window, tex_ptr);
% %         Screen( params.default.fix_type{1} , params.display.window, pres_cell{stim_ind,4}, params.display.fixationPointCoordinates );
%         
% %         fh_array{stim_ind}(stim_ind);    
%         eval([pres_cell{stim_ind,6} ';'])
%           
%     end % End timer_callbck(obj, event)
% 
%     function err_callbck(~,~)
%         
%         %disp(event.Data.Message)
%         stop(t)
% 
%         % Close all screens
%         Screen('CloseAll');
% 
%         % Restores the mouse cursor.
%         ShowCursor;
%         ListenChar(0);
% 
%         % Restore preferences
%         Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%         Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
% 
%         if( useMCC_Flag )
%             if ispc
%                 stop( MCC_dio );
%                 delete( MCC_dio )
%                 clear MCC_dio 
%             end
%         end % END - if( useMCC_Flag )
% 
%         fclose('all');
% 
%     end % End err_callbck(~,~)
% 
%     function stop_callbck(~, ~, fid)
%         
%         WaitSecs(params.default.individual_duration - .04) % Manual Wait
%         
%         fprintf(fid, '%3.4f,', (stimonset - start_t)); % Onset (Retrospectively)
%         
%         % Display picture
%         [~,stimonset] = Screen('Flip', params.display.window);
%         set(t,'UserData',stimonset); % Set UserData
%         
%         % Writing data (Retrospectively)
%         fprintf(fid, '%1.f,', pres_cell{stim_ind-1,1}); % Block number
%         fprintf(fid, '%s,', pres_cell{stim_ind-1,2}); % Pattern type
%         fprintf(fid, '%1.f,', pres_cell{(stim_ind-1),4}); % Fixation change
%         fprintf(fid, '%3.4f,', RT); % RT
%         fprintf(fid, '%1.f,', Hit); % Hit
%         
%         if pres_cell{(stim_ind-1), 4} && Hit == 0 % If last was a fixation change, and no Hit was reported
%             Miss = 1; % Miss is 1
%         end % End if: fix_change(get(t, 'TasksExecuted'))
%         
%         fprintf(fid, '%1.f\n', Miss); % Miss
%         
%         % Resetting
%         RT = 0;
%         Hit = 0;
%         Miss = 0;
%         
%         WaitSecs(params.default.individual_duration - .04); % Manual wait
%         
%         % Final data write (Retrospectively)
%         fprintf(fid, '%3.4f,', (stimonset - start_t)); % Onset
%         fprintf(fid, '%1.f,', pres_cell{stim_ind,1}); % Block number
%         fprintf(fid, '%s,', pres_cell{stim_ind,2}); % Pattern type
%         fprintf(fid, '%1.f,', pres_cell{(stim_ind-1),4}); % Fixation change
%         fprintf(fid, '%3.4f,', RT); % RT
%         fprintf(fid, '%1.f,', Hit); % Hit
%         
%         if pres_cell{(stim_ind-1), 4} && Hit == 0 % If last was a fixation change, and no Hit was reported
%             Miss = 1; % Miss is 1
%         end % End if: fix_change(get(t, 'TasksExecuted'))
%         
%         fprintf(fid, '%1.f\n', Miss); % Miss
%         
%         %stop(t) % Stop timer
%         
%         % Close all screens
%         Screen('CloseAll');
% 
%         % Restores the mouse cursor.
%         ShowCursor;
% 
%         % Restore preferences
%         Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%         Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
% 
%         if( useMCC_Flag )
%             if ispc
%                 stop( MCC_dio );
%                 delete( MCC_dio )
%                 clear MCC_dio 
%             end
%         end % END - if( useMCC_Flag )
%         
%         fclose('all');
%         
%     end % End stop_callbck(~, ~, fid)

%% Cell 1 end
% 
% 
% % ---------- Window Setup ----------
% oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
% oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
% 
% whichScreen = params.display.screenNumber;
% [windowPointer, windowRectangle] = Screen( 'OpenWindow', whichScreen, params.display.gray );
% params.display.window = windowPointer;
% 
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
% % Keyboard setup
% KbName( 'UnifyKeyNames' );
% escapeKey = KbName('ESCAPE');
% cKey = KbName('c');
% 
% HideCursor;
% ListenChar(2);
% ShowHideWinTaskbarMex(0);
% 
% if useMCC_Flag
%     
% 	% Show ready screen, wait for trigger
% 	Screen('FillRect', windowPointer, params.display.gray);
% 	DrawFormattedText(params.display.window, 'Waiting for trigger.', 'center', 'center', params.display.black );
% 	Screen( 'Flip', params.display.window  );
% 
%     % Preparing first display
%     tex_ptr = Screen('MakeTexture', params.display.window, pres_cell{stim_ind,3});
%     Screen('DrawTexture', params.display.window, tex_ptr);
%     Screen( params.default.fix_type{1} , params.display.window, pres_cell{stim_ind,5}, params.display.fixationPointCoordinates );
%     
%     % Checking operating system
%     if ispc
%         while ~getvalue(MCC_dio)
%         end
%     elseif ismac
%         while DaqDIn(daq,1) == 254
%         end
%     end
%     
% else
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
% 
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
% 
% ShowHideWinTaskbarMex(1);
% ListenChar(0);
% delete(t);

% end % End primary function