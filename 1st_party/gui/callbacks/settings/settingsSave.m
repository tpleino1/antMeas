function settingsSave(hObject, ~, gui, static)
% Save interpolation settings (if ran from GUI) and interpolate
	
	gui = guidata(gui.window);
	
	% Do not save GUI-based interpolation settings if ran from cmd
	if ~isempty(hObject)
	
		% Shorthands
		fMin = abs(str2double(get(gui.settingsTab.interpPanel.freqMinEdit, 'String')));
		fMax = abs(str2double(get(gui.settingsTab.interpPanel.freqMaxEdit, 'String')));
		fCount = round(abs(str2double(get(gui.settingsTab.interpPanel.freqCountEdit, 'String'))));
		fCoeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);

		pMin = str2double(get(gui.settingsTab.interpPanel.primMinEdit, 'String'));
		pMax = str2double(get(gui.settingsTab.interpPanel.primMaxEdit, 'String'));
		pCount = round(abs(str2double(get(gui.settingsTab.interpPanel.primCountEdit, 'String'))));

		sMin = str2double(get(gui.settingsTab.interpPanel.secMinEdit, 'String'));
		sMax = str2double(get(gui.settingsTab.interpPanel.secMaxEdit, 'String'));
		sCount = round(abs(str2double(get(gui.settingsTab.interpPanel.secCountEdit, 'String'))));

		pCoeff = static.tabs.settings.units.phase.coeffs(gui.dynamic.units.phase);	
	
		% Store into gui.dynamic
		gui.dynamic.interpolated.freq = linspace(fMin, fMax, fCount)' * fCoeff;
		gui.dynamic.interpolated.prim = linspace(pMin, pMax, pCount)' * pCoeff;
		gui.dynamic.interpolated.sec = linspace(sMin, sMax, sCount)' * pCoeff;

		gui.dynamic.interp.function = ...
			get(gui.settingsTab.interpPanel.functSelect, 'Value');
		gui.dynamic.interp.method = ...
			get(gui.settingsTab.interpPanel.methodSelect, 'Value');
	end
	
	% Interpolate
	gui.dynamic.interpolated = interpAntMeas( ...
		gui.dynamic.original, gui.dynamic.interpolated, gui.dynamic.enable, ...
		static.tabs.settings.interp.function.options{gui.dynamic.interp.function}, ...
		gui.dynamic.interp.method);
	
	options = gui.mainLayout.TabEnable;
	select = 2;
	
	% Enable & Change tabs
	if gui.dynamic.enable.horiz || gui.dynamic.enable.vert
		options{4} = 'on';
		select = 4;
	end
	
	if gui.dynamic.enable.eff
		options{5} = 'on';
		select = 5;
	end
	
	guidata(gui.window, gui);
	
	% Create tabs if not there already
	if (gui.dynamic.enable.horiz || gui.dynamic.enable.vert) && ...
			isempty(gui.pattTab.pattLayout.Children)
		createPattTab(gui, static);
	end
	
	if gui.dynamic.enable.eff && isempty(gui.effTab.effLayout.Children)
		createEffTab(gui, static);
	end
	
	gui = guidata(gui.window);
	
	% Set the tabs to be updated when changed to
	gui.dynamic.tabDefaults(4:5) = [true true];
	
	% Update GUI
	gui.mainLayout.TabEnable = options;
	gui.mainLayout.SelectedChild = select;
	tabChanged(gui.mainLayout, ...
		struct('PreviousChild', 2, 'SelectedChild', select), gui, static);

	guidata(gui.window, gui);
	
end
