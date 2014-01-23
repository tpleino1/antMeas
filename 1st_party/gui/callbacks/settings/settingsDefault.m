function settingsDefault(~, ~, gui, static)
% Reset the Settings tab to its default values

	gui = guidata(gui.window);
	
	% Freq
	gui.dynamic.units.freq = static.tabs.settings.units.freq.default;
	set(gui.settingsTab.unitPanel.freqSelect, ...
		'Value',	gui.dynamic.units.freq);
	
	% Phase
	gui.dynamic.units.phase = static.tabs.settings.units.phase.default;
	set(gui.settingsTab.unitPanel.phaseSelect, ...
		'Value',	gui.dynamic.units.phase);
		
	% Table units
	
	fUnit = static.tabs.settings.units.freq.units{gui.dynamic.units.freq};
	pUnit = static.tabs.settings.units.phase.units{gui.dynamic.units.phase};
	set(gui.settingsTab.interpPanel.freqLabel, 'String', ...
		sprintf(static.tabs.settings.interpPanel.freqLabel, fUnit));
	set(gui.settingsTab.interpPanel.primLabel, 'String', ...
		sprintf(static.tabs.settings.interpPanel.primLabel, pUnit));
	set(gui.settingsTab.interpPanel.secLabel, 'String', ...
		sprintf(static.tabs.settings.interpPanel.secLabel, pUnit));
	clear fUnit pUnit;
	
	set(gui.settingsTab.interpPanel.panel, 'Enable', 'Off');
	set(gui.settingsTab.buttonRow.saveButton, 'Enable', 'Off');
		
	if (gui.debug || gui.dynamic.enable.horiz || gui.dynamic.enable.vert)
		
		% Shorthands
		f = gui.dynamic.original.freq;
		p = gui.dynamic.original.prim;
		s = gui.dynamic.original.sec;
	
		% Debug values
		if gui.debug && (isempty(f) || isempty(p) || isempty(s))
			f = (700:40:1100)' * 1e6;
			p = (-180:10:180)';
			s = (0:-10:-180)';
		end
		
		set(gui.settingsTab.interpPanel.panel, 'Enable', 'On');
		set(gui.settingsTab.buttonRow.saveButton, 'Enable', 'On');
		set(gui.settingsTab.interpPanel.totalEdit, ...
			'Enable',	static.general.styles.edit.enable);
		
		% Function
		gui.dynamic.interp.function = static.tabs.settings.interp.function.default;
		set(gui.settingsTab.interpPanel.functSelect, ...
			'Value',	gui.dynamic.interp.function);
		
		% Method
		gui.dynamic.interp.method = static.tabs.settings.interp.method.default;
		set(gui.settingsTab.interpPanel.methodSelect, ...
			'Value',	gui.dynamic.interp.method);
		
		% Frequency	
		fCoeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);
		set(gui.settingsTab.interpPanel.freqMinEdit, ...
			'String',	num2str(min(f) / fCoeff, '%g'));
		set(gui.settingsTab.interpPanel.freqMaxEdit, ...
			'String',	num2str(max(f) / fCoeff, '%g'));
		set(gui.settingsTab.interpPanel.freqStepEdit, ...
			'String',	num2str(abs(mean(diff(f))) / fCoeff, '%g'));
		set(gui.settingsTab.interpPanel.freqCountEdit, ...
			'String',	int2str(length(f)));
		clear fCoeff;

		% Primary
		pCoeff = static.tabs.settings.units.phase.coeffs(gui.dynamic.units.phase);
		set(gui.settingsTab.interpPanel.primMinEdit, ...
			'String',	num2str(min(p) / pCoeff, '%g'));
		set(gui.settingsTab.interpPanel.primMaxEdit, ...
			'String',	num2str(max(p) / pCoeff, '%g'));
		set(gui.settingsTab.interpPanel.primStepEdit, ...
			'String',	num2str(abs(mean(diff(p))) / pCoeff, '%g'));
		set(gui.settingsTab.interpPanel.primCountEdit, ...
			'String',	int2str(length(p)));
		
		% Secondary
		set(gui.settingsTab.interpPanel.secMinEdit, ...
			'String',	num2str(min(s) / pCoeff, '%g'));
		set(gui.settingsTab.interpPanel.secMaxEdit, ...
			'String',	num2str(max(s) / pCoeff, '%g'));
		set(gui.settingsTab.interpPanel.secStepEdit, ...
			'String',	num2str(abs(mean(diff(s))) / pCoeff, '%g'));
		set(gui.settingsTab.interpPanel.secCountEdit, ...
			'String',	int2str(length(s)));
		
		% Total
		set(gui.settingsTab.interpPanel.totalEdit, ...
			'String',	int2str(length(f) * length(p) * length(s)));
			
	end
	
	guidata(gui.window, gui);
	
end
