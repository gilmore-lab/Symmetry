function params = param_setup

%   function params = symmetry_jps_5( temp_1 )
% blockTimingFlag = 1 => square, blank, super_square, blank - 6 sec duration
% blockTimingFlag = 1 => square, super_square - 6 sec duration
% blockTimingFlag = 1 => square, blank, super_square, blank - 12 sec
% duration
% blockTimingFlag = 1 => square, super_square - 12 sec duration

% Adapted from code originally developed by Tony Norcia based on
% Stability results for steady, spatially periodic planforms
% Benoit Dionne?, Mary Silber? and Anne C Skeldon, 1997, Nonlinearity
%

%-------------------------------------------------------------------------
% History
% xx-aug-09 rog adapted code from AMN.
% 10-feb-10 rog reparameterized gratings using more conventional
%               parameters.
% 01-apr-10 rog consolidated w/ data structures
% 02-apr-10 rog added new "change 1 component" random mode and
%           symmetric/random mode; Also added feature to export images.
% 06-mar-12 krh Added offphase to block structure.

%-------------------------------------------------------------------------
% params : data structure for whole study
%   display : structure for display-related values
%   control : structure for control/status related values
%   expt    : structure for experiment/stimulus values

%       Experiments have blocks, and eventually user info, etc.
%
%       block : structure for block info; block(i) indexes that info
%           Blocks consist of sequences of pattern classes.
%           pattern :
%               Pattern classes refer to sets of symmetric "square" or "supersquare" or
%               random images, and eventually fixation stimuli. Need to change terminology to be consistent.
%               A given sequence has a duration and a number of individual
%               pattern elements.
%
%   A given expt can be be specified with a few parameters:
%       number of blocks
%       block type

% Loading global variables
global blockTimingFlag 
blockTimingFlag = 3;
%global SPM_Matrix
global numberOfTasks
global numberOfTrials
%global subject_ID

numberOfTasks = 1; % NOTE! 1 => 2 repeats
numberOfTrials = 1;  % 2 per Task (i.e., 4 min )

% Parameter specifications ------------------------------------------------

%---- Control params
control.default_status = 1;
control.write_img_jpg = 0;
control.debug = 0;
control.status = 'running';

params.control = control;

%----   Get display parameters
params.display = getDisplayParams( params );

%----   Get stimulus parameters
params = define_defaults( params );
params = set_symmetry_params( params );

params = make_pattern_array( params );

%---- Set mri parameters -- some are contingent on stimulus
params = define_mri_params( params );

end
%--------------------------------------------------------------------------



%-------------------------------------------------------------------------
function display = getDisplayParams( params )

% Defining display parameters

if params.control.debug
    disp('Specifying display parameters');
end

display.screens = Screen('Screens');
display.screenNumber = max( display.screens ); % Display screen
display.doublebuffer = 1; 

% Screen dimensions
[width_pix, height_pix] = Screen('WindowSize', display.screenNumber);
[w_mm,h_mm] = Screen('DisplaySize',display.screenNumber);
display.width_pix = width_pix;
display.height_pix = height_pix;        
display.rect = [0  0 width_pix height_pix]; % Display rect
[display.center(1), display.center(2)] = RectCenter( display.rect );
display.width_cm = w_mm/10; 
display.view_dist_cm = 60; % default -- should measure

% Display colors
display.black = 1;
display.white = 255;
display.gray = (display.black + display.white) / 2;  % Computes the CLUT color code for gray.
if round(display.gray)==display.white
    display.gray=black;
end
display.absoluteDifferenceBetweenWhiteAndGray = abs(display.white - display.gray);

% Frames per second
display.fps = 60;
display.ifi = 1/display.fps;

display.waitframes   = 1;
display.update_hz    = display.fps/display.waitframes;
display.update_ifi   = 1/display.update_hz;

% Pixels per degree of visual angle
display.ppd = pi * (width_pix) / atan(display.width_cm/display.view_dist_cm/2) / 360;

Screen('CloseAll');

% Restores the mouse cursor.
ShowCursor;

end
%-------------------------------------------------------------------------



%-------------------------------------------------------------------------
function params = define_defaults( params )

default.n_blocks         = 10;  % 5 => repeat once  10 => repeat twice
default.duration         = 12;
default.offpres          = 12;
% default.n_class          = 6;
default.n_elements       = 6; % Elements references pattern/blank pairs
default.element_duration = default.duration/default.n_elements;  % Total duration/# of elements (2)
default.duty_cycle       = 0.5;  %  0.5
default.individual_duration = default.element_duration; % Element duration (2), Include duty-cycle if you want different presentation type
default.block_types      =  { 'square-blank', 'super_square-blank', 'super_square_2-blank', ...
                                'super_square_3-blank', 'super_square_4-blank', ... 
                                    'square-blank', 'super_square-blank', 'super_square_2-blank', ...
                                         'super_square_3-blank', 'super_square_4-blank'};

