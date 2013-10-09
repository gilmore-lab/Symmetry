function params = symmetry_jps_7( temp_1 )

eval( [ 'cd ', 'C:\SLEIC_Projects\jps120\Matlab_Work\SymmetryStudy' ] );
%   temp_1 = 3 
%   close all; clear all; pack; clc; symmetry_jps_7( 3 );

  %  

global useMCC_Flag MCC_dio
global blockTimingFlag 
blockTimingFlag = temp_1;
global SPM_Matrix
global numberOfTasks
global numberOfTrials
global subject_ID
global manualTriggerSeconds2wait

numberOfTasks = 1; % NOTE! 1 => 2 repeats
numberOfTrials = 1;  % 2 per Task (i.e., 4 min )

useMCC_Flag = 1;
manualTriggerSeconds2wait = 1.98; % When using manual trigger, ammount of time to display pattern.
  
  
  
  
load symmetry_cfg.mat
%   subject_ID 

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



if( useMCC_Flag )
    MCC_dio = digitalio( 'mcc' ,'0' );
    addline( MCC_dio, 0, 0, 'in' );
    start( MCC_dio );
end % END - if( useMCC_Flag )


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

%----   Show stimuli
params = show_symmetry( params );

return
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function c = make_grating( X, Y, phase, tiltInRadians, rad_per_pix )
% Generates gray scale grating

a = cos( tiltInRadians )* rad_per_pix;
b = sin( tiltInRadians )* rad_per_pix;

cc = cos( a*X + b*Y + phase*ones(size(X)) );
scale = max(cc(:));

c = cc/scale;

return
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

return;
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
return
%--------------------------------------------------------------------------


%-------------------------------------------------------------------------
function params = make_pattern_array( params )

for b = 1:params.expt.n_blocks
    this_block      = params.expt.block(b);
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
            if strcmp( this_pattern.p_type(p), 'none' )
                img{p}  = zeros( size( this_block.X ) );
            else
                img{p} = make_pattern( this_block.X, this_block.Y, phase, theta, tilt, rad_per_pix, gaussianSpaceConstant );
            end
            
            fix(p).color = params.default.fix_color;
            fix(p).radius = params.default.fix_radius;
            fix(p).line = params.default.fix_color;        
            if rand(1,1) > params.default.fix_p_chg;
                fix(p).type = params.default.fix_types{1};
            else
                fix(p).type = params.default.fix_types{2};
            end
        end
        this_pattern.img = img;
        this_pattern.fix = fix;
        
        patterns(s) = this_pattern;
    end
    params.expt.block(b).pattern = patterns;
end

return
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
function display = getDisplayParams( params )
if params.control.debug
    disp('Specifying display parameters');
end

try
    display.screens = Screen('Screens');
    display.screenNumber = max( display.screens );
    display.doublebuffer = 1;
    
    [width_pix, height_pix] = Screen('WindowSize', display.screenNumber);
    display.width_pix = width_pix;
    display.height_pix = height_pix;
    
    display.rect = [0  0 width_pix height_pix];
    
    display.black = 1;
    display.white = 255;
    display.width_cm = 39; % default -- should measure
    
    [display.center(1), display.center(2)] = RectCenter( display.rect );
    
    display.view_dist_cm = 60; % default -- should measure
    
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

catch exception
if(  0  )
    Screen('CloseAll');
    
    % Restores the mouse cursor.
    ShowCursor;
    
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    
    %     params.control.status = 'error';
    %     params.control.error_code = psychlasterror;
    
    % We throw the error again so the user sees the error description.
    psychrethrow( psychlasterror );
end % END - if(  1  )
    rethrow(exception) 
end

