classdef client < handle
%CLIENT Summary of this function goes here
%   Detailed explanation goes here
    
%     properties (SetAccess = private)
%         debug = false;
%     end
    
    properties
        defaults = {
            'debug',false;...
            'verbose',false;...
            'path','';...
            'input','';
            'inputtype','PGM';
            'output','';
            'id',datestr(now,30);
            'platform',computer;
            'matlab',version;
            'ptb','';
            };
        build = {
            'invoke';...
            'presentation';...
            'segment';...
            'ptb';...
            'paradigm';
            };
        data
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
        function d = listDirectory(path,varargin)
            % Directory list
            % Search path with optional wildcards
            % path = search directory
            % varargin{1} = name filter
            % varargin{2} = extension filter
            
            narginchk(1,3);
            
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
        function this = client(varargin)
            % Set ptb
            [~,ptb] = PsychtoolboxVersion;
            this.set_defaults_value('ptb',regexprep(num2str([ptb.major,ptb.minor,ptb.point]),'\s+','.'));
            
            % Parse arguments
            % One argument expected, cell
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
            for i = 1:size(this.defaults,1)
                if isempty(this.defaults{i,2})
                    ME = this.missingParameter(this.defaults{i,1});
                    throw(ME);
                end
                if this.get_defaults_value('verbose')
                    fprintf('%s...\n',this.defaults{i,1});
                    if ischar(this.defaults{i,2})
                        fprintf('\t%s\n',this.defaults{i,2});
                    else
                        disp(this.defaults{i,2});
                    end
                end
            end
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
        
        function bootstrap(this)
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
            fullpath = fullfile(this.get_defaults_value('path'),this.get_defaults_value('input'));
            this.set_defaults_value('input',fullpath);
            fullpath = fullfile(this.get_defaults_value('path'),this.get_defaults_value('output'));            
            this.set_defaults_value('output',fullpath);
            if this.get_defaults_value('verbose')
                fprintf('%s...\n','input path');
                fprintf('\t%s\n',this.get_defaults_value('input'));
                fprintf('%s...\n','output path');
                fprintf('\t%s\n',this.get_defaults_value('output'));
            end
            
            images = this.get_image_names;
            [this.data,~] = this.load_image_matrix(images);
        end
    end
end