default.seq_replications = 1; % per block
default.n_exptphase = 2; % 1 on, 1 off
default.theta0          = atan2(1,3);
default.phase0          = 0;
default.cyc_per_deg     = 1.5; % cycles/deg
default.n_patterns      = 2; % Number of patterns
default.theta_noise_max = .5*default.theta0;
default.cyc_per_sd      = 5.5;  % for gaussian_sp_const
default.img_fraction    = .8;   % fraction of total verparalell_Port_dioal size of display

default.total_secs = default.n_blocks * (default.n_exptphase*default.duration);

% Text
default.TextFont = 'Courier New';
default.TextSize = 64;
default.TextStyle = 1+2;
default.TextColor = params.display.white;

default.img_file_fmt = 'gif';

% default.pattern.phase0        = 0;
% default.pattern.phase_shift   = 0;
% default.pattern.n_components  = 4;
% default.pattern.cyc_per_img   = 12;
% default.pattern.img_pix       = 512;

% Fixation
default.fix_color = {uint8([255, 0, 0]),uint8([0, 255, 0])};
default.fix_radius = 5;
default.fix_line = 2;
default.fix_p_chg = .7;
default.fix_type = {'FillOval'};

params.default = default;

end
%-------------------------------------------------------------------------



%-------------------------------------------------------------------------
function params = set_symmetry_params( params )
% global blockTimingFlag

if params.control.debug
    disp('set_symmetry_params');
end

if ~params.control.default_status
    error('Custom design feature not yet enabled.');
end

default = params.default;
display = params.display;

%--- Build expt structure
n_blocks = default.n_blocks;
expt.n_blocks = n_blocks;

block_types = default.block_types;
expt.block_types = block_types;