%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
function params = set_symmetry_params( params )
global blockTimingFlag

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
    
    seq_replications = default.seq_replications;
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
    
    n_patterns          = default.n_patterns;
    block(b).n_patterns = default.n_patterns; % in this class
    
    n_elements          = default.n_elements;
    block(b).n_elements = repmat( [ n_elements ], n_patterns*seq_replications );
    
    block(b).stim_type  = stim_type;
    block(b).theta_type = theta_type;
    block(b).tilt_type = repmat({'random'}, 1, n_patterns*seq_replications );
    block(b).theta0     = default.theta0;
    
    block(b).stim_secs  = repmat( [ default.class_duration ], n_patterns*seq_replications );
    block(b).element_secs = block(b).stim_secs./block(b).n_elements;
    block(b).element_duty_cycle = repmat( [ default.duty_cycle ], n_patterns*seq_replications );
    block(b).final_gray_secs = default.final_gray_secs;
    
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
    
    %--- Build pattern structure for this block
    for s = 1:block(b).n_patterns
        %--- Square with random tilt
        for p = 1:block(b).n_elements
            
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

            if( blockTimingFlag == 3 )
                pattern(s).cyc_per_img(p) = 32;
            elseif( blockTimingFlag == 4 )
                pattern(s).cyc_per_img(p) = 128;
            else
                pattern(s).cyc_per_img(p) = 32;
            end % END - if( blockTimingFlag == 3 )

            
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
            
            pattern(s).on_secs(p) = block(b).element_secs(s).*block(b).element_duty_cycle(s);
            pattern(s).off_secs(p) = block(b).element_secs(s).*(1-block(b).element_duty_cycle(s));
            
        end
    end % for s
    
    block(b).pattern = pattern;
end % for b

expt.block    = block;
params.expt   = expt;

return
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
function params = show_symmetry( params )
global useMCC_Flag MCC_dio
global SPM_Matrix
global tempCounter_2 
global numberOfTasks
global numberOfTrials
global subject_ID
global manualTriggerSeconds2wait


control = params.control;
display = params.display;


try
    % ---------- Window Setup ----------
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    
    
    whichScreen = display.screenNumber;
    [windowPointer, windowRectangle] = Screen( 'OpenWindow', whichScreen );
    params.display.window = windowPointer;
    
    ifi = display.ifi;
    fps = display.fps;
    
    % ---------- Color Setup ----------
    
    % Retrieves color codes for black and white and gray.
    black = display.black;  % Retrieves the CLUT color code for black.
    white = display.white;  % Retrieves the CLUT color code for white.
    gray = (black + white) / 2;  % Computes the CLUT color code for gray.
    if round(gray)==white
        gray=black;
    end
    % Taking the absolute value of the difference between white and gray will
    % help keep the grating consistent regardless of whether the CLUT color
    % code for white is less or greater than the CLUT color code for black.
    absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
    center = params.display.center;
    fix_x0 = center(1)-5;
    fix_y0 = center(2)-5;
    fix_x1 = center(1)+5;
    fix_y1 = center(2)+5;
    fix_coords = [ fix_x0 fix_y0 fix_x1 fix_y1 ];
    
    KbName( 'UnifyKeyNames' );
    escapeKey = KbName('ESCAPE');
    aKey = KbName('a');
    bKey = KbName('b');
    cKey = KbName('c');
    dKey = KbName('d');

    monitorWidth   = 48;   % horizontal dimension of viewable screen (cm)
    viewingDistance      = 60;   % viewing distance (cm)
    fixationPointRadius = 0.15;
    [ windowCenter(1), windowCenter(2) ] = RectCenter( windowRectangle );
    pixelsPerDegree = ( pi / 360 ) * ( windowRectangle(3) - windowRectangle(1) ) ...
                        / atan(   ( monitorWidth / 2 ) / viewingDistance  );     % pixels per degree
    fixationPointCoordinates = [ (  windowCenter - ( fixationPointRadius * pixelsPerDegree )  ) ...
                    (  windowCenter + ( fixationPointRadius * pixelsPerDegree )  ) ];
    
    totalTaskTime = tic;
    escapeKeyFlag = 0;
