function varargout = antMeas(varargin)
% ANTMEAS Graphical antenna measurement tool
%
%	ANTMEAS runs the GUI using default settings. 
%
%	ANTMEAS('param') allows you specify optional parameters from the
%	following list:
%		debug				Enables debugging
%		help, man, ver		Displays this help, equals to calling help ANTMEAS
%		reset, clear		Clears the current Matlab instance before running
%		nogui				Run without the GUI
%
%	[G] = ANTMEAS or [G] = ANTMEAS('param') returns the structure
%	containing all data to use the program from the command line when the
%	window is still open (hint: useful when scripting). Since this program
%	uses <a href="matlab:help guidata">guidata</a>, you need to use G = guidata(G.window) to load changes
%	made by the program. To save your changes, use guidata(G.window, G).
%
%	[G, S] = ANTMEAS or [G, S] = ANTMEAS('param') returns two structures:
%	G with the application data and S with the static data. The static data
%	is required in most callback functions. The static struct can also be
%	obtained using [S] = <a href="matlab:addpath(genpath('1st_party')); help initStatic">initStatic</a>.
%
%	When running the software from command line, the handle to the caller
%	object (i.e., the first parameter) should be se to [] to ensure correct
%	behaviour. 
%
%	A word of warning: Using the program directly from the command line
%	requires deep insight into the inner workings of the software since,
%	for instance, it allows one to bypass all sanity checks made to the
%	input data.
%
%	For more detailed help/manual, see <a href="user_guide.pdf">user_guide.pdf</a>.
%	
%	Credits:		Tuomas Leinonen
%					tuomas.leinonen@aalto.fi
%					Aalto ELEC, RAD, C120
%					September 8th, 2013
% 
%	The author would like to thank Risto Valkonen for his help with the
%	calculation scripts, and the authors of the third party software (see
%	folder named '3rd_party').
%

	% Check calling format
	narginchk(0, 1);
	nargoutchk(0, 2);
	
	% Structure for "auxiliary main program data"
	misc = struct( ...
		'lang',		'en', ...
		'version',	struct(...	% Version check
			'req',		datenum('September 11, 2012', 'mmmm dd, yyyy'), ...
			'curr',		datenum(version('-date'), 'mmmm dd, yyyy'), ...
			'errID',	'MATLAB:antMeas:incompatibleMatlabVersion' ...
			), ...	
		'en',		struct(...	% 'en' translation for main program messages
			'unknown',	'Unknown parameter ''%s'', using defaults.', ...
			'version',	[ 'You are currently running a MATLAB version ', ...
							'that is incompatible with antMeas GUI. ', ...
							'Please update or run from the command line.' ] ...
			) ...
		);
	
	% Handle input parameters
	debug = false;
	noGUI = false;
	
	if nargin == 1 && ischar(varargin{1})
		switch lower(varargin{1}(1))
			case 'd' 				% Set debugging
				debug = ~debug;
			case {'m', 'v', 'h'} 	% Display help
				help antMeas;
			case {'c', 'r'} 		% Clear current Matlab instance
				clearvars -except varargin varargout debug noGUI; 
				clc; close all;
			case 'n'				% No GUI
				noGUI = ~noGUI;
			otherwise				% Unknown
				fprintf(misc.(misc.lang).unknown, varargin{1});
		end
	end

	% GUI requires MATLAB version 8.X (i.e., 2012b or later)
	if ~noGUI && (misc.version.curr < misc.version.req)
		error(misc.version.errID, misc.(misc.lang).version);
	end
	clear misc;

	% Add paths
	addpath(genpath('1st_party'));
	
    % Initialize static data
	s = initStatic();
	
	% Create GUI (or don't)
	if noGUI
		g = createNoGUI(s, debug);
	else
		addpath(genpath('3rd_party'));
		g = createInterface(s, debug);
	end
	clear noGUI debug;
	
	% Output arguments
	if nargout > 0
		varargout{1} = g;
	end
	if nargout > 1
		varargout{2} = s;
	end
    
end
