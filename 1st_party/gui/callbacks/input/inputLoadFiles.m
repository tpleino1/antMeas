function inputLoadFiles(hObject, ~, gui, static)
% Load the data from specified input files into gui.dynamic
	
	gui = guidata(gui.window);
		
	% Some shorthands
	aH = [gui.dynamic.io.aut.horiz.path, gui.dynamic.io.aut.horiz.file];
	aV = [gui.dynamic.io.aut.vert.path, gui.dynamic.io.aut.vert.file];
	aS = [gui.dynamic.io.aut.sParam.path, gui.dynamic.io.aut.sParam.file];
	
	rH = [gui.dynamic.io.ref.horiz.path, gui.dynamic.io.ref.horiz.file];
	rV = [gui.dynamic.io.ref.vert.path, gui.dynamic.io.ref.vert.file];
	rE = [gui.dynamic.io.ref.eff.path, gui.dynamic.io.ref.eff.file];
	
	dyn = initDynamic(static);
	dyn.io = gui.dynamic.io;
	dyn.plotting = gui.dynamic.plotting;
	
	% S-params require only the S-param data
	% Pattern requires (autHoriz) OR (autVert)
	% Efficiency requires full pattern, S-params and the reference efficiency	
	% (Cannot use same files for both pol, both aut and ref must be specified)
	try		
		
		% Load S-Param
		dyn.enable.sParam = ~isempty(aS);
		
		if dyn.enable.sParam
			[f, s, z] = readSparamFile(aS);
			dyn.enable.sParam = ...
				(~isempty(f) && ~isempty(s(:,1)) && ~isempty(z));
			
			if dyn.enable.sParam
				dyn.original.aut.sParam.freq = f;
				dyn.original.aut.sParam.s11 = s(:, 1);
				dyn.original.aut.sParam.z0 = z;
			end
		end
		
		% Load AUT-Horiz
		dyn.enable.horiz = (~strcmp(aH, aV) && ~isempty(aH));
		
		if dyn.enable.horiz
			[f, p, s, d] = readAntPatt(aH);
			dyn.enable.horiz = (~isempty(f) && ~isempty(p) && ...
				~isempty(s) && ~isempty(d));

			if dyn.enable.horiz
				dyn.original.aut.horiz.freq = f;
				dyn.original.aut.horiz.prim = p;
				dyn.original.aut.horiz.sec = s;
				dyn.original.aut.horiz.data = d;
			end
		end
		
		% Load AUT-Vert
		dyn.enable.vert = (~strcmp(aH, aV) && ~isempty(aV));
		
		if dyn.enable.vert
			[f, p, s, d] = readAntPatt(aV);
			dyn.enable.vert = (~isempty(f) && ~isempty(p) && ...
				~isempty(s) && ~isempty(d));

			if dyn.enable.vert
				dyn.original.aut.vert.freq = f;
				dyn.original.aut.vert.prim = p;
				dyn.original.aut.vert.sec = s;
				dyn.original.aut.vert.data = d;
			end
		end
		
		% Load those needed for EFF
		dyn.enable.eff = (dyn.enable.horiz && dyn.enable.vert && ...
			dyn.enable.sParam && ~isempty(rE));
		
		% Ref-Horiz
		if dyn.enable.eff
			[f, p, s, d] = readAntPatt(rH);
			dyn.enable.eff = (~isempty(f) && ~isempty(p) && ...
				~isempty(s) && ~isempty(d));

			if dyn.enable.eff
				dyn.original.ref.horiz.freq = f;
				dyn.original.ref.horiz.prim = p;
				dyn.original.ref.horiz.sec = s;
				dyn.original.ref.horiz.data = d;
			end
		end
		
		% Ref-Vert
		if dyn.enable.eff
			[f, p, s, d] = readAntPatt(rV);
			dyn.enable.eff = (~isempty(f) && ~isempty(p) && ...
				~isempty(s) && ~isempty(d));

			if dyn.enable.eff
				dyn.original.ref.vert.freq = f;
				dyn.original.ref.vert.prim = p;
				dyn.original.ref.vert.sec = s;
				dyn.original.ref.vert.data = d;
			end
		end
		
		% Ref-Eff
		if dyn.enable.eff
			[f, e, s] = readRefEff(rE);
			dyn.enable.eff = (~isempty(f) && ~isempty(e) && ~isempty(s));
			
			if dyn.enable.eff
				dyn.original.ref.eff.freq = f;
				dyn.original.ref.eff.eff = e;
				dyn.original.ref.eff.s11 = s;
			end
		end
		
		clear f p s d e z aH aV aS rH rV rE;
		
		% Make the default vectors
		if (dyn.enable.horiz || dyn.enable.vert)
			
			% Some shorthands
			coeff = [NaN 1];
			hCoeff = coeff(dyn.enable.horiz + 1);
			vCoeff = coeff(dyn.enable.vert + 1);
			sCoeff = coeff(dyn.enable.sParam + 1);
			eCoeff = coeff(dyn.enable.eff + 1);
			clear coeff;
			
			% Frequency
			fMin = max(abs([	...
				hCoeff * min(dyn.original.aut.horiz.freq), ...
				vCoeff * min(dyn.original.aut.vert.freq), ...
				sCoeff * min(dyn.original.aut.sParam.freq), ...
				hCoeff * min(dyn.original.ref.horiz.freq), ...
				vCoeff * min(dyn.original.ref.vert.freq), ...
				eCoeff * min(dyn.original.ref.eff.freq) ...
				]));

			fMax = min(abs([	...
				hCoeff * max(dyn.original.aut.horiz.freq), ...
				vCoeff * max(dyn.original.aut.vert.freq), ...
				sCoeff * max(dyn.original.aut.sParam.freq), ...
				hCoeff * max(dyn.original.ref.horiz.freq), ...
				vCoeff * max(dyn.original.ref.vert.freq), ...
				eCoeff * max(dyn.original.ref.eff.freq) ...
				]));

			fStep = max(abs([	...
				hCoeff * mean(diff(dyn.original.aut.horiz.freq)), ...
				vCoeff * mean(diff(dyn.original.aut.vert.freq)), ...
				sCoeff * mean(diff(dyn.original.aut.sParam.freq)), ...
				hCoeff * mean(diff(dyn.original.ref.horiz.freq)), ...
				vCoeff * mean(diff(dyn.original.ref.vert.freq)), ...
				eCoeff * mean(diff(dyn.original.ref.eff.freq)) ...
				]));

			dyn.original.freq = (fMin : fStep : fMax)';
			clear fMin fMax fStep;

			% Primary angle
			pMin = max([	...
				hCoeff * min(dyn.original.aut.horiz.prim), ...
				vCoeff * min(dyn.original.aut.vert.prim), ...
				hCoeff * min(dyn.original.ref.horiz.prim), ...
				vCoeff * min(dyn.original.ref.vert.prim) ...
				]);

			pMax = min([	...
				hCoeff * max(dyn.original.aut.horiz.prim), ...
				vCoeff * max(dyn.original.aut.vert.prim), ...
				hCoeff * max(dyn.original.ref.horiz.prim), ...
				vCoeff * max(dyn.original.ref.vert.prim) ...
				]);

			pStep = max(abs([	...
				hCoeff * mean(diff(dyn.original.aut.horiz.prim)), ...
				vCoeff * mean(diff(dyn.original.aut.vert.prim)), ...
				hCoeff * mean(diff(dyn.original.ref.horiz.prim)), ...
				vCoeff * mean(diff(dyn.original.ref.vert.prim)) ...
				]));

			dyn.original.prim = (pMin : pStep : pMax)';
			clear pMin pMax pStep;

			% Secondary angle
			sMin = max([	...
				hCoeff * min(dyn.original.aut.horiz.sec), ...
				vCoeff * min(dyn.original.aut.vert.sec), ...
				hCoeff * min(dyn.original.ref.horiz.sec), ...
				vCoeff * min(dyn.original.ref.vert.sec) ...
				]);

			sMax = min([	...
				hCoeff * max(dyn.original.aut.horiz.sec), ...
				vCoeff * max(dyn.original.aut.vert.sec), ...
				hCoeff * max(dyn.original.ref.horiz.sec), ...
				vCoeff * max(dyn.original.ref.vert.sec) ...
				]);

			sStep = max(abs([	...
				hCoeff * mean(diff(dyn.original.aut.horiz.sec)), ...
				vCoeff * mean(diff(dyn.original.aut.vert.sec)), ...
				hCoeff * mean(diff(dyn.original.ref.horiz.sec)), ...
				vCoeff * mean(diff(dyn.original.ref.vert.sec)) ...
				]));

			dyn.original.sec = (sMin : sStep : sMax)';
			clear sMin sMax sStep;
		
		end
		
		% Set enable status
		dyn.enable.horiz = dyn.enable.horiz && ~isempty(dyn.original.freq) && ...
			~isempty(dyn.original.prim) && ~isempty(dyn.original.sec);
		dyn.enable.vert = dyn.enable.vert && ~isempty(dyn.original.freq) && ...
			~isempty(dyn.original.prim) && ~isempty(dyn.original.sec);
		dyn.enable.eff = dyn.enable.eff && dyn.enable.horiz && dyn.enable.vert;
		
		% Atleast something to do
		success = (dyn.enable.sParam || dyn.enable.horiz || dyn.enable.vert);
		
	catch err
		success = 0;
		getReport(err);
	end

	% Files loaded successfully -> update dynamic
	if success	

		gui.dynamic = dyn; % reset basically everything
		guidata(gui.window, gui);
			
		if ~isempty(hObject)
			% Create & enable specified tabs
			options = {'on', 'on', 'off', 'off', 'off'};
			
			% Default tab
			if dyn.enable.sParam
				options{3} = 'on';
			end

			% Settings
			if isempty(gui.settingsTab.settingsLayout.Children)
				createSettingsTab(gui, static);
			end
			
			% S-param
			if dyn.enable.sParam && isempty(gui.sParamTab.sParamLayout.Children)
				createSParamTab(gui, static);
			end
			
			gui = guidata(gui.window);

			% Update tab settings & change tab
			gui.mainLayout.TabEnable = options;
			gui.mainLayout.SelectedChild = 2;
			tabChanged(gui.mainLayout, ...
				struct('PreviousChild', 1, 'SelectedChild', 2), ...
				gui, static);
		end

	else
		% errMsg(0, 'Error.');
		set(gui.inputTab.buttonRow.openLabel, 'String', 'Error.');
	end
	
	guidata(gui.window, gui);
	
	
% 	% Error reporting (not used to full extent)
% 	function errMsg(code, str)
% 		if (nargin < 2 && code > 0)
% 			switch (code)			
% 				case 1 % empty
% 					str = static.tabs.input.errorMsg.empty;
% 				case 2 % same
% 					str = static.tabs.input.errorMsg.same;
% 				case 3 % load
% 					str = static.tabs.input.errorMsg.load;
% 				otherwise % unknown
% 					str = static.tabs.input.errorMsg.unknown;
% 			end
% 		end
% 		set(gui.inputTab.buttonRow.openLabel, 'String', str);
% 	end
	
end