for taskIndex = 1:numberOfTasks
    if( escapeKeyFlag == 1 )
        break;
    end % END - if( escapeKeyFlag == 1 )
        % Do initial flip...
        vbl = Screen('Flip', windowPointer );
        Screen('FillRect', windowPointer, gray);
        HideCursor;


    %% BEGIN - Delay start of display for 2 sync pulses
        tempFlag = 0;
        tempCounter = 0;
        beep on;

        %   params = draw_text_2_screen( params, 'Starting...' );

 beginTriggerPulseTimer = tic;        
            if( useMCC_Flag )
                tempDIOvalue = getvalue( MCC_dio );
                Screen('FillRect', windowPointer, gray);
                params = draw_text_2_screen( params, 'Starting...' );
                vbl = Screen( 'Flip', windowPointer  );
                while(  tempDIOvalue == 0  )
                    tempDIOvalue = getvalue( MCC_dio );
                end  % END - while(  tempDIOvalue == 0  )
           else
                % Show ready screen, wait for keypress to start
                Screen(  'FillRect', windowPointer, gray  );
                vbl = Screen( 'Flip', windowPointer  );
                params = draw_text_2_screen( params, 'Scanner Operator ONLY!' );
                %   vbl = Screen( 'Flip', windowPointer  );
                Screen( 'DrawingFinished', windowPointer ); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                KbWait;
                %   while KbCheck; end;
                %   if(  ~useMCC_Flag  )
                %   end % END - if(  ~useMCC_Flag  )
                    Screen('FillRect', windowPointer, gray);
                    vbl = Screen( 'Flip', windowPointer  );
                    tempDIOvalue = 0;
                    tempValue = 0;
                    delay4sec = tic;
                    while( toc( delay4sec ) < 4.75 ) % Assuming 2 second TR pulse
                    end;  % END - while( toc( delay4sec ) < 4 )
                tempFlag = 1;
            end % END - if( useMCC_Flag )
    %% END - Delay start of display for 2 sync pulses
    toc( beginTriggerPulseTimer )
    totalRunTime = GetSecs; 

    colorRed = [255, 0, 0];
    colorGreen = [0, 255, 0];
    fixationPointShape = 'FillOval';
    fixationPointShapeFlag = 1;
    fixationPointColor = colorRed;
        previousPointShape = fixationPointShape;
        previousPointColor = fixationPointColor;
    for trialIndex = 1:numberOfTrials
        behavioralResponseStructure = struct( [] );
        if( escapeKeyFlag == 1 )
                Screen('CloseAll');
                ShowCursor;
                return;             
        end % END - if( escapeKeyFlag == 1 )
        Screen(  'FillRect', windowPointer, gray  );
        vbl = Screen( 'Flip', windowPointer  );
        frameIndex = 0;
        tempCounter1 = 1;


        % Start actual data acquisition and display
        start_secs = GetSecs;

        % loop on block
        tempCounter_2 = 1;
        for b = 1:params.expt.n_blocks
        	if( escapeKeyFlag == 1 )
                Screen('CloseAll');
                ShowCursor;
                return;             
            end % END - if( escapeKeyFlag == 1 )

            this_block = params.expt.block(b);

            % loop on replications within block
            for r = 1:this_block.seq_replications
            	if( escapeKeyFlag == 1 )
                    Screen('CloseAll');
                    ShowCursor;
                    return;             
                end % END - if( escapeKeyFlag == 1 )

                % loop on patterns within block
                for s = 1:this_block.n_patterns
                    if( escapeKeyFlag == 1 )
                        Screen('CloseAll');
                        ShowCursor;
                        return;             
                    end % END - if( escapeKeyFlag == 1 )

                     tempStimulusType = this_block.stim_type{ s };
                     switch tempStimulusType
                         case 'square'
                            tempStimulusType = '      square';
                          case 'super_square'
                            tempStimulusType = 'super_square';
                          case 'super_square_2'
                            tempStimulusType = 'super_square_2';
                          case 'super_square_3'
                            tempStimulusType = 'super_square_3';
                          case 'super_square_4'
                            tempStimulusType = 'super_square_4';
                         case 'none'
                            tempStimulusType = '        none';
                         otherwise
                            tempStimulusType = '   otherwise';                             
                     end  % END - switch tempStimulusType
                         
                          
                     this_pattern = this_block.pattern( s );

                    if control.debug
                        fprintf('Pattern %d\n', s);
                    end

                    % loop on elements within pattern sequence
                    %   for i = 1:this_block.n_elements
                    numberOfElements = this_block.n_elements( 1, 1 );
                    tempCounter_3 = 0;
                    totalBlockTime = tic; 
                    for i = 1:numberOfElements
                        if( escapeKeyFlag == 1 )
                            Screen('CloseAll');
                            ShowCursor;
                            return;             
                        end % END - if( escapeKeyFlag == 1 )
                        if(  mod( i, 2) == 0  )
 %                              SPM_Matrix{ tempCounter1 } = tempStimulusType;
                            %   SPM_Matrix( tempCounter1, : ) = [ tempArcAngle, fixationPointChangeFlag, tempKeyPressed ];
                            tempCounter1 = tempCounter1 + 1;
 %                             [i; tempCounter1]
                        end  % END - if(  mod( i, 2)  )
                        
                        this_img = this_pattern.img{i};
                        on_secs  = this_pattern.on_secs(i);
                        off_secs = this_pattern.off_secs(i);
                        fix      = this_pattern.fix(i);

                        grayscaleImageMatrix = gray + absoluteDifferenceBetweenWhiteAndGray * this_img;
                        % Writes the image to the window.
                        