%--- Build block structure
for b = 1:expt.n_blocks
    
    seq_replications = default.seq_replications; % 2
    block(b).seq_replications = seq_replications;
    
        switch block_types{b}
            case 'square-random'
                stim_type = repmat({'square', 'square'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'random'}, 1, seq_replications );
            case 'super_square-random'
                stim_type = repmat({'super_square', 'random'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'random'}, 1, seq_replications );
            case 'blank-blank'
                stim_type = repmat({'none', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'square-blank'
                stim_type = repmat({'square', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'super_square-blank'
                stim_type = repmat({'super_square', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'super_square_2-blank'
                stim_type = repmat({'super_square_2', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'super_square_3-blank'
                stim_type = repmat({'super_square_3', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'super_square_4-blank'
                stim_type = repmat({'super_square_4', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'square-super_square'
                stim_type = repmat({'square', 'super_square'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'symmetric-random'
                stim_type = repmat({'symmetric', 'symmetric'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'random'}, 1, seq_replications );
            case 'square-none'
                stim_type = repmat({'square', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'super_square-none'
                stim_type = repmat({'super_square', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'symmetric-none'
                stim_type = repmat({'symmetric', 'none'}, 1, seq_replications );
                theta_type = repmat({'fixed', 'fixed'}, 1, seq_replications );
            case 'random-none'
                stim_type = repmat({'random', 'none'}, 1, seq_replications );
                theta_type = repmat({'random', 'fixed'}, 1, seq_replications );
        end

        block(b).block_type = block_types{b};
        
        n_patterns          = default.n_patterns; % 2
        block(b).n_patterns = default.n_patterns; % in this class

        n_elements          = default.n_elements; % 12
        block(b).n_elements = repmat( n_elements, [1 n_patterns*seq_replications] );

        block(b).stim_type  = stim_type;
        block(b).theta_type = theta_type;
        block(b).tilt_type  = repmat({'random'}, [1 n_patterns*seq_replications] );
        block(b).theta0     = default.theta0;

        block(b).stim_secs  = repmat( default.duration, [1 n_patterns*seq_replications] ); % 24
        block(b).element_secs = block(b).stim_secs./block(b).n_elements; %24/12 = 2s
        block(b).element_duty_cycle = repmat( default.duty_cycle, [1 n_patterns*seq_replications] ); % .5

        block(b).theta_noise_max = block(b).theta0;

        widthOfGrid = display.height_pix * default.img_fraction;
        halfWidthOfGrid = widthOfGrid / 2;
        widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.

        [X, Y] = meshgrid( widthArray, widthArray );
        block(b).X                     = X;
        block(b).Y                     = Y;

        %--- Assign to block structure
        cyc_per_pix = default.cyc_per_deg/display.ppd;
        rad_per_pix = cyc_per_pix * 2 * pi; % cyc/pix * rad/cyc
        gaussianSpaceConstant = default.cyc_per_sd/cyc_per_pix;

        %     block(b).gaussianSpaceConstant = gaussianSpaceConstant;
        block(b).gaussianSpaceConstant        = gaussianSpaceConstant;

        block(b).rad_per_pix           = rad_per_pix;

        %--- For each element
        for p = 1:block(b).n_elements

            % For each pattern in element set
            for s = 1:block(b).n_patterns

                % 'symmetric' stim type creates alternating square/super-square
                if strcmp( block(b).stim_type{s}, 'symmetric' )
                    switch p
                        case 1
                            patt = 'square';
                        case 2
                            patt = 'super_square';
                       case 3
                            patt = 'super_square_2';
                       case 4
                            patt = 'super_square_3';
                       case 5
                            patt = 'super_square_4';
                        otherwise 
                            patt = 'square';
                    end % END - switch p

                    pattern(s).p_type{p} = patt;
                else               
                    pattern(s).p_type{p}    = block(b).stim_type{s};
                end

                pattern(s).theta0(p)        = block(b).theta0;
                pattern(s).phase0(p)        = default.phase0;
                pattern(s).phase_shift(p)   = default.phase0;
                pattern(s).n_components(p)  = 4;

                pattern(s).cyc_per_img(p) = 32;

        %             if( blockTimingFlag == 3 )
        %                 pattern(s).cyc_per_img(p) = 32;
        %             elseif( blockTimingFlag == 4 )
        %                 pattern(s).cyc_per_img(p) = 128;
        %             else
        %                 pattern(s).cyc_per_img(p) = 32;
        %             end % END - if( blockTimingFlag == 3 )


                %   pattern(s).cyc_per_img(p)   = widthOfGrid * cyc_per_pix;
                pattern(s).img_pix(p)       = widthOfGrid;

                %--- Feed vector of tilt values
                switch block(b).tilt_type{s}
                    case 'fixed'
                        pattern(s).tilt(p)  = 0;
                    case 'random'
                        pattern(s).tilt(p)  = ( 2*rand(1, 1)-ones(1,1) )*pi/2; % random tilt
                end

                %--- Feed vector of theta values to pattern generator
                switch block(b).theta_type{s}
                    case {'fixed', 'none'}
                        pattern(s).theta_noise_max(p)  = 0;
                    case {'random_all', 'random'}
                        pattern(s).theta_noise_max(p)  = block(b).theta_noise_max;
                end

                theta0 = pattern(s).theta0(p);
                theta_vect = [ theta0; theta0 + pi/2; pi/2 - theta0; -theta0 ];

                %--- Generate theta noise vector, if 'random', then change only 1
                if strcmp(block(b).theta_type{s}, 'random' )
                   theta_noise = pattern(s).theta_noise_max(p)*[ 2*rand(1,1)-1 0 0 0 ]';
                else
                   theta_noise = 2*rand(4,1)*pattern(s).theta_noise_max(p) - ones(4,1);
                end
                pattern(s).theta(:,p) = theta_vect + theta_noise;

                %--- Feed vector of phase values to pattern generator
                switch pattern(s).p_type{p}
                    case {'square', 'none'}
                        phase_shift = 0;
                    case 'super_square'
                        phase_shift = pi;
                    case 'super_square_2'   % pi / 2
                        phase_shift = pi / 2;
                    case 'super_square_3'   % pi / 3
                        phase_shift = pi / 3;   
                    case 'super_square_4'   %  2 * pi / 3
                        %   phase_shift = 2 * pi / 3;   
                        phase_shift = pi / 4;   
                    otherwise
                        phase_shift = 0;
                end

                phase0 = pattern(s).phase0(p);
                pattern(s).phase(:,p) = [ phase0 phase0 phase0 + phase_shift phase0 + phase_shift ];

                pattern(s).gaussianSpaceConstant = block(1).gaussianSpaceConstant;
                pattern(s).rad_per_pix = block(b).rad_per_pix;

                pattern(s).on_secs(p) = block(b).element_secs(s).*block(b).element_duty_cycle(s); % 1s
                pattern(s).off_secs(p) = block(b).element_secs(s).*(1-block(b).element_duty_cycle(s)); % 1s
        %             
        %             pattern(s).on_secs(p) = block(b).element_secs(s);
        %             pattern(s).off_secs(p) = block(b).element_secs(s);

            end % End for s

        end % End for: p = 1:block(b).n_elements
 
    block(b).pattern = pattern;
    
end % for b

expt.block    = block;
params.expt   = expt;

end
%-------------------------------------------------------------------------



%--------------------------------------------------------------------------
function c = make_grating( X, Y, phase, tiltInRadians, rad_per_pix )
% Generates gray scale grating

a = cos( tiltInRadians )* rad_per_pix;
b = sin( tiltInRadians )* rad_per_pix;

cc = cos( a*X + b*Y + phase*ones(size(X)) );
scale = max(cc(:));

c = cc/scale;

end
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
function g = make_circularGaussian( X, Y, gaussianSpaceConstant )

%   gaussianSpaceConstant = 10;
g = exp(  -( (X .^ 2) + (Y .^ 2) ) / ( gaussianSpaceConstant ^ 2 )  );

%   [matrix]=MakeCircle( 20, 100, 0 ); figure(1);imagesc( matrix );

tempSizeX = size( X, 1 );
tempMax = round(  max( X(:) )  );

tempIndices = find(  (  sqrt( X.^2 + Y.^2 )  ) < ( 0.7 * tempMax )  ); 
g = zeros(  tempSizeX );
g( tempIndices ) = 1;
%   g = makecircle( (0.7 * tempSizeX), tempSizeX, 0 );

end
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
function p = make_pattern( X, Y, phase, theta, tilt, rad_per_pix, gaussianSpaceConstant )

c1 = make_grating( X, Y, phase(1), theta(1) + tilt, rad_per_pix );
c2 = make_grating( X, Y, phase(2), theta(2) + tilt, rad_per_pix );
c3 = make_grating( X, Y, phase(3), theta(3) + tilt, rad_per_pix );
c4 = make_grating( X, Y, phase(4), theta(4) + tilt, rad_per_pix );

c = (c1+c2+c3+c4);
scale = max(c(:)); % force values in [-1,1]

p = ( c./scale ) .* make_circularGaussian( X, Y, gaussianSpaceConstant );

end
%--------------------------------------------------------------------------


%-------------------------------------------------------------------------
function params = make_pattern_array( params )

    for b = 1:params.expt.n_blocks

        this_block = params.expt.block(b);
        x = size( this_block.X );
        n_patterns = this_block.n_patterns;

        for s = 1:n_patterns

            this_pattern = this_block.pattern(s);
            rad_per_pix = this_pattern.rad_per_pix;
            gaussianSpaceConstant = this_pattern.gaussianSpaceConstant;

            for p = 1:this_block.n_elements(s)

                theta       = this_pattern.theta(:,p);
                phase       = this_pattern.phase(:,p);
                tilt        = this_pattern.tilt(p);

                % If pattern type is none, fill image with zeros
                if ~strcmp( this_pattern.p_type(p), 'none' )
                    pattern = make_pattern( this_block.X, this_block.Y, phase, theta, tilt, rad_per_pix, gaussianSpaceConstant );
                    img{p} = params.display.gray + params.display.absoluteDifferenceBetweenWhiteAndGray * pattern;
                end

                fix(p).type = params.default.fix_type{1};           
                fix(p).radius = params.default.fix_radius;
                fix(p).line = params.default.fix_line; 
                
                if rand(1,1) > params.default.fix_p_chg;
                    fix(p).change = 1;
                else
                    fix(p).change = 0;
                end

            end

            this_pattern.img = img;
            this_pattern.fix = fix;

            patterns(s) = this_pattern;

        end

        params.expt.block(b).pattern = patterns;
        
%         offpres = params.default.offpres;
%     
%         for i = 1:offpres
%             
%             offphase.img{i}  = repmat(params.display.gray, x );
% 
%             if rand(1,1) > params.default.fix_p_chg;
%                 offphase.color{i} = params.default.fix_color{1};
%             else
%                 offphase.color{i} = params.default.fix_color{2};
%             end
% 
%         end
%         
%         offphase.fix_type = params.default.fix_type;
%         
%         params.expt.block(b).offphase = offphase;
        
        
    end

end
%-------------------------------------------------------------------------



%-------------------------------------------------------------------------
function params = define_mri_params( params )

mri.tr          = 2; % seconds
mri.n_discards  = 2;
mri.discarded_vol_secs = mri.tr * mri.n_discards;

params.mri = mri;

end
%-------------------------------------------------------------------------