classdef Client < handle
    %CLIENT Summary of this function goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        defaults = {
            'debug',false;...
            'verbose',false;...
            'path','';...
            'input','';
            'inputtype','PGM';
            'output','';
            'outputtype','1D';
            'generaloutputname','all';
            'generaloutputtype','csv';
            'io','';
            'writeinterval',60000;
            'staggerinterval',500;
            'id','';
            'platform',computer;
            'matlab',version;
            'ptb','';
            'java',version('-java');
            };
        build = {
            'Invoke';...
            'presentation';...
            'segment';...
            'PTB';...
            'paradigm';
            'simpleui';
            };
        threadManager
    end
        
    properties
        data
        groups
        writeBuffer = {}
        writeCb % Java threads
        csvFid
        mainWriteCb % Matlab thread
        response % Default false
    end
    
    methods (Static)
        function ME = invalidArgumentType(wrong_type,for_argument)
            ME = MException('client:invalidArgumentType', ...
                'Unexpected type, "%s", for argument "%s".', wrong_type,for_argument);
        end
        function ME = unrecognizedArgument(wrong_argument)
            ME = MException('client:unrecognizedArgument', ...
                'Unrecognized argument "%s".', wrong_argument);
        end
        function ME = missingFile(req_file)
            ME = MException('client:missingFile', ...
                'File "%s" not found', req_file);
        end
        function ME = missingParameter(no_param)
            ME = MException('client:missingParameter', ...
                'Parameter, "%s", value empty.', no_param);
        end
        function ME = incorrectFileReference(wrong_path)
            ME = MException('client:incorrectFileReference', ...
                'File path, "%s", is the incorrect reference for this build.', wrong_path);
        end
        function ME = errorFileOpen(bad_path)
            ME = MException('client:errorFileOpen', ...
                'File, "%s", could not be opened.', bad_path);
        end        
        
        function d = listDirectory(path,varargin)
            % Directory list
            % Search path with optional wildcards
            % path = search directory
            % varargin{1} = name filter
            % varargin{2} = extension filter
            
            narginchk(1,3); % R2011b
            
            name = [];ext = [];exclude = '[]';
            
            vin = size(varargin,2);
            
            if vin==1
                name = varargin{1};
            elseif vin==2
                name = varargin{1};
                ext = varargin{2};
            elseif vin==3
                name = varargin{1};
                ext = varargin{2};
                exclude = varargin{3};
            end
            
            if ismac
                if vin == 0
                    [~,d] = system(['ls ' path ' | xargs -n1 basename']);
                elseif vin == 1
                    [~,d] = system(['ls ' path filesep '*' name '* | xargs -n1 basename']);
                elseif vin == 2
                    [~,d] = system(['ls ' path filesep '*' name '*' ext ' | xargs -n1 basename']);
                end
            elseif ispc
                [~,d] = system(['dir /b "' path '"' filesep '*' name '*' ext ' | findstr /vi ".' exclude '"']);
            else
                error('client (listDirectory): Unsupported OS.');
            end
        end
        
        function d = parseListing(list)
            % Parse directory listing
            % Only tested on PC
            if ispc
                d = regexp(list(1:end-1),'\n','split');
                if strcmp(d,'File Not Found')
                    d = [];
                end
            else
                error('client (parseListing): Unsupported OS.');
            end
        end
    end
    
    methods
        function this = Client(varargin)
            % Set ptb
            [~,ptb] = PsychtoolboxVersion;
            this.set_defaults_value('ptb',regexprep(num2str([ptb.major,ptb.minor,ptb.point]),'\s+','.'));
            
            % Parse arguments
            % One argument expected, type cell
            if nargin == 1
                flags = varargin{1};
                if ~isempty(flags)
                    for i = 1:size(flags,1)
                        if any(strcmp(flags{i,1},this.defaults(:,1)))
                            if strcmp(class(this.defaults{i,2}),class(flags{i,2}))
                                set_defaults_value(this,flags{i,1},flags{i,2});
                                %                                 this.defaults{strcmp(flags{i,1},this.defaults(:,1)),2} = flags{i,2};
                            else
                                ME = this.invalidArgumentType(class(flags{i,2}),this.defaults{i,1});
                                throw(ME);
                            end
                        else
                            ME = this.unrecognizedArgument(flags{i,1});
                            throw(ME);
                        end
                    end
                end
            end
            
            % Verify arguments
            if this.get_defaults_value('verbose')
                for i = 1:size(this.defaults,1)
                    fprintf('%s...\n',this.defaults{i,1});
                    if ischar(this.defaults{i,2})
                        fprintf('\t%s\n',this.defaults{i,2});
                    else
                        disp(this.defaults{i,2});
                    end
                end
            end
        end
        
        function bootstrap(this)
            % Random seed
            rng('shuffle'); % R2011b
            
            % Assert file existence and validity
            for i = 1:size(this.build,1)
                if isempty(which(this.build{i}))
                    ME = this.missingFile(this.build{i});
                    throw(ME);
                end
                if ~regexp(which(this.build{i}),regexprep(this.defaults{3,2},'\','\\\'))
                    ME = this.incorrectFileReference(which(this.build{i}));
                    throw(ME);
                end
            end
            
            % Path construction
            if isempty(this.get_defaults_value('path'))
                ME = this.missingParameter(this.get_defaults_value('path'));
                throw(ME);
            end
                
            fullpath = fullfile(this.get_defaults_value('path'),this.get_defaults_value('input'));
            this.set_defaults_value('input',fullpath);
            fullpath = fullfile(this.get_defaults_value('path'),this.get_defaults_value('output'));
            this.set_defaults_value('output',fullpath);
            fullpath = fullfile(this.get_defaults_value('path'),this.get_defaults_value('io'));
            this.set_defaults_value('io',fullpath);
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','input path');
                fprintf('\t%s\n',this.get_defaults_value('input'));
                fprintf('%s...\n','output path');
                fprintf('\t%s\n',this.get_defaults_value('output'));
                fprintf('%s...\n','io path');
                fprintf('\t%s\n',this.get_defaults_value('io'));
            end
            
            % Media
            images = this.get_image_names;
            [this.data,~] = this.load_image_matrix(images);
            
            % I/O
            javaaddpath(this.get_defaults_value('io'));
            import threadio.*
            
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','Added IO path');
                fprintf('\t%s\n',this.get_defaults_value('io'));
                fprintf('%s...\n','Imported "threadio" package');
            end
            
            this.setUpIOThreads;
        end
        
        function value = get_defaults_value(this,key)
            % Return by key
            value = this.defaults{strcmp(this.defaults(:,1),key),2};
        end
        
        function set_defaults_value(this,key,value)
            % Set value by key
            this.defaults{strcmp(this.defaults(:,1),key),2} = value;
        end
        
        function [d,n] = get_image_names(this)
            % List image names
            d = this.listDirectory(this.get_defaults_value('input'),this.get_defaults_value('inputtype'));
            d = this.parseListing(d);
            n = length(d);
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','number of valid input file contents');
                fprintf('\t%d\n',n);
            end
            % Input verification
            if this.get_defaults_value('debug')
                assert(~(n==0),'Image directory listing has 0 results!');
            end
        end
        
        function [img,n] = load_image_matrix(this,d)
            % Load images into image matrix
            img = cell([size(d,1) 1]);
            for i = 1:length(d)
                try
                    img{i} = imread(fullfile(this.get_defaults_value('input'),d{i}),this.get_defaults_value('inputtype'));
                    if this.get_defaults_value('verbose')
                        fprintf('%s...\n','loading');
                        fprintf('\t%s\n',d{i});
                    end
                catch ME
                    throw(ME)
                end
            end
            n = length(find(~cellfun(@isempty,img)));
            
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','number of images loaded');
                fprintf('\t%d\n',n);
            end
        end
                
        function setUpIOThreads(this)
            this.threadManager = threadio.ProcessThreadManager;
%             rd = ReadData;
%             this.threadManager.addProcess(rd);
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','Initialized ProcessThreadManager');
            end
        end
        
        function cleanUpIO(this)
            this.writeBuffer = {};
            this.threadManager.removeAll();
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','Threads cleaned');
            end
        end
        
        function setUpOutputStream(this,file)
            this.writeBuffer(end+1) = {threadio.WriteData(this.get_defaults_value('writeinterval'))};
            this.threadManager.storeProcess(this.writeBuffer{end});
            fullpath = fullfile(this.get_defaults_value('output'),[file '.' this.get_defaults_value('outputtype')]);
            javaMethodEDT('openBufferedOutputStream',this.writeBuffer{end},fullpath)
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','Added write buffer to index');
                fprintf('\t%d\n',length(this.writeBuffer));
                fprintf('%s...\n','Opened data stream for file');
                fprintf('\t%s\n',fullpath);
            end
        end
        
        function startThreads(this)
            javaMethodEDT('startAll',this.threadManager,this.get_defaults_value('staggerinterval'));
        end
        
        function stopThreads(this)
            javaMethodEDT('stopAll',this.threadManager);
        end
        
        function mainCloseFileCb(this)
            fclose(this.csvFid);
        end
        
        function verboseDisplay(this,src,evt)
            if this.get_defaults_value('verbose')
                disp('------')
                fprintf(evt.AffectedObject.verbosemsg);
                disp('------')
            end
        end
        
        function write(this,src,evt)
            meta = evt.AffectedObject.write{1};
            t = evt.AffectedObject.write{2};
            if this.response
                resp = 1;
            else
                resp = 0;
            end
            this.response = false;
            
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','Client callback, group');
                fprintf('\t%s\n',meta.group);
                fprintf('%s...\n','Client callback, time');
                fprintf('\t%d\n',t);
                if meta.fix_chng
                    fprintf('%s...\n','Client callback, fixation change');
                end
                fprintf('%s...\n','Client callback, response');
                fprintf('\t%d\n',resp);
            end
            this.writeCb(meta.group,t);
            this.mainWriteCb(meta.cname,meta.image,meta.group,meta.phase,t,meta.fix_chng,resp);            
        end
        
        function debugCb(this,src,evt)
            meta = evt.AffectedObject.write{1};
            t = evt.AffectedObject.write{2};
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','Client callback, group');
                fprintf('\t%s\n',meta.group);
                fprintf('%s...\n','Client callback, time');
                fprintf('\t%d\n',t);
            end
            this.writeCb(meta.group,t);
            this.mainWriteCb(meta.cname,meta.image,meta.group,meta.phase,t);
        end
    end
end