%% BEGIN - Plot fixation point
       fixationPointChangeFlag = 0;
       if(  rand < 0.3333 )
               fixationPointChangeThreshold = 0.5;
                if( escapeKeyFlag == 1 )
                    Screen('CloseAll');
                    ShowCursor;
                    return;             
                end % END - if( escapeKeyFlag == 1 )
                 
               %% BEGIN - Change fixation point color
                if( rand < fixationPointChangeThreshold )
                    %   fixationPointColor = white;
                    fixationPointColor = colorRed;
                else
                    %   fixationPointColor = gray;
                    fixationPointColor = colorGreen;
                end % END - if( rand < fixationPointChangeThreshold )
                % END - Change fixation point color

                %% BEGIN - Change fixation point shape
                if( rand < fixationPointChangeThreshold )
                    fixationPointShape = 'FillOval';
                    fixationPointShapeFlag = 1;
                else
                    fixationPointShape = 'FillOval';
                    %   fixationPointShape = 'FillRect';
                     fixationPointShapeFlag = 0;
                end % END - if( rand < fixationPointChangeThreshold )
                % END - Change fixation point shape


                if(  (fixationPointShapeFlag ~= previousPointShape) || (fixationPointColor ~= previousPointColor)  );
                    fixationPointChangeFlag = 1;
                else
                    fixationPointChangeFlag = 0;
                end  % END - if(  (fixationPointShape ~= previousPointShape) || (fixationPointColor ~= previousPointColor)  );
                previousPointShape = fixationPointShapeFlag;
                previousPointColor = fixationPointColor;                
       end  % END - if(  rand < 0.2  )
 
        Screen( fixationPointShape, windowPointer, uint8( fixationPointColor ), fixationPointCoordinates ); % draw fixation dot (flip erases it)
        vbl = Screen( 'Flip', windowPointer  );

%% END - Plot fixation point                        
                        
                        
                        
                        
        Screen('PutImage', windowPointer, grayscaleImageMatrix);
        Screen( fixationPointShape, windowPointer, uint8( fixationPointColor ), fixationPointCoordinates ); % draw fixation dot (flip erases it)
        vbl = Screen( 'Flip', windowPointer  );
        Screen( 'DrawingFinished', windowPointer ); % Tell PTB that no further drawing commands will follow before Screen('Flip')
        startImageDisplay = tic; 
        startTimeFrom_GetSecs = GetSecs;


                        %%  BEGIN - Check for trigger pulse = 0
                        %   if( useMCC_Flag )
                        if( useMCC_Flag )
                            dioTimer = tic;
                            tempValue_1 = getvalue( MCC_dio );
                            while( ~getvalue( MCC_dio ) )
 %% BEGIN - Keyboard check   
                                
                                triggeredFlag = 0;
                                startKeyPressTimer = tic;
                                tempKeyPressed = 0;
                                keyPressTime = 0;
                                
                                [ keyIsDown, timeSecs, keyCode ] = KbCheck;
                                
                                if( keyIsDown && ~triggeredFlag )

                                   triggeredFlag = 1;
                                   
                                   if(  keyCode( aKey ) || keyCode( bKey ) || keyCode( cKey ) || keyCode( dKey )  )
                                       %    JPS - 8/12/2011 - Look at this code segment before
                                       %    Monday

                                        %   elapsedTime = timeSecs - startSecs;
                                        %   fprintf('"%s" typed at time %.3f seconds\n', KbName(keyCode), elapsedTime );
                                        tempKeyPressed = KbName( keyCode);
                                        keyPressTime = ( timeSecs - startTimeFrom_GetSecs  );
                                        
                                        if( keyPressTime == 0 )
                                            keyPressTime = GetSecs - startKeyPressTimer;
                                        end % END - if( keyPressTime == 0 )
                                        
        behavioralResponseStructure( tempCounter_2 ).StimulusType = tempStimulusType;                                
        behavioralResponseStructure( tempCounter_2 ).TotalRunTime = toc( totalRunTime );                                 
        behavioralResponseStructure( tempCounter_2 ).fixationPointChangeFlag = fixationPointChangeFlag;                                
        behavioralResponseStructure( tempCounter_2 ).keyPressed = tempKeyPressed;                                
        behavioralResponseStructure( tempCounter_2 ).keyPressTime = keyPressTime;                                
        tempCounter_2 = tempCounter_2 + 1;
        
                                   end % END - if(  keyCode(aKey) | keyCode(bKey) | keyCode(cKey) | keyCode(dKey) |  )

                                    if keyCode( escapeKey )
                                        Screen('CloseAll');
                                        ShowCursor;
                                        return;             
                                        escapeKeyFlag = 1;
                                    end % END - if keyCode(escapeKey)

                                    % If the user holds down a key, KbCheck will report multiple events.
                                    % Wait until all keys have been released.
                                %   while KbCheck; end
                               end  % END - if( keyIsDown )

                                if( escapeKeyFlag == 1 )
                                    Screen('CloseAll');
                                    ShowCursor;
                                    return;             
                                end % END - if( escapeKeyFlag == 1 )
        
                            tempCounter_3 = tempCounter_3 + 1;
%% END - Keyboard check   
                           end % END - while( ~getvalue( MCC_dio )  )
                           while(  toc( dioTimer ) < 1e-2  ) % image is displayed for 2 seconds % Assuming TR = 2sec => 1 pulse
                            %   while(  getvalue( MCC_dio )  ) % image is displayed for 2 seconds % Assuming TR = 2sec => 1 pulse
                            end;  % END - while( toc < 4 )
                            tempCounter_3 = tempCounter_3 + 1;
                        else                           
                            while(  toc( startImageDisplay ) < manualTriggerSeconds2wait  ) % image is displayed for 2 seconds % Assuming TR = 2sec => 1 pulse
%% BEGIN - Keyboard check   
                                startKeyPressTimer = tic;
                                tempKeyPressed = 0;
                                keyPressTime = 0;
                                [ keyIsDown, timeSecs, keyCode ] = KbCheck;
                                if( keyIsDown )

                                   if(  keyCode( aKey ) || keyCode( bKey ) || keyCode( cKey ) || keyCode( dKey )  )
                                       %    JPS - 8/12/2011 - Look at this code segment before
                                       %    Monday

                                        %   elapsedTime = timeSecs - startSecs;
                                        %   fprintf('"%s" typed at time %.3f seconds\n', KbName(keyCode), elapsedTime );
                                        tempKeyPressed = KbName( keyCode);
                                        keyPressTime = ( timeSecs - startTimeFrom_GetSecs  );
                                        if( keyPressTime == 0 )
                                            keyPressTime = toc( startKeyPressTimer );
                                        end % END - if( keyPressTime == 0 )
                                   end % END - if(  keyCode(aKey) | keyCode(bKey) | keyCode(cKey) | keyCode(dKey) |  )

                                    if keyCode( escapeKey )
                                        Screen('CloseAll');
                                        ShowCursor;
                                        return;             
                                        escapeKeyFlag = 1;
                                    end % END - if keyCode(escapeKey)

                                    % If the user holds down a key, KbCheck will report multiple events.
                                    % Wait until all keys have been released.
                                %   while KbCheck; end
        behavioralResponseStructure( tempCounter_2 ).StimulusType = tempStimulusType;                                
        behavioralResponseStructure( tempCounter_2 ).TotalRunTime = toc( totalRunTime );                                
        behavioralResponseStructure( tempCounter_2 ).fixationPointChangeFlag = fixationPointChangeFlag;                                
        behavioralResponseStructure( tempCounter_2 ).keyPressed = tempKeyPressed;                                
        behavioralResponseStructure( tempCounter_2 ).keyPressTime = keyPressTime;                                
        tempCounter_2 = tempCounter_2 + 1;
                              end  % END - if( keyIsDown )

                                if( escapeKeyFlag == 1 )
                                    Screen('CloseAll');
                                    ShowCursor;
                                    return;             
                                end % END - if( escapeKeyFlag == 1 )
        
                            tempCounter_3 = tempCounter_3 + 1;
%% END - Keyboard check   
                            end;  % END - while( toc( startImageDisplay ) < manualTriggerSeconds2wait )
                        end % END - if( useMCC_Flag )                         
                    end % END - for i = 1:numberOfElements
                    toc( totalBlockTime );
                end % END - for s = 1:this_block.n_patterns
            end % END - for r = 1:this_block.seq_replications

if(  0  )
            %-- Show gray sceen at end of block
            Screen('FillRect', windowPointer, gray);
            if (display.doublebuffer==1)
                vbl=Screen('Flip', windowPointer, vbl + (fps*this_block.final_gray_secs-0.5)*ifi);
            end % END - if (display.doublebuffer==1)
end % END - if(  1  )


        end % END - for b = 1:params.expt.n_blocks
        params.control.total_secs = GetSecs - start_secs;
    toc( totalTaskTime )
    
        %% BEGIN - Save indexed responseGripMatrix
        tempFolderName = ['Response/Subject_', num2str( subject_ID )];
        if(  ~exist( [ char(39), tempFolderName, char(39) ], 'dir' )   )
            status = mkdir( tempFolderName ); 
        end  % END - if(  ~exist( [ char(39), tempFolderName, char(39) ], 'dir' )   )    
        notSaved = 1;
         tempCounter_10 = 1;
        while( notSaved )
            tempFilename = ['Response/Subject_', num2str( subject_ID ) , '/responseGripMatrix_TaskNumber_', num2str(  tempCounter_10 ), '.mat'];
            if(   exist( tempFilename )  )
                 tempCounter_10 =  tempCounter_10 + 1;
                notSaved = 1;
            else
                eval(  ['save ', tempFilename, ' behavioralResponseStructure']  );
                notSaved = 0;
            end;  % END - if(   exist( tempFilename )  )         
            %  save responseGripMatrix.mat responseGripMatrix
        end;  % END -     while( notSaved )
    %% END - Save indexed responseGripMatrix
    end  % END - for trialIndex = 1:numberOfTrials
