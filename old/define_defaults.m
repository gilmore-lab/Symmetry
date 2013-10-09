function params = define_defaults( params )
global blockTimingFlag 

blockTimingFlag = 3;
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
%default.TextColor = params.display.white;

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