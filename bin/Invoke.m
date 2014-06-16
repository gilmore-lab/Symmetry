classdef Invoke < handle
    %INVOKE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable)
        verbosemsg
        write
    end
    
    properties
        plugin
        sequence = cell(0);
        meta = cell(0);
        iter = 1;
    end
    
    methods
        function obj = Invoke(client,plugin)
            obj.plugin = plugin;
            if isempty(plugin.getWindow)
                fprintf('%s\n','Invoke(): No window initialized.');
            end
            obj.listenToProps(client);
        end
        
        function listenToProps(this,client)
            addlistener(this,'verbosemsg','PostSet',@client.verboseDisplay);
            addlistener(this,'write','PostSet',@client.record);
        end
        
        function listenTo(this,segment)
            addlistener(segment,'go',@this.respond);
        end
        
        function register(this,segment,meta)
            this.sequence{end+1} = segment;
            this.listenTo(segment);
            this.meta{end+1} = meta;
        end
        
        function execute(this)
            this.sequence{this.iter}.execute();
            this.iter = this.iter + 1;
        end
        
        %         function unittests(this)
        %             strcmp('01',cellfun(@(y)(y.group),inv.meta,'UniformOutput',false))'
        %         end
        
        function gate(this)
            % KB press
            KbStrokeWait;
            % Trigger
        end
        
        function respond(this,src,evt)
            msg = sprintf('%s: %s\n%s: %s\n%s: %s\n', ...
                'Name',this.meta{this.iter}.name, ...
                'Group',this.meta{this.iter}.group, ...
                'Image',this.meta{this.iter}.image);
            this.plugin.setVerboseMsg(msg);
            secs = this.plugin.drawimg(src.IMAGE);
            this.verbosemsg = [msg sprintf('%s: %d\n','Onset',secs)];
%             this.write
        end
        
        function stopcbk(this)
            
%             WaitSecs(params.default.individual_duration - .04) % Manual Wait
%             
%             fprintf(fid, '%3.4f,', (stimonset - start_t)); % Onset (Retrospectively)
%             
%             Display picture
%             [~,stimonset] = Screen('Flip', params.display.window);
%             set(t,'UserData',stimonset); % Set UserData
%             
%             Writing data (Retrospectively)
%             fprintf(fid, '%1.f,', pres_cell{stim_ind-1,1}); % Block number
%             fprintf(fid, '%s,', pres_cell{stim_ind-1,2}); % Pattern type
%             fprintf(fid, '%1.f,', pres_cell{(stim_ind-1),4}); % Fixation change
%             fprintf(fid, '%3.4f,', RT); % RT
%             fprintf(fid, '%1.f,', Hit); % Hit
%             
%             if pres_cell{(stim_ind-1), 4} && Hit == 0 % If last was a fixation change, and no Hit was reported
%                 Miss = 1; % Miss is 1
%             end % End if: fix_change(get(t, 'TasksExecuted'))
%             
%             fprintf(fid, '%1.f\n', Miss); % Miss
%             
%             Resetting
%             RT = 0;
%             Hit = 0;
%             Miss = 0;
%             
%             WaitSecs(params.default.individual_duration - .04); % Manual wait
%             
%             Final data write (Retrospectively)
%             fprintf(fid, '%3.4f,', (stimonset - start_t)); % Onset
%             fprintf(fid, '%1.f,', pres_cell{stim_ind,1}); % Block number
%             fprintf(fid, '%s,', pres_cell{stim_ind,2}); % Pattern type
%             fprintf(fid, '%1.f,', pres_cell{(stim_ind-1),4}); % Fixation change
%             fprintf(fid, '%3.4f,', RT); % RT
%             fprintf(fid, '%1.f,', Hit); % Hit
%             
%             if pres_cell{(stim_ind-1), 4} && Hit == 0 % If last was a fixation change, and no Hit was reported
%                 Miss = 1; % Miss is 1
%             end % End if: fix_change(get(t, 'TasksExecuted'))
%             
%             fprintf(fid, '%1.f\n', Miss); % Miss
%             
        end % End stop_callbck(~, ~, fid)
        
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
    end
    
end