end  % END - for taskIndex = 1:numberOfTasks        
    
    % Final end of session screen
    params = draw_text_2_screen( params, 'Finished!' );
    WaitSecs(2); 
    
    % Close all screens
    Screen('CloseAll');
    
    % Restores the mouse cursor.
    ShowCursor;
    
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    params.control.status = 'successful_termination';
    
    if( useMCC_Flag )
        stop( MCC_dio );
        delete( MCC_dio )
        clear MCC_dio 
    end % END - if( useMCC_Flag )
    
subject_ID = subject_ID + 1;
save symmetry_cfg.mat subject_ID


tempCounter_3
    
catch
    
    % ---------- Error Handling ----------
    % If there is an error in our code, we will end up here.
    
    % The try-catch block ensures that Screen will restore the display and return us
    % to the MATLAB prompt even if there is an error in our code.  Without this try-catch
    % block, Screen could still have control of the display when MATLAB throws an error, in
    % which case the user will not see the MATLAB prompt.
    Screen('CloseAll');
    
    % Restores the mouse cursor.
    ShowCursor;
    
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    
    params.control.status = 'error';
    params.control.error_code = psychlasterror;
    
    % We throw the error again so the user sees the error description.
    psychrethrow( psychlasterror );
    
        
    if( useMCC_Flag )
        stop( MCC_dio );
        delete( MCC_dio )
        clear MCC_dio 
    end % END - if( useMCC_Flag )    
end

return
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
function params = define_defaults( params )
global blockTimingFlag 

%   blockTimingFlag = 3;
switch blockTimingFlag
    case 1
        default.n_blocks        = 12;  % 12
        default.class_duration  = 6; % seconds  % 6
        default.n_elements      = default.class_duration;  % Patterns/class  % 6
        default.block_types     =  { 'square-blank', 'super_square-blank', 'square-blank', 'super_square-blank', ...
                                        'square-blank', 'super_square-blank', 'square-blank', 'super_square-blank', ...
                                            'square-blank', 'super_square-blank', 'square-blank', 'super_square-blank', ... 
                                                'blank-blank', 'blank-blank' }; 
                                        %{ 'square-blank', 'super_square-blank' }
    case 2
        default.n_blocks        = 12;  % 12
        default.class_duration  = 6; % seconds  % 6
        default.n_elements      = default.class_duration;  % Patterns/class  % 6
        default.block_types     =  { 'square-super_square', 'square-super_square', 'square-super_square', 'square-super_square', ...
                                         'square-super_square', 'square-super_square', 'square-super_square', 'square-super_square', ...
                                            'square-super_square', 'square-super_square', 'square-super_square', 'square-super_square' }; %{ 'random-none', 'random-none' }
                                         % {'symmetric-random', 'square-random', 'super_square-random', 'symmetric-random'}
    case 3
        default.n_blocks        = 10;  % 5 => repeat once  10 => repeat twice
        default.class_duration  = 12; % seconds  % 12
        default.n_elements      = 6;  % Patterns/class  % 6 default.class_duration
        default.block_types     =  { 'square-blank', 'super_square-blank', 'super_square_2-blank', ...
                                        'super_square_3-blank', 'super_square_4-blank', ... 
                                            'square-blank', 'super_square-blank', 'super_square_2-blank', ...
                                                 'super_square_3-blank', 'super_square_4-blank' }; %{ 'random-none', 'random-none' }
    case 4
        default.n_blocks        = 5;  % 5 => repeat once  10 => repeat twice
        default.class_duration  = 6; % seconds  % 12
        default.n_elements      = 6;  % Patterns/class  % 6 default.class_duration
        default.block_types     =  { 'square-blank', 'super_square-blank', 'super_square_2-blank', ...
                                        'super_square_3-blank', 'super_square_4-blank', ... 
                                            'square-blank', 'super_square-blank', 'super_square_2-blank', ...
                                                 'super_square_3-blank', 'super_square_4-blank' }; %{ 'random-none', 'random-none' }
    otherwise
        default.n_blocks        = 14;  % 2
        default.class_duration  = 12; % seconds  % 12
        default.n_elements      = default.class_duration;  % Patterns/class  % 6
        default.block_types     =  { 'square-blank', 'super_square-blank', 'square-blank', 'super_square-blank', ...
                                        'square-blank', 'super_square-blank', 'square-blank', 'super_square-blank', ...
                                            'square-blank', 'super_square-blank', 'square-blank', 'super_square-blank', ... 
                                                'blank-blank', 'blank-blank' }; 
                                        %{ 'square-blank',
                                        %'super_square-blank' }
end  % END - switch blockTimingFlag
default.seq_replications = 1; % per block
default.theta0          = atan2(1,3);
default.phase0          = 0;
default.cyc_per_deg     = 1.5; % cycles/deg
default.n_patterns      = 2;
default.duty_cycle      = 0.5;  %  0.25
default.final_gray_secs = 0;
default.theta_noise_max = .5*default.theta0;
default.cyc_per_sd      = 5.5;  % for gaussian_sp_const
default.img_fraction    = .8;   % fraction of total verparalell_Port_dioal size of display

default.total_secs = default.n_blocks * default.seq_replications * default.n_patterns * default.class_duration;

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

default.fix_color = 1;
default.fix_radius = 5;
default.fix_line = 2;
default.fix_p_chg = .75;
default.fix_types = {'plus', 'times'};

params.default = default;

return
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
function params = define_mri_params( params )

mri.tr          = 2; % seconds
mri.n_discards  = 2;
mri.discarded_vol_secs = mri.tr * mri.n_discards;
% mri.n_vols      = 
params.mri = mri;
return
%-------------------------------------------------------------------------


function params = draw_text_2_screen( params, txt )

try
    w = params.display.window;
    
    Screen('TextFont', w, params.default.TextFont);
    %   Screen('TextSize', w, params.default.TextSize);
    Screen('TextSize', w, 12 );
    Screen('TextStyle', w, params.default.TextStyle);
    
    %   [~, ny, bbox] = DrawFormattedText(w, txt, 'center', 'center', params.default.TextColor );
    [~, ny, bbox] = DrawFormattedText(w, txt, 'center', [], params.default.TextColor );
    Screen('Flip', w);

catch
    Screen('CloseAll');
    fclose('all');
    psychrethrow(psychlasterror);
end


return

function draw_fixation( display, fix )

windowPointer = display.window;

fix_color = fix.color;
fix_line_pix = fix.line;
fix_radius_pix = fix.radius;
fix_type = fix.type;

fromH = display.center(1) - fix_radius_pix;
fromV = display.center(2) - fix_radius_pix;
toH   = display.center(1) + fix_radius_pix;
toV   = display.center(2) + fix_radius_pix;

switch fix_type
    case 'circle'
        Screen('FillOval', windowPointer, fix_color, [ fromH fromV toH toV ] );
    case 'times'
        Screen('DrawLine', windowPointer, fix_color, fromH, fromV, toH, toV, fix_line_pix);
        Screen('DrawLine', windowPointer, fix_color, fromH, toV, toH, fromV, fix_line_pix);
    case 'plus'
        Screen('DrawLine', windowPointer, fix_color, display.center(1), fromV, display.center(1), toV, fix_line_pix);
        Screen('DrawLine', windowPointer, fix_color, fromH, display.center(2), toH, display.center(2), fix_line_pix);        
end % switch
return

function delayInSecs = checkTheKeyboard( startTimeOfPattern )

[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;

delayInSecs = ( startTimeOfPattern - secs